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
    case TaskNotFound
    case GroupNotFound
    case AttemptToAddTaskInMultipleGroups
    case InterruptedOnFault
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

    /**
     Starts the task group

     - throws: Error on Non Invocable task

     - returns: the number of entry tasks if >1 there is something to do.
     */
    public func start() throws -> Int {
        self.status = .Runnable
        // The graph may be partially executed.
        // We search the entry tasks.
        let entryTasks=self.findRunnableTasks()

        for task in entryTasks {
            task.status = .Running // There was no trans serialization we can set directly the status.
            if let invocableTask = task as? Invocable {
                if TasksScheduler.DEBUG_TASKS {
                    bprint("\(invocableTask.summary ?? invocableTask.UID ) task is invoked", file: #file, function: #function, line: #line)
                }
                 dispatch_sync(self.dispatchQueue, {
                    invocableTask.invoke()
                })

            } else {
                throw TasksGroupError.NonInvocableTask(task: task)
            }
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
     Add a top level concurrent task to the group.
     And registers the group alias

     - parameter task:  the top level task to be added
     - parameter group: the group
     */
    public func addConcurrentTask(task: Task) throws {
        if let _ = task.group {
            throw TasksGroupError.AttemptToAddTaskInMultipleGroups
        }
        task.group=Alias(from:self)
        self.tasks.append(task)
    }


    /**
     The total count at a given time

     - returns: the number of tasks
     */
    public func totalTaskCount() -> Int {
        var counter: Int=0
        for task in self.tasks {
            self._count(task, counter:&counter)
        }
        return counter
    }


    private func _count(task: Task, inout counter: Int) {
        counter += 1
        for alias in task.children {
            if let child: Task=alias.toLocalInstance() {
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
        for task in self.tasks {
            self._runnableCount(task, counter:&counter)
        }
        return counter
    }


    private func _runnableCount(task: Task, inout counter: Int) {
        if ( task.status != .Completed ) && (task.status != .Running) {
           counter += 1
        }
        for alias in task.children {
            if let child: Task=alias.toLocalInstance() {
                self._runnableCount(child, counter: &counter)
            }
        }
    }


    /**
     - returns: the rank of a given task and -1 if not found.
     */
    public func rankOfTask(task: Task) -> Int {
        var rankCounter: Int = -1
        var stop: Bool=false
        for task in self.tasks {
            self._rankOfTask(task, rankCounter:&rankCounter, stop:&stop)
        }
        return rankCounter
    }

    private func _rankOfTask(task: Task, inout rankCounter: Int, inout stop: Bool) {
        if stop==false {
            rankCounter += 1
            for alias in task.children {
                if let _: Task=alias.toLocalInstance() {
                    stop=true
                }
            }
        }
    }



    // MARK: Find runnable Tasks

    /**
     Determines the bunch of task to use to start or resume a TaskGroup.
     The entry tasks may be deeply nested if the graph has already been partially running

     - returns: a collection of tasks
     */
    public func findRunnableTasks() -> [Task] {
        var tasks=[Task]()
        for task in self.tasks {
            self._findRunnableTasksFrom(task, tasks:&tasks)
        }
        return tasks
    }


    private func _findRunnableTasksFrom(task: Task, inout tasks: [Task]) {
        if ( task.status != .Completed ) && (task.status != .Running) {
            tasks.append(task)
            return
        }
        for alias in task.children {
            if let child: Task=alias.toLocalInstance() {
                if ( child.status != .Completed ) && (child.status != .Running) {
                    tasks.append(child)
                } else {
                    // We search recursively tasks
                    // Only if there are not runnable task at previous levels
                    self._findRunnableTasksFrom(child, tasks:&tasks)
                }
            }
        }
    }


    // MARK: Find tasks with status

    /**
     Returns a filtered list of task.

     - parameter status: the status

     - returns: the list of tasks
     */
    public func findTasksWithStatus(status: Task.Status) -> [Task] {
        var tasks=[Task]()
        for task in self.tasks {
            self._findTasksWithStatusFrom(task, status:status, tasks:&tasks)
        }
        return tasks
    }

    private func _findTasksWithStatusFrom(task: Task, status: Task.Status, inout tasks: [Task]) {
        if ( task.status != .Completed ) && (task.status != .Running) {
            tasks.append(task)
        }
        for alias in task.children {
            if let child: Task=alias.toLocalInstance() {
                if child.status == status {
                    tasks.append(child)
                }
                self._findTasksWithStatusFrom(child, status:status, tasks:&tasks)
            }
        }
    }

}
