//
//  TasksGroup+Execution.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 08/05/2016.
//
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import Alamofire
    import ObjectMapper
#endif


// MARK: - TasksGroup Extension

enum TasksGroupError: ErrorType {
    case NonInvocableTask(task:Task)
    case GroupNotFound
    case AttemptToAddTaskInMultipleGroups
    case MultipleAttemptToAddTask
    case InterruptedOnFault
    case MissingExternalReference
    case TaskGroupDataSpaceNotFound(spaceUID:String)
}

/*

 TaskGroup ?


 How to monitor the taskGroup ?

 1. You can add the handlers
 ```
 group.handlers.appendCompletionHandler(handlers.on)
 group.handlers.appendProgressHandler(handlers.notify)
 ```
 2. or with with one expression
 ```
 group.handlers.appendChainedHandlers(handlers)
 ```
 3. Observe the task Group completion and Progression by NSNotification.
 ```
 NSNotificationCenter.defaultCenter().addObserverForName(group.completionNotificationName, object: nil, queue: nil, usingBlock: { (notification) in
 //
 })
 // Observe the task Group completion
 NSNotificationCenter.defaultCenter().addObserverForName(group.progressionNotificationName, object: nil, queue: nil, usingBlock: { (notification) in
 //
 })
 ```
 */

public extension TasksGroup {


    @available(OSX 10.9, *)
    public var dispatchQueue: dispatch_queue_t {
        get {
            return Bartleby.scheduler.getQueueFor(self)
        }
    }

    // The completion Notification osbervable
    // NSNotificationCenter.defaultCenter()
    public var completionNotificationName: String {
        get {
            return self.name+"_COMPLETION_NOTIFICATION"
        }
    }


    // The completion Notification osbervable
    // NSNotificationCenter.defaultCenter()
    public var progressionNotificationName: String {
        get {
            return self.name+"_PROGRESSION_NOTIFICATION"
        }
    }

    // MARK: Main API

    /**
     Starts the task group

     - throws: Error on Non Invocable task

     - returns: the number of entry tasks if >1 there is something to do.
     */
    public func start() throws -> Int {
        // The graph may be partially executed.
        // We search the entry tasks.
        let entryTasks=self.runnableTasks()
        bprint("Starting group \(self.name) \(entryTasks.count) entry task(s)", file: #file, function: #function, line: #line,category:TasksScheduler.BPRINT_CATEGORY)
        if self.status != .Running {
            // We donnot want to re-run an already running group.
            self.status = .Running
            // We start and run the task Code not on the main dispatch Queue
            // We will roll back to the MainQueue on taskGroup Completion.
            dispatch_async(self.dispatchQueue, {
                // We dispatch sync on the dispatch queue to be able to dispatch exceptions
                for task in entryTasks {
                    if let invocableTask = task as? Invocable {
                        invocableTask.invoke()
                    } else {
                        dispatch_async(GlobalQueue.Main.get(), {
                            task.complete(Completion.failureState("Not invocable", statusCode: CompletionStatus.Precondition_Failed))
                        })
                    }
                }
            })

        }
        return entryTasks.count
    }



    /**
     Simple Pause
     When the group is paused on completion of a task we donnot run its childrens.
     */
    public func pause() {
        self.status = .Paused
    }



    /**
     Add top level concurrent task or a child task to the group.
     And registers the group

     - parameter task:  the top level task to be added
     - parameter group: the group
     */
    public func addTask(task: Task) throws {

        try self._insurePersistencyOfTask(task)
        
        if let _ = task.group {
            throw TasksGroupError.AttemptToAddTaskInMultipleGroups
        }
        task.group=ExternalReference(from:self)

        if self.tasks.filter({$0.iUID==task.UID}).count>0 {
            throw TasksGroupError.MultipleAttemptToAddTask
        }
        // Add the task to the root tasks.
        self.tasks.append(ExternalReference(from:task))
        if TasksScheduler.DEBUG_TASKS {
            let s = task.summary ?? task.UID
            let t = self.summary ?? self.UID
            let g = task.group?.iUID ?? Default.NO_GROUP
            bprint("Adding Grouped \(s) to \(t) in \(g)", file: #file, function: #function, line: #line,category:TasksScheduler.BPRINT_CATEGORY)
        }

    }

    /**
     Appends a task to the last task

     - parameter task: the task to be sequentially added
     */
    public func appendChainedTask(task: Task) throws {
        defer {
            self.lastChainedTask=ExternalReference(from: task)
            task.group=ExternalReference(from: self)
        }
        try self._insurePersistencyOfTask(task)
        if self.lastChainedTask == nil {
            if let lastTaskRef=self.tasks.last {
                if let lastTask: Task=lastTaskRef.toLocalInstance() {
                     try lastTask.addChildren(task)
                } else {
                     throw TasksGroupError.MissingExternalReference
                }
            } else {
                try self.addTask(task)
            }
        } else if let lastTask: Task=self.lastChainedTask!.toLocalInstance() {
            try lastTask.addChildren(task)
        } else {
            if let registry=Bartleby.sharedInstance.getRegistryByUID(self.spaceUID) {
                let tasksCollection: TasksCollectionController = try registry.getCollection()
                print(tasksCollection.items.count)
            }
            throw TasksGroupError.TaskGroupDataSpaceNotFound(spaceUID: self.spaceUID)
        }
    }

    // MARK: - Counters

    // !!! REMPLACER LES PROCESSUS EXPLORATOIRES PAR DES COMPTEURS UNE FOIS LE CODE STABILISÉ
    // totalTaskCount() - EXPLORER LES TASK À L'AJOUT ET INCRÉMENTER LES COMPETEUR
    // PAREIL POUR runnableTaskCount()
    // UTILISER EVENTUELLEMENT UN FLATMAP POUR optimiser les appels.

    /**
     The total count at a given time

     - returns: the number of tasks
     */
    public func totalTaskCount() -> Int {
        var counter: Int=0
        for taskRef in self.tasks {
            if let task: Task=taskRef.toLocalInstance() {
                self._count(task, counter:&counter)
            }
        }
        return counter
    }


    private func _count(task: Task, inout counter: Int) {
        counter += 1
        for ref in task.children {
            if let child: Task=ref.toLocalInstance() {
                self._count(child, counter: &counter)
            }
        }
    }



    /**
     The total count at a given time

     - returns: the number of tasks
     */
    public func runnableTaskCount() -> Int {
        var counter: Int=0
        for taskRef in self.tasks {
            if let task: Task=taskRef.toLocalInstance() {
                 self._runnableCount(task, counter:&counter)
            }
        }
        return counter
    }


    private func _runnableCount(task: Task, inout counter: Int) {
        if ( task.status == .Runnable) {
            counter += 1
        }
        for ref in task.children {
            if let child: Task=ref.toLocalInstance() {
                self._runnableCount(child, counter: &counter)
            }
        }
    }


    // MARK: Ranking

    // MARK: Find runnable Tasks

    /**
     Determines the bunch of task to use to start or resume a TaskGroup.
     The entry tasks may be deeply nested if the graph has already been partially running

     - returns: a collection of tasks
     */
    public func runnableTasks() -> [Task] {
        var tasks=[Task]()
        for taskRef in self.tasks {
            if let task: Task=taskRef.toLocalInstance() {
                self._runnableTasksFrom(task, tasks:&tasks)
            }
        }
        return tasks
    }


    private func _runnableTasksFrom(task: Task, inout tasks: [Task]) {
        if (task.status != .Running && task.completionState == nil) {
            tasks.append(task)
            return
        }
        // There is no task at this level of the task Graph.
        // Let's explore the next level (children references)
        for ref in task.children {
            if let child: Task=ref.toLocalInstance() {
                if (child.status != .Running && task.completionState == nil) {
                    tasks.append(child)
                } else {
                    // We search recursively tasks
                    // Only if there are not runnable task at previous levels
                    self._runnableTasksFrom(child, tasks:&tasks)
                }
            }
        }
    }



    //MARK : find Tasks

    /**
     General purpose task Extractor

     - parameter matching: filter

     - returns: an array of tasks.
     */
    public func findTasks(@noescape matching:(task: Task) -> Bool) -> [Task] {
        var tasks=[Task]()
        for taskRef in self.tasks {
            if let task: Task=taskRef.toLocalInstance() {
                self._findTasks(task, matching: matching, tasks:&tasks)
            }
        }
        return tasks
    }

    private func _findTasks(task: Task, @noescape matching:(task: Task) -> Bool, inout tasks: [Task]) {
        if matching(task: task) {
            tasks.append(task)
        }
        for taskRef in task.children {
            if let child: Task=taskRef.toLocalInstance() {
                if matching(task: child) {
                    tasks.append(child)
                }
                self._findTasks(child, matching:matching, tasks:&tasks)
            }
        }
    }

    /**
     Adds the task to the relevant collection.

     - parameter task: the task

     - throws: TaskCollectionControllerNotFound can occur if the DataSpace is available locally
     */
    private func _insurePersistencyOfTask(task: Task) throws {
        if let registry=Bartleby.sharedInstance.getRegistryByUID(self.spaceUID) {
            // Identify the task Creator.
            task.creatorUID=registry.currentUser.UID
            // Add the taksk to the peristent tasks.
            let persitentTasks: TasksCollectionController = try registry.getCollection()
            persitentTasks.add(task)

        } else {
            throw TasksGroupError.TaskGroupDataSpaceNotFound(spaceUID:self.spaceUID)
        }
    }



}
