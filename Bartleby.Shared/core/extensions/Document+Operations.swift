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

    // MARK: - Operations

    /**
     Pushes directly the operations without neither login nor optimizing the operations.

     - parameter handlers: the handlers to monitor the progress and completion

     - throws: throws
     */
    public func pushPendingOperations(handlers: Handlers)throws {
        try self.pushArrayOfOperations(self.operations.items, handlers:handlers)
    }

    /**
     Synchronizes the pending operations
     1. Proceeds to login
     2. Optimizes the operations
     3. Then pushes the operations

     - parameter handlers: the handlers to monitor the progress and completion
     */
    public func synchronizePendingOperations(handlers: Handlers) {
        if self._operationsAreAvailable(self.operations.items, handlers:handlers)==true {
            if let currentUser=self.registryMetadata.currentUser {
                currentUser.login(withPassword: currentUser.password, sucessHandler: {
                    self.optimizeOperations()
                    do {
                        try self.pushPendingOperations(handlers)
                    } catch {
                        handlers.on(Completion.failureState("Push operations has failed error: \(error)", statusCode: CompletionStatus.Expectation_Failed))
                    }
                    }, failureHandler: { (context) in
                        handlers.on(Completion.failureStateFromJHTTPResponse(context))
                })
            }
        }
    }


    /**
     Pushes an array of operations using a Group of chained PushOperationTasks
     - On successful completion the operation is deleted.
     - On total completion the tasks are deleted on global success.
     If an error as occured the task group is preserved for rerun or analysis.

     - parameter operations: operations description
     - parameter handlers:   the handlers to hook the completion / Progression
     */
    public func pushArrayOfOperations(operations: [Operation], handlers: Handlers) throws->() {
        bprint("Pushing \(operations.count) Operations", file:#file, function:#function, line:#line, category:TasksScheduler.BPRINT_CATEGORY)
        if self._operationsAreAvailable(operations, handlers:handlers)==true {
            if operations.count==0 {
                handlers.on(Completion.successState(NSLocalizedString("Operations stack is void", comment: "Operations stack is void")))
            } else {
                // We use the encapsulated SpaceUID
                let spaceUID=self.spaceUID
                // We taskGroupFor the task
                let group=try Bartleby.scheduler.getTaskGroupWithName("Push_Operations\(spaceUID)", inDocument: self)
                group.priority=TasksGroup.Priority.High
                // We add the calling handlers
                group.handlers.appendChainedHandlers(handlers)

                for operation in operations {
                    let task=PushOperationTask(arguments:operation)
                    try group.appendChainedTask(task)
                }
                try group.start()
            }
        }
    }




    /**
     Normalized reaction to void operations stack
     Returns true if there are operation available, false if not, and react directly if not.

     - parameter operations: the operation
     - parameter handlers:   the handlers

     - returns: true if there are operation available and react directly if not.
     */
    private func _operationsAreAvailable(operations: [Operation], handlers: Handlers) -> Bool {
        if operations.count > 0 {
            return true
        } else {
            let completion=Completion.successState()
            completion.message=NSLocalizedString("There was no pending operation", tableName:"operations", comment: "There was no pending operation")
            handlers.on(completion)
            return false
        }
    }



    /**
     Optimizes the operations
     */
    public func optimizeOperations() {
        self.optimizeOperations(self.operations.items)
    }

    /**
     Deletes, aggregates and generates operations to reduce the push and subscribe load.

     - parameter operations: the operations

     - returns: the reduced operations + a trigger
     */
    public func optimizeOperations(operations: [Operation]) -> [Operation] {
        /*
         var toBeDeleted=[Operation]()
         var groups=[String:[Operation]]()
         for operation in operations{

         }*/

        // TODO: @bpds Append a Trigger

        return operations
    }


}


// MARK: - Instance Distribution management

extension Registry {


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
