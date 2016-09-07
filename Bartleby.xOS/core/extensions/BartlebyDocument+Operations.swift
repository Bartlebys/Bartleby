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
            self._timer=NSTimer(timeInterval: Bartleby.configuration.SUPERVISION_LOOP_TIME_INTERVAL_IN_SECONDS, target: self, selector: #selector(BartlebyDocument.superVisionLoop), userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(self._timer!, forMode: NSRunLoopCommonModes)
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
                triggerUpsertString += "\(UIDS.count),\(collection.d_collectionName)"+UIDS.joinWithSeparator(",")
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
                    self.synchronizationHandlers.on(Completion.failureState("Push operations has failed. Error: \(error)", statusCode: StatusOfCompletion.Expectation_Failed))
                }
            }else{
                currentUser.login(withPassword: currentUser.password, sucessHandler: {
                    do {
                        try self._commitAndPushPendingOperations()
                    } catch {
                        self.synchronizationHandlers.on(Completion.failureState("Push operations has failed. Error: \(error)", statusCode: StatusOfCompletion.Expectation_Failed))
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
    private func _commitAndPushPendingOperations()throws {
        // Commit the pending changes (if there are changes)
        // Each changed object creates a new Operation
        try self.commitPendingChanges()
        self._pushNextBunch()
    }


    private func _pushNextBunch(){
        // Push next bunch if there is no bunch in progress
        if !self.registryMetadata.bunchInProgress {
            // We donnot want to schedule anything if there is nothing to do.
            if self.operations.count > 0 {
                let nextBunchOfOperations=self._popNextBunchOfPendingOperations()
                if nextBunchOfOperations.count>0{
                    let bunchHandlers=Handlers(completionHandler: { (completionState) in
                        self.synchronizationHandlers.on(completionState)
                        self._pushNextBunch()
                        }, progressionHandler: { (progressionState) in
                            self.synchronizationHandlers.notify(progressionState)
                    })
                    self.pushSortedOperations(nextBunchOfOperations, handlers:bunchHandlers)
                }
            }
        }
    }


    private func _popNextBunchOfPendingOperations()->[Operation]{
        var nextBunch=[Operation]()
        let filtered=self.operations.filter { $0.canBePushed() }
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
    public func pushSortedOperations(bunchOfOperations: [Operation], handlers: Handlers?)->() {

        let totalNumberOfOperations=self.operations.count

        if self.registryMetadata.upDataProgressionState==nil{
            self.registryMetadata.upDataProgressionState=Progression(currentTaskIndex: 0, totalTaskCount:totalNumberOfOperations, currentPercentProgress:0, message: "Data synchronization upstream", data:nil).identifiedBy("Operations", identity:self.UID)
        }

        let nbOfOperationsInCurrentBunch=bunchOfOperations.count
        if  nbOfOperationsInCurrentBunch>0 {

            // Flag there is an active Bunch of Operations in Progress
            self.registryMetadata.bunchInProgress=true

            for operation in bunchOfOperations{
                if let serialized=operation.toDictionary {
                    if let command = try? JSerializer.deserializeFromDictionary(serialized) {
                        if let jCommand=command as? JHTTPCommand {
                            dispatch_async(dispatch_get_main_queue(), {
                                // Push the command.
                                jCommand.push(sucessHandler: { (context) in
                                    self.delete(operation)
                                    self._onCompletion(operation, within: bunchOfOperations, handlers: handlers,identity: self.UID)
                                    }, failureHandler: { (context) in
                                        self._onCompletion(operation, within: bunchOfOperations, handlers: handlers,identity:self.UID)
                                })
                            })
                        } else {
                            let completion=Completion.failureState(NSLocalizedString("Error of operation casting", tableName:"operations", comment: "Error of operation casting"), statusCode: StatusOfCompletion.Expectation_Failed)
                            bprint(completion, file: #file, function: #function, line: #line, category: "Operations")
                            handlers?.on(completion)
                        }
                    } else {
                        let completion=Completion.failureState(NSLocalizedString( "Error on operation deserialization", tableName:"operations", comment:  "Error on operation deserialization"), statusCode: StatusOfCompletion.Expectation_Failed)
                        bprint(completion, file: #file, function: #function, line: #line, category: "Operations")
                        handlers?.on(completion)
                    }
                } else {
                    let completion=Completion.failureState(NSLocalizedString( "Error when converting the operation to dictionnary", tableName:"operations", comment: "Error when converting the operation to dictionnary"), statusCode: StatusOfCompletion.Precondition_Failed)
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
    private func _onCompletion(completedOperation:Operation,within bunchOfOperations:[Operation], handlers:Handlers?,identity:String){
        let nbOfunCompletedOperationsInBunch=Double(bunchOfOperations.filter { $0.completionState==nil }.count)
        let totalNbOfunCompletedOperations=Double(self.operations.filter { $0.completionState==nil }.count)
        if nbOfunCompletedOperationsInBunch == 0{
            // All the operation of that bunch has been completed.
            let bunchCompletionState=Completion().identifiedBy("Operations", identity:identity)
            bunchCompletionState.success=bunchOfOperations.reduce(true, combine: { (success, operation) -> Bool in
                if operation.completionState?.success==true{
                    return true
                }
                return false
            })
            if bunchCompletionState.success{
                bunchCompletionState.statusCode = StatusOfCompletion.OK.rawValue
            }else{
                bunchCompletionState.statusCode = StatusOfCompletion.Expectation_Failed.rawValue
            }
            // Let's remove the progression state if there is no more operations
            if totalNbOfunCompletedOperations==0 {
                self.registryMetadata.upDataProgressionState=nil
            }
            self.registryMetadata.bunchInProgress=false
            handlers?.on(bunchCompletionState)
        }else{
            if let progressionState=self.registryMetadata.upDataProgressionState{
                let total=Double(self.operations.count)
                let completed=Double(total-totalNbOfunCompletedOperations)
                let currentPercentProgress=completed*Double(100)/total
                progressionState.currentTaskIndex=Int(completed)
                progressionState.totalTaskCount=Int(total)
                progressionState.currentPercentProgress=currentPercentProgress
                handlers?.notify(progressionState)
            }else{
                bprint("Internal inconsistency unable to find identified operation bunch", file: #file, function: #function, line: #line, category: "Operations")
            }
        }

    }


    /**
     A collection iterator

     - parameter on: the iteration closure
     */
    public func iterateOnCollections(on:(collection: BartlebyCollection)->()){
        for (_, collection) in self._collections {
            on(collection: collection)
        }
    }



    // MARK: markAsDistributed

    /**
     Marks the instance as distributed (on Push).

     - parameter instances: the collectible instances
     */
    public func markAsDistributed<T: Collectible>(inout instance: T) {
        instance.distributed=true
    }

    /**
     Marks the instances as distributed  (on Push).

     - parameter instances: the collectible instances
     */
    public func markAsDistributed<T: Collectible>(inout instances: [T]) {
        for var instance in instances {
            instance.distributed=true
        }
    }

    
}