//
//  Document+Operations.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 05/05/2016.
//
//

import Foundation


// MARK: -  Operation support

extension BartlebyDocument {

    // MARK: - Supervised Automatic Push

    func startSupervisionLoopIfNecessary() {
        if self._timer==nil{
            self._timer=Timer(timeInterval: Bartleby.configuration.SUPERVISION_LOOP_TIME_INTERVAL_IN_SECONDS, target: self, selector: #selector(BartlebyDocument.superVisionLoop), userInfo: nil, repeats: true)
            RunLoop.current.add(self._timer!, forMode: RunLoopMode.commonModes)
        }
    }

    func superVisionLoop () -> () {
        if self.shouldBePushed(){
            self.synchronizePendingOperations()
        }
    }

    public func shouldBePushed()->Bool{
        return self.registryMetadata.pushOnChanges
    }


    // MARK: - Operations

    /**
     Commits the pending changes.
     - throws: may throw on collection iteration
     */
    public func commitPendingChanges() throws {
        var triggerUpsertString=""
        self.iterateOnCollections { (collection) in
            let UIDS=collection.commitChanges()
            if UIDS.count>0{
                triggerUpsertString += "\(UIDS.count),\(collection.d_collectionName)"+UIDS.joined(separator: ",")
            }
        }
    }

    /**
     Synchronizes the pending operations
     1. Proceeds to login
     3. Then pushes the pending operations

     - parameter handlers: the handlers to monitor the progress and completion
     */
    public func synchronizePendingOperations() {
        if let currentUser=self.registryMetadata.currentUser {
            if currentUser.loginHasSucceed{
                do {
                    try self._commitAndPushPendingOperations()
                } catch {
                    self.synchronizationHandlers.on(Completion.failureState("Push operations has failed. Error: \(error)", statusCode: StatusOfCompletion.expectation_Failed))
                }
            }else{
                currentUser.login( sucessHandler: {
                    do {
                        try self._commitAndPushPendingOperations()
                    } catch {
                        self.synchronizationHandlers.on(Completion.failureState("Push operations has failed. Error: \(error)", statusCode: StatusOfCompletion.expectation_Failed))
                    }
                    }, failureHandler: { (context) in
                        self.synchronizationHandlers.on(Completion.failureStateFromJHTTPResponse(context))
                })
            }
        }
    }


    /**
     Commits and Pushes the pending operations.
     The Command will optimize and inject commands if some changes has occured.

     - parameter handlers: the handlers to monitor the progress and completion

     - throws: throws
     */
    fileprivate func _commitAndPushPendingOperations()throws {
        // Commit the pending changes (if there are changes)
        // Each changed object creates a new Operation
        try self.commitPendingChanges()
        self._pushNextBunch()
    }


    fileprivate func _pushNextBunch(){
        // Push next bunch if there is no bunch in progress
        if !self.registryMetadata.bunchInProgress {
            // We donnot want to schedule anything if there is nothing to do.
            if self.pushOperations.count > 0 {
                let nextBunchOfOperations=self._getNextBunchOfPendingOperations()
                if nextBunchOfOperations.count>0{
                    bprint("Pushing Next Bunch of operations",file:#file,function:#function,line:#line,category:DEFAULT_BPRINT_CATEGORY,decorative:false)
                    let bunchHandlers=Handlers(completionHandler: { (completionState) in
                        self._pushNextBunch()
                        }, progressionHandler: { (progressionState) in
                            self.synchronizationHandlers.notify(progressionState)
                    })
                    self.pushSortedOperations(nextBunchOfOperations, handlers:bunchHandlers)
                }
            }
        }
    }


    fileprivate func _getNextBunchOfPendingOperations()->[PushOperation]{
        var nextBunch=[PushOperation]()
        let filtered=self.pushOperations.filter { $0.canBePushed() }
        let filteredCount=filtered.count
        let maxBunchSize=Bartleby.configuration.MAX_OPERATIONS_BUNCH_SIZE
        if filteredCount > 0 {
            let lastOperationIdx =  filteredCount-1
            let maxIndex:Int = min(maxBunchSize,lastOperationIdx)
            for i in 0 ... maxIndex {
                nextBunch.append(filtered[i])
            }
        }
        return nextBunch
    }



    /**
     Pushes an array of operations

     - On successful completion the operation is deleted.
     - On total completion the tasks are deleted on global success.
     If an error as occured the task group is preserved for re-run or analysis.

     - parameter operations: the sorted operations to be excecuted
     - parameter handlers:   the handlers to hook the completion / Progression
     */
    public func pushSortedOperations(_ bunchOfOperations: [PushOperation], handlers: Handlers?)->() {

        let totalNumberOfOperations=self.pushOperations.count

        if self.registryMetadata.pendingOperationsProgressionState==nil{
            // It is the first Bunch
            self.registryMetadata.totalNumberOfOperations=self.pushOperations.count
            self.registryMetadata.pendingOperationsProgressionState=Progression(currentTaskIndex: 0, totalTaskCount:totalNumberOfOperations, currentPercentProgress:0, message: self._messageForOperation(nil), data:nil).identifiedBy("Operations", identity:"Operations."+self.UID)
        }

        let nbOfOperationsInCurrentBunch=bunchOfOperations.count
        if  nbOfOperationsInCurrentBunch>0 {

            // Flag there is an active Bunch of Operations in Progress
            self.registryMetadata.bunchInProgress=true

            for operation in bunchOfOperations{
                if let serialized=operation.toDictionary {
                    if let command = try? JSerializer.deserializeFromDictionary(serialized) {
                        if let jCommand=command as? JHTTPCommand {
                            DispatchQueue.main.async(execute: {
                                // Push the command.
                                jCommand.push(sucessHandler: {  (context) in
                                    self.delete(operation)
                                    self._onCompletion(operation, within: bunchOfOperations, handlers: handlers,identity:self.registryMetadata.pendingOperationsProgressionState!.externalIdentifier)
                                    }, failureHandler: { (context) in
                                        self._onCompletion(operation, within: bunchOfOperations, handlers: handlers,identity:self.registryMetadata.pendingOperationsProgressionState!.externalIdentifier)
                                })
                            })
                        } else {
                            let completion=Completion.failureState(NSLocalizedString("Error of operation casting", tableName:"operations", comment: "Error of operation casting"), statusCode: StatusOfCompletion.expectation_Failed)
                            bprint(completion, file: #file, function: #function, line: #line, category: "Operations")
                            handlers?.on(completion)
                        }
                    } else {
                        let completion=Completion.failureState(NSLocalizedString( "Error on operation deserialization", tableName:"operations", comment:  "Error on operation deserialization"), statusCode: StatusOfCompletion.expectation_Failed)
                        bprint(completion, file: #file, function: #function, line: #line, category: "Operations")
                        handlers?.on(completion)
                    }
                } else {
                    let completion=Completion.failureState(NSLocalizedString( "Error when converting the operation to dictionnary", tableName:"operations", comment: "Error when converting the operation to dictionnary"), statusCode: StatusOfCompletion.precondition_Failed)
                    bprint(completion, file: #file, function: #function, line: #line, category: "Operations")
                    handlers?.on(completion)
               } 
            }
        } else {
            let completion=Completion.successState()
            completion.message=NSLocalizedString("Void bunch of operations", tableName:"operations", comment: "Void bunch of operations")
            handlers?.on(completion)
        }
    }

    /**
     Called on the completion of any operation in the bunch

     - parameter completedOperation: the completed operation
     - parameter bunchOfOperations:  the bunch
     - parameter handlers:           the global handlers
     - parameter identity:           the bunch identity
     */
    fileprivate func _onCompletion(_ completedOperation:PushOperation,within bunchOfOperations:[PushOperation], handlers:Handlers?,identity:String){
        let nbOfunCompletedOperationsInBunch=Double(bunchOfOperations.filter { $0.completionState==nil }.count)
        let currentOperationsCounter=self.pushOperations.count
        if nbOfunCompletedOperationsInBunch == 0{

            let _=self._updateProgressionState(completedOperation,currentOperationsCounter)

            // All the operation of that bunch have been completed.
            let bunchCompletionState=Completion().identifiedBy("Operations", identity:identity)
            bunchCompletionState.success=bunchOfOperations.reduce(true, { (success, operation) -> Bool in
                if operation.completionState?.success==true{
                    return true
                }
                return false
            })
            if bunchCompletionState.success{
                bunchCompletionState.statusCode = StatusOfCompletion.ok.rawValue
            }else{
                bunchCompletionState.statusCode = StatusOfCompletion.expectation_Failed.rawValue
            }
            self.registryMetadata.bunchInProgress=false
            handlers?.on(bunchCompletionState)

            // Let's remove the progression state if there is no more operations
            if currentOperationsCounter==0 {
                self.registryMetadata.pendingOperationsProgressionState=nil
                self.registryMetadata.totalNumberOfOperations=0//Reset the number of operation
                let finalCompletionState=Completion.successState().identifiedBy("Operations", identity:identity)
                self.synchronizationHandlers.on(finalCompletionState)
            }
        }else{
            if let progressionState=self._updateProgressionState(completedOperation,currentOperationsCounter){
                 handlers?.notify(progressionState)
            }
        }
    }

    fileprivate func _updateProgressionState(_ completedOperation:PushOperation,_ currentOperationsCounter:Int)->Progression?{
        if let progressionState=self.registryMetadata.pendingOperationsProgressionState{
            let total=Double(self.registryMetadata.totalNumberOfOperations)
            let completed=Double(self.registryMetadata.totalNumberOfOperations-currentOperationsCounter)
            let currentPercentProgress=completed*Double(100)/total
            progressionState.currentTaskIndex=Int(completed)
            progressionState.totalTaskCount=Int(total)
            progressionState.currentPercentProgress=currentPercentProgress
            progressionState.message=self._messageForOperation(completedOperation)
            return progressionState
        }else{
            bprint("Internal inconsistency unable to find identified operation bunch", file: #file, function: #function, line: #line, category: "Operations")
            return nil
        }

    }


    fileprivate func _messageForOperation(_ operation:PushOperation?)->String{
        return NSLocalizedString("Upstream Data transmission", tableName:"operations", comment: "Upstream Data transmission")
    }


    /**
     A collection iterator

     - parameter on: the iteration closure
     */
    public func iterateOnCollections(_ on:(_ collection: BartlebyCollection)->()){
        for (_, collection) in self._collections {
            on(collection)
        }
    }

    
}
