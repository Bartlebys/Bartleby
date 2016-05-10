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
}


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
            if let invocableTask = self.invocableTaskFrom(task) {
                if TasksScheduler.DEBUG_TASKS {
                    bprint("\(invocableTask.summary ?? invocableTask.UID ) task is invoked", file: #file, function: #function, line: #line)
                }
                dispatch_async(self.dispatchQueue, {
                    invocableTask.invoke()
                })

            } else {
                throw TasksGroupError.NonInvocableTask(task: task)
            }
        }
        return entryTasks.count
    }

    /**
     Extract a fully typed concrete task from an abstract task
     (!) Very important the Invocable task is a concrete Clone of the abstract Class.

     - parameter task: the transitionnal task

     - returns: an invocable task or nil
     */
    public func invocableTaskFrom(task: Task) -> ConcreteTask? {
        if task.taskClassName != Default.NO_NAME {
            // Serialize the current transitionnal task.
            let dictionary=task.dictionaryRepresentation()
            if let Reference: Collectible.Type = NSClassFromString(task.taskClassName) as? Collectible.Type {
                // deserialize using its concrete type
                if  var invocableTask = Reference.init() as? protocol<Mappable, ConcreteTask> {
                    let map=Map(mappingType: .FromJSON, JSONDictionary : dictionary)
                    invocableTask.mapping(map)
                    return invocableTask
                }
            }
        }
        return nil
    }


    /**
     Tasks are trans-serialized before invocation.
     This grabs the original task instance.
     Should be used to set the state or the status.

     - parameter taskInstance: the task Instance

     - returns: the original task
     */
    public func originalTaskFrom(taskInstance: Task) -> Task {
        let original: Task?=Registry.registredObjectByUID(taskInstance.UID)
        return original ?? taskInstance // Falls back on the current instance if nothing was found
    }


    /**
        Simple Pause
        When the group is paused on completion of a task we donnot run its childrens.
     */
    public func pause() {
        self.status = .Paused
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
