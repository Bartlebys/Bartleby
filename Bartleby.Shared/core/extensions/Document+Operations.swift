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
     Commits the pending changes.
     */
    public func commitPendingChanges() throws {
        try self.iterateOnCollections { (collection) in
            collection.commitChanges()
        }
    }

    /**
     Synchronizes the pending operations
     1. Proceeds to login
     3. Then pushes the pending operations

     - parameter handlers: the handlers to monitor the progress and completion
     */
    public func synchronizePendingOperations(handlers: Handlers) {
        if let currentUser=self.registryMetadata.currentUser {
            currentUser.login(withPassword: currentUser.password, sucessHandler: {
                do {
                    try self._commitAndPushPendingOperations(handlers)
                } catch {
                    handlers.on(Completion.failureState("Push operations has failed. Error: \(error)", statusCode: CompletionStatus.Expectation_Failed))
                }
                }, failureHandler: { (context) in
                    handlers.on(Completion.failureStateFromJHTTPResponse(context))
            })
        }

    }


    /**
     Pushes an array of operations using a Group of chained PushOperationTasks

     - On successful completion the operation is deleted.
     - On total completion the tasks are deleted on global success.
     If an error as occured the task group is preserved for re-run or analysis.

     - parameter operations: operations description
     - parameter handlers:   the handlers to hook the completion / Progression
     */
    public func pushArrayOfOperations(operations: [Operation], handlers: Handlers) throws->() {
        bprint("Pushing \(operations.count) Operations", file:#file, function:#function, line:#line, category:TasksScheduler.BPRINT_CATEGORY)
        if  operations.count>0 {

            // We use the encapsulated SpaceUID
            let spaceUID=self.spaceUID
            // We taskGroupFor the task
            let group=try Bartleby.scheduler.getTaskGroupWithName("Push_Operations\(spaceUID)", inDocument: self)
            group.priority=TasksGroup.Priority.High
            // We add the calling handlers
            group.handlers.appendChainedHandlers(handlers)

            // #2 add the operations tasks.
            for operation in operations {
                let task=PushOperationTask(arguments:operation)
                try group.appendChainedTask(task)
            }
            try group.start()
        } else {
            let completion=Completion.successState()
            completion.message=NSLocalizedString("There was no pending operation", tableName:"operations", comment: "There was no pending operation")
            handlers.on(completion)
        }
    }

    /**
     Commits and Pushes the pending operations.
     The Command will optimize and inject commands if some changes has occured.

     - parameter handlers: the handlers to monitor the progress and completion

     - throws: throws
     */
    private func _commitAndPushPendingOperations(handlers: Handlers)throws {
        // We use the encapsulated SpaceUID
        let spaceUID=self.spaceUID
        // We taskGroupFor the task
        let group=try Bartleby.scheduler.getTaskGroupWithName("Push_Pending_Operations\(spaceUID)", inDocument: self)
        group.priority=TasksGroup.Priority.High
        // We add the calling handlers
        group.handlers.appendChainedHandlers(handlers)

        // This task will append task
        let dataSpaceString: JString=JString()
        dataSpaceString.string=self.spaceUID
        let commitPendingOperationsTask=CommitAndPushPendingOperationsTask(arguments:dataSpaceString)
        try group.appendChainedTask(commitPendingOperationsTask)
        try group.start()
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
