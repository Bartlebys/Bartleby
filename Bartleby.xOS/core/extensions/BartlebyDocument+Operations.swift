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

    func startPushLoopIfNecessary() {
        if _timer == nil && !metadata.isolatedUserMode {
            _timer = Timer.scheduledTimer(timeInterval: Bartleby.configuration.LOOP_TIME_INTERVAL_IN_SECONDS,
                                          target: self,
                                          selector: #selector(BartlebyDocument._pushLoop),
                                          userInfo: nil,
                                          repeats: true)
        }
    }

    func destroyThePushLoop() {
        _timer?.invalidate()
        _timer = nil
    }

    // The push loop
    @objc internal func _pushLoop() {
        if metadata.pushOnChanges {
            synchronizePendingOperations()
        }
    }

    // MARK: - Operations

    /**
     Synchronizes the pending operations

     1. Proceeds to login if necessart
     2. Then commits the pending changes and pushes operations

     - parameter handlers: the handlers to monitor the progress and completion
     */
    public func synchronizePendingOperations() {
        if let currentUser = self.metadata.currentUser {
            if currentUser.loginHasSucceed {
                do {
                    try _commitAndPushPendingOperations()
                } catch {
                    synchronizationHandlers.on(Completion.failureState("Push operations has failed. Error: \(error)", statusCode: StatusOfCompletion.expectation_Failed))
                }
            } else {
                currentUser.login(sucessHandler: {
                    do {
                        try self._commitAndPushPendingOperations()
                    } catch {
                        self.synchronizationHandlers.on(Completion.failureState("Push operations has failed. Error: \(error)", statusCode: StatusOfCompletion.expectation_Failed))
                    }
                }, failureHandler: { context in
                    if context.httpStatusCode == 403 {
                        self.close()
                    } else {
                        self.log("synchronizePendingOperations Login has failed \(context)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
                        self.transition(DocumentMetadata.Transition.onToOff)
                    }
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
    fileprivate func _commitAndPushPendingOperations() throws {
        // Commit the pending changes (if there are changes)
        // Each changed object creates a new Operation
        try commitPendingChanges()
        _pushNextBunch()
    }

    /**
     Commits the pending changes.
     - throws: may throw on collection iteration
     */
    public func commitPendingChanges() throws {
        iterateOnCollections { collection in
            collection.commitChanges()
        }
    }

    fileprivate func _pushNextBunch() {
        // Push next bunch if there is no bunch in progress
        if !metadata.bunchInProgress {
            // We donnot want to schedule anything if there is nothing to do.
            if pushOperations.count > 0 {
                let nextBunchOfOperations = _getNextBunchOfPendingOperations()
                if nextBunchOfOperations.count > 0 {
                    log("Pushing Next Bunch of operations", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
                    let bunchHandlers = Handlers(completionHandler: { _ in
                        self._pushNextBunch()
                    }, progressionHandler: { progressionState in
                        self.synchronizationHandlers.notify(progressionState)
                    })
                    pushSortedOperations(nextBunchOfOperations, handlers: bunchHandlers)
                }
            }
        }
    }

    fileprivate func _getNextBunchOfPendingOperations() -> [PushOperation] {
        var nextBunch = [PushOperation]()
        let filtered = pushOperations.filter { $0.canBePushed() }
        let filteredCount = filtered.count
        let maxBunchSize = Bartleby.configuration.MAX_OPERATIONS_BUNCH_SIZE
        if filteredCount > 0 {
            let lastOperationIdx = filteredCount - 1
            let maxIndex: Int = min(maxBunchSize, lastOperationIdx)
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
    public func pushSortedOperations(_ bunchOfOperations: [PushOperation], handlers: Handlers?) {
        let totalNumberOfOperations = pushOperations.count

        if metadata.pendingOperationsProgressionState == nil {
            // It is the first Bunch
            metadata.totalNumberOfOperations = pushOperations.count
            metadata.pendingOperationsProgressionState = Progression(currentTaskIndex: 0, totalTaskCount: totalNumberOfOperations, currentPercentProgress: 0, message: _messageForOperation(nil), data: nil).identifiedBy("Operations", identity: "Operations." + UID)
        }

        let nbOfOperationsInCurrentBunch = bunchOfOperations.count
        if nbOfOperationsInCurrentBunch > 0 {
            // Flag there is an active Bunch of Operations in Progress
            metadata.bunchInProgress = true

            for operation in bunchOfOperations {
                if let serialized = operation.serialized {
                    do {
                        let o = try dynamics.deserialize(typeName: operation.operationName, data: serialized, document: nil)
                        // #TODO why is it necessary to cast to ManagedModel?
                        // If we set to BartlebyOperation it fails
                        if let op = o as? ManagedModel & BartlebyOperation {
                            op.referentDocument = self
                            syncOnMain {
                                // Push the command.
                                op.push(sucessHandler: { _ in
                                    //////////////////////////////////////////////////
                                    // Delete the operation from self.pushOperations
                                    //////////////////////////////////////////////////
                                    self.delete(operation)
                                    // Update the completion / Progression
                                    self._onCompletion(operation, within: bunchOfOperations, handlers: handlers, identity: self.metadata.pendingOperationsProgressionState!.externalIdentifier)
                                }, failureHandler: { context in

                                    let statusCode = context.httpStatusCode
                                    // Operations Quarantine
                                    // According to https://github.com/Bartlebys/Bartleby/issues/23
                                    if [403, 406, 412, 417].contains(statusCode) {
                                        //////////////////////////////////////////////////
                                        // Put the operation in Quarantine
                                        // Delete the operation from self.pushOperations
                                        //////////////////////////////////////////////////
                                        self.metadata.operationsQuarantine.append(operation)
                                        self.delete(operation)
                                    } else if statusCode == 404 {
                                        //////////////////////////////////////////////////
                                        // UPDATE operation with 404 is normal on deleted entity
                                        // According to https://github.com/Bartlebys/Bartleby/issues/24
                                        //////////////////////////////////////////////////
                                        let opTypeName = op.runTimeTypeName()
                                        if opTypeName.contains("Update") {
                                            // We delete the operation
                                            // And The local entity will be deleted by a trigger later.
                                            self.delete(operation)
                                        }
                                    }
                                    // Update the completion / Progression
                                    self._onCompletion(operation, within: bunchOfOperations, handlers: handlers, identity: self.metadata.pendingOperationsProgressionState!.externalIdentifier)

                                })
                            }
                        } else {
                            let completion = Completion.failureState(NSLocalizedString("Error of operation casting", tableName: "operations", comment: "Error of operation casting"), statusCode: StatusOfCompletion.expectation_Failed)
                            log(completion, file: #file, function: #function, line: #line, category: "Operations")
                            handlers?.on(completion)
                        }

                    } catch {
                        let completion = Completion.failureState(NSLocalizedString("Error on operation deserialization", tableName: "operations", comment: "Error on operation deserialization"), statusCode: StatusOfCompletion.expectation_Failed)
                        log(completion, file: #file, function: #function, line: #line, category: "Operations")
                        handlers?.on(completion)
                    }
                } else {
                    let completion = Completion.failureState(NSLocalizedString("Error when converting the operation to dictionnary", tableName: "operations", comment: "Error when converting the operation to dictionnary"), statusCode: StatusOfCompletion.precondition_Failed)
                    log(completion, file: #file, function: #function, line: #line, category: "Operations")
                    handlers?.on(completion)
                }
            }

        } else {
            let completion = Completion.successState()
            completion.message = NSLocalizedString("Void bunch of operations", tableName: "operations", comment: "Void bunch of operations")
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
    fileprivate func _onCompletion(_ completedOperation: PushOperation, within bunchOfOperations: [PushOperation], handlers: Handlers?, identity: String) {
        let nbOfunCompletedOperationsInBunch = Double(bunchOfOperations.filter { $0.completionState == nil }.count)
        let currentOperationsCounter = pushOperations.count
        if nbOfunCompletedOperationsInBunch == 0 {
            _ = _updateProgressionState(completedOperation, currentOperationsCounter)

            // All the operation of that bunch have been completed.
            let bunchCompletionState = Completion().identifiedBy("Operations", identity: identity)
            bunchCompletionState.success = bunchOfOperations.reduce(true, { (_, operation) -> Bool in
                if operation.completionState?.success == true {
                    return true
                }
                return false
            })
            if bunchCompletionState.success {
                bunchCompletionState.statusCode = StatusOfCompletion.ok.rawValue
            } else {
                bunchCompletionState.statusCode = StatusOfCompletion.expectation_Failed.rawValue
            }
            metadata.bunchInProgress = false
            handlers?.on(bunchCompletionState)

            // Let's remove the progression state if there is no more operations
            if currentOperationsCounter == 0 {
                metadata.pendingOperationsProgressionState = nil
                metadata.totalNumberOfOperations = 0 // Reset the number of operation
                let finalCompletionState = Completion.successState().identifiedBy("Operations", identity: identity)
                synchronizationHandlers.on(finalCompletionState)
            }
        } else {
            if let progressionState = self._updateProgressionState(completedOperation, currentOperationsCounter) {
                handlers?.notify(progressionState)
            }
        }
    }

    fileprivate func _updateProgressionState(_ completedOperation: PushOperation, _ currentOperationsCounter: Int) -> Progression? {
        if let progressionState = self.metadata.pendingOperationsProgressionState {
            let total = Double(metadata.totalNumberOfOperations)
            let completed = Double(metadata.totalNumberOfOperations - currentOperationsCounter)
            let currentPercentProgress = completed * Double(100) / total
            progressionState.currentTaskIndex = Int(completed)
            progressionState.totalTaskCount = Int(total)
            progressionState.currentPercentProgress = currentPercentProgress
            progressionState.message = _messageForOperation(completedOperation)
            return progressionState
        } else {
            log("Internal inconsistency unable to find identified operation bunch", file: #file, function: #function, line: #line, category: "Operations")
            return nil
        }
    }

    fileprivate func _messageForOperation(_: PushOperation?) -> String {
        return NSLocalizedString("Upstream Data transmission", tableName: "operations", comment: "Upstream Data transmission")
    }

    /**
     A collection iterator

     - parameter on: the iteration closure
     */
    public func iterateOnCollections(_ on: (_ collection: BartlebyCollection) -> Void) {
        for (_, collection) in _collections {
            on(collection)
        }
    }
}
