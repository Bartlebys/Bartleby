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
        TasksScheduler.DEBUG_TASKS=true
        if operations.count==0 {
            handlers.on(Completion.successState())
        } else {
            // We use the encapsulated SpaceUID
            let spaceUID=operations.first!.spaceUID

            // ??? L'ORDRE D'AJOUT EST INCIDENT
            // BPDS Implementer une Progression cohérente.
            // le task Group devrait connaitre son nombre total de tâche + le nb completé couramment.
            // A chaque completion de task il devrait mettre à jour

            // Create the root Task.
            let firstOperationTask=PushOperationTask(arguments: operations.first!)

            // We taskGroupFor the task
            let group=try Bartleby.scheduler.getTaskGroupWithName("Push_Operations\(spaceUID)", inDataSpace: spaceUID)
            try group.addTask(firstOperationTask)

            // We add the calling handlers
            group.handlers.appendChainedHandlers(handlers)

            for operation in operations {
                let task=PushOperationTask(arguments:operation)
                try group.appendChainedTask(task)
            }
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
