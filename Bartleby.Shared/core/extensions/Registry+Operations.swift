//
//  Registry+Operations.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 05/05/2016.
//
//

import Foundation


extension Registry {

    // MARK: - Operations

    /**
     Push the operation using PushOperationTask.

     - parameter operations: operations description
     - parameter handlers:   the handlers to hooks the completion / Progression
     */
    public func pushOperations(operations: [Operation], handlers: Handlers) throws->() {
        if operations.count==0 {
            handlers.on(Completion.successState())
        } else {
            // We use the encapsulated SpaceUID
            let spaceUID=operations.first!.spaceUID
            // Create the root Task.
            let firstOperationTask=PushOperationTask(arguments: operations.first!)
            // Hook the task reactive handlers
            firstOperationTask.reactiveHandlers.appendCompletionHandler(handlers.on)
            firstOperationTask.reactiveHandlers.appendProgressHandler(handlers.notify)
            if operations.count>1 {
                // We iterate on the next task.
                for i in 1...operations.count-1 {
                    // And append the operation task sequentially
                    try firstOperationTask.appendSequentialTask(PushOperationTask(arguments: operations[i]))
                }
            }
            // We createTaskGroupFor the task
            let group=try Bartleby.scheduler.createTaskGroupFor(firstOperationTask, groupedBy: "Push_Operations\(spaceUID)", inDataSpace: spaceUID)
            try group.start()
        }
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
