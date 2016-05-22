//
//  Registry+Operations.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 05/05/2016.
//
//

import Foundation


extension BartlebyDocument {

    // MARK: - Operations

    /**
     Push the operation using PushOperationTask.

     - parameter operations: operations description
     - parameter handlers:   the handlers to hooks the completion / Progression
     */
    public func pushOperations(operations: [Operation], handlers: Handlers) throws->() {
        TasksScheduler.DEBUG_TASKS=true
        bprint("Pushing \(operations.count) Operations", file:#file, function:#function, line:#line)
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

    public func pushOperations(handlers: Handlers)throws {
        try self.pushOperations(self.operations.items, handlers:handlers)
    }


    public func synchronizeOperations(handlers: Handlers) {
        if let currentUser=self.registryMetadata.currentUser {
            currentUser.login(withPassword: currentUser.password, sucessHandler: {
                self.optimizeOperations()
                do {
                    try self.pushOperations(handlers)
                } catch {
                    handlers.on(Completion.failureState("Push operations has failed error: \(error)", statusCode: CompletionStatus.Expectation_Failed))
                }
                }, failureHandler: { (context) in
                    handlers.on(Completion.failureStateFromJHTTPResponse(context))
            })
        }
    }

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
