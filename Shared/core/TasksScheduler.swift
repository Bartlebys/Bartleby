//
//  TasksScheduler.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 19/04/2016.
//
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif


// MARK: - TasksScheduler

enum TasksSchedulerError: ErrorType {
    case DataSpaceNotFound
    case TaskGroupNotFound
}

@objc(TasksScheduler) public class TasksScheduler: NSObject {

    //Storage
    private var _groups=Dictionary<String, TasksGroup>()

    /**
     Provision a task in a given Group.

     - parameter parentTask: the task to provision.
     - parameter groupName:  its group name
     - parameter spaceUID:   the relevent DataSpace

     - throws: DataSpace Not found

     - returns: the Task group
     */
    public func provision(rootTask: Task, groupedBy groupName: String, inDataSpace spaceUID: String) throws -> TasksGroup {
        let group=try self.taskGroupByName(groupName, inDataSpace: spaceUID)
        group.tasks.append(rootTask)
        group.priority=TasksGroup.Priority(rawValue:rootTask.priority.rawValue)!
        group.status=TasksGroup.Status(rawValue:rootTask.status.rawValue)!
        rootTask.group=Registry.instanceToAlias(group)
        if let document=Bartleby.sharedInstance.getRegistryByUID(spaceUID) as? BartlebyDocument {
            document.tasksGroups.add(group)
        } else {
            throw TasksSchedulerError.DataSpaceNotFound
        }
        return group
    }


    /**
     Returns a TaskGroup by its name.
     If necessary it creates the group

     - parameter groupName: the group name

     - returns: a task group
     */
    public func taskGroupByName(groupName: String, inDataSpace spaceUID: String) throws ->TasksGroup {
        if let group=_groups[groupName] {
            return group
        } else {
            if let document=Bartleby.sharedInstance.getRegistryByUID(spaceUID) as? BartlebyDocument {

                if let groups: [TasksGroup]=document.tasksGroups.filter({ (group) -> Bool in
                    return group.name==groupName}) {

                    if groups.count>0 {
                        _groups[groups.first!.name]=groups.first!
                        return groups.first!
                    }

                    let group=TasksGroup()
                    group.name=groupName
                    _groups[groupName]=group
                    return group

                } else {
                    throw TasksSchedulerError.DataSpaceNotFound
                }
            }
        }
         throw TasksSchedulerError.TaskGroupNotFound
    }


    /**
     Called by a task on its completion.

     - parameter completedTask: the reference to the task
     */
    func onCompletion(completedTask: Task) throws {
        if let aliasOfGroup=completedTask.group {
            if let group: TasksGroup=Registry.aliasToLocalInstance(aliasOfGroup) {
                if group.status != .Paused && group.status != .Completed {
                    for child in completedTask.children {
                        if let task = group.invocableTaskFrom(child) {
                            task.invoke()
                        } else {
                            throw TasksGroupError.NonInvocableTask(task: completedTask)
                        }
                        child.status = .Running
                    }
                } else {
                    // Paused or Completed
                }
                // Mark the group as completed if there is no more
                // Runnable tasks
                let runnableTasks = group.findRunnableTasks()
                if runnableTasks.count==0 {
                    group.status = .Completed
                    dispatch_async(dispatch_get_main_queue(), {
                         NSNotificationCenter.defaultCenter().postNotificationName(group.completionNotificationName, object: nil)
                    })

                }
            }

        }

    }


}


// MARK: - TasksGroup Extension

enum TasksGroupError: ErrorType {
    case NonInvocableTask(task:Task)
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
        let entryTasks=self.findRunnableTasks()
        for task in entryTasks {
            if let invocableTask = self.invocableTaskFrom(task) {
                invocableTask.invoke()
            } else {
                throw TasksGroupError.NonInvocableTask(task: task)
            }
        }
        return entryTasks.count
    }

    // TODO @bpds securize in Tasks => (!) Used to force the transitionnal casting

    /**
     Extract a fully typed concrete task from a

     - parameter task: the transitionnal task

     - returns: an invocable task or nil
     */
    public func invocableTaskFrom(task: Task) -> Invocable? {
        if task.taskClassName != Default.NO_NAME {
            // serialize the current transitionnal task.
            let dictionary=task.dictionaryRepresentation()
            if let Reference: Collectible.Type = NSClassFromString(task.taskClassName) as? Collectible.Type {
                // deserialize using its concrete type
                if  var mappable = Reference.init() as? Mappable {
                    let map=Map(mappingType: .FromJSON, JSONDictionary : dictionary)
                    mappable.mapping(map)
                    if let invocable = mappable as? Invocable {
                        return invocable
                    }
                }
            }
        }
        return nil
    }


    /**
     All the running tasks will be finished
     But not their children tasks.
     */
    public func pause() {
        // Mark the group as completed if there is no more
        // Runnable tasks
        let runnableTasks = self.findRunnableTasks()
        if runnableTasks.count==0 {
            self.status = .Completed
        } else {
            self.status = .Paused
        }
    }



    // MARK: Find runnable Tasks

    /**
     Determines the bunch of task to use to start or resume a TaskGroup.
     The entry tasks may be deeply nested if the graph has already been partially running

     - returns: a collection of tasks
     */
    public func findRunnableTasks() -> [Task] {
        //Top level of the graph.
        var topLevelTasks=[Task]()
        for task in self.tasks {
            if task.status != Task.Status.Completed {
                if task.taskClassName==Default.NO_NAME {
                    //TODO @bpds
                    bprint("ERROR to be fixed in next implementation", file: #file, function: #function, line: #line)
                } else {
                   topLevelTasks.append(task)
                }

            }
        }
        if topLevelTasks.count==0 {
            for task in self.tasks {
                self._findTasksUnCompletedSubTask(task, topLevelTasks: &topLevelTasks)
            }
        }
        return topLevelTasks
    }


    private func _findTasksUnCompletedSubTask(task: Task, inout topLevelTasks: [Task]) {
        if topLevelTasks.count==0 {
            for childTask in task.children {
                if childTask.status != Task.Status.Completed {
                    if childTask.taskClassName==Default.NO_NAME {
                        bprint("ERROR to be fixed in next implementation", file: #file, function: #function, line: #line)
                    } else {
                        topLevelTasks.append(childTask)
                    }
                }
            }
            if topLevelTasks.count==0 {
                for task in task.children {
                    self._findTasksUnCompletedSubTask(task, topLevelTasks: &topLevelTasks)
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
        var matching=[Task]()
        let rootTasks=self.tasks.filter { (task) -> Bool in
            return task.status==status
        }
        matching.appendContentsOf(rootTasks)
        for task in self.tasks {
            self._findChildrenTasksWithStatus(task, status:status, tasks:&matching)
        }
        return matching
    }


    private func _findChildrenTasksWithStatus(task: Task, status: Task.Status, inout tasks: [Task]) {
        var matching=[Task]()
        let matchingChildren=task.children.filter { (subTask) -> Bool in
            return subTask.status==status
        }
        matching.appendContentsOf(matchingChildren)
    }

}
