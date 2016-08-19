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
     Pushes an array of operations using a Group of chained PushOperationTasks

     - On successful completion the operation is deleted.
     - On total completion the tasks are deleted on global success.
     If an error as occured the task group is preserved for re-run or analysis.

     - parameter operations: operations description
     - parameter handlers:   the handlers to hook the completion / Progression
     */
    public func pushArrayOfOperations(operations: [Operation], handlers: Handlers?) throws->() {
        bprint("Pushing \(operations.count) Operations", file:#file, function:#function, line:#line, category:TasksScheduler.BPRINT_CATEGORY)
        if  operations.count>0 {

            // We use the encapsulated SpaceUID
            let UID=self.UID
            // We taskGroupFor the task
            let group=try Bartleby.scheduler.getTaskGroupWithName("Push_Operations\(UID)", inDocument: self)
            group.priority=TasksGroup.Priority.Background
            if let handlers=handlers{
                // We add the calling handlers
                group.handlers.appendChainedHandlers(handlers)
            }
            // #2 add the operations tasks.
            for operation in operations {
                let task=PushOperationTask(arguments:operation)
                try group.appendChainedTask(task)
            }

            //Add an automatic save document task.
            let saveTask=SaveDocumentTask(arguments:JString(from:self.UID))
            try group.appendChainedTask(saveTask)
            try group.start()

        } else {
            let completion=Completion.successState()
            completion.message=NSLocalizedString("There was no pending operation", tableName:"operations", comment: "There was no pending operation")
            handlers?.on(completion)
        }
    }

    /**
     Commits and Pushes the pending operations.
     The Command will optimize and inject commands if some changes has occured.

     - parameter handlers: the handlers to monitor the progress and completion

     - throws: throws
     */
    private func _commitAndPushPendingOperations()throws {

        // We ask the for taskGroup
        let group=try Bartleby.scheduler.getTaskGroupWithName("Push_Pending_Operations\(self.UID)", inDocument: self)
        group.priority=TasksGroup.Priority.Background

        // Commit the pending changes (if there are changes)
        try self.commitPendingChanges()

        // We donnot want to schedule anything if there is nothing to do.
        if self.operations.count > 0 {

            if group.tasks.count==0{
                // There is no root PushPendingOperationsTask tasks to the group
                // lets create this task.
                let registryUIDString=JString(from:self.UID)
                let pushPendingOperationsTask=PushPendingOperationsTask(arguments:registryUIDString)
                try group.appendChainedTask(pushPendingOperationsTask)
            }else{
                // There is already a PushPendingOperationsTask
                // So we will append chained task if necessary.
                if let pushPendingOperationsTask:PushPendingOperationsTask=group.tasks.first?.toLocalInstance(){
                    for operation in self.operations{
                        if !pushPendingOperationsTask.containsOperation(operation){
                            let task=PushOperationTask(arguments:operation)
                            try group.appendChainedTask(task)
                        }
                    }
                }
            }

            // Let's resume the group if it is paused
            if  group.status == .Paused{
                try group.start()
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



    /**
     Restarts the tasks Group
     */
    internal func _restartTasksGroups(){
        // Pause the taskGroup
        for taskGroup in self.tasksGroups{
            if taskGroup.totalTaskCount()>0{
                // We reset to Paused to force the restart
                taskGroup.status=TasksGroup.Status.Paused
                do {
                    bprint("Starting task Group \(taskGroup.UID)", file:#file, function:#function, line:#line)
                    try taskGroup.start()
                } catch let e {
                    bprint("Error while restarting taskGroup \(e)", file:#file, function:#function, line:#line)
                }
            }
        }

    }


    /**
     Restarts the tasks Group
     */
    internal func _pauseTasksGroups(){
        // Pause the taskGroup
        for taskGroup in self.tasksGroups{
            if taskGroup.totalTaskCount()>0{
                taskGroup.pause()
            }
        }
        
    }
    
    
    
}

