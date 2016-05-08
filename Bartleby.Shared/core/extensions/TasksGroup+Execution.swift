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

    // The completion Notification osbervable
    // NSNotificationCenter.defaultCenter()
    public var completionNotificationName: String {
        get {
            return self.name+"_NOTIFICATION"
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
            if let invocableTask = self.invocableTaskFrom(task) {
                if TasksScheduler.DEBUG_TASKS {
                    bprint("\(invocableTask.summary ?? invocableTask.UID ) task is invoked", file: #file, function: #function, line: #line)
                }
                invocableTask.invoke()
            } else {
                throw TasksGroupError.NonInvocableTask(task: task)
            }
        }
        return entryTasks.count
    }

    /**
     Extract a fully typed concrete task from a

     - parameter task: the transitionnal task

     - returns: an invocable task or nil
     */
    public func invocableTaskFrom(task: Task) -> ConcreteTask? {
        if task.taskClassName != Default.NO_NAME {
            // serialize the current transitionnal task.
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
            self._findRunnableTasks(task, tasks:&tasks)
        }
        return tasks
    }


    private func _findRunnableTasks(task: Task, inout tasks: [Task]) {
        for alias in task.children {
            if let task: Task=alias.toLocalInstance() {
                if ( task.status != .Completed ) && (task.status != .Running) {
                    tasks.append(task)
                } else {
                    // We search recursively tasks
                    // Only if there are not runnable task at previous levels
                    self._findRunnableTasks(task, tasks:&tasks)
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
            self._findTasksWithStatus(task, status:status, tasks:&tasks)
        }
        return tasks
    }

    private func _findTasksWithStatus(task: Task, status: Task.Status, inout tasks: [Task]) {
        for alias in task.children {
            if let task: Task=alias.toLocalInstance() {
                if task.status == status {
                    tasks.append(task)
                }
                self._findTasksWithStatus(task, status:status, tasks:&tasks)
            }
        }
    }

}
