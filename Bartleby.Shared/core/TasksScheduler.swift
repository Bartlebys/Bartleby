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

/*

    The tasks Scheduler runs graph of task that can be

        - paused
        - serialized
        - and if the underlining logic permits, moved from a physical device to another

    Any child task is reputed concurential.
    When its parent is completed the scheduler run all its direct children.

    TasksGroup can be paused.
    When you pause a group the running tasks are completed but the graph execution is interupted.

    The Task Scheduler performs locally
    That's why we use local dealiasing "taskAlias.toLocalInstance()"
    If you need to createTaskGroupFor distant task you should grab the distant task (eg: ReadTaskById...)


*/
enum TasksSchedulerError: ErrorType {
    case DataSpaceNotFound
    case TaskGroupNotFound
}

@objc(TasksScheduler) public class TasksScheduler: NSObject {

    // Task may be difficult to debug
    // So we expose a debug setting
    static public var DEBUG_TASKS=false

    //Storage
    private var _groups=Dictionary<String, TasksGroup>()

    // MARK: - Tasks Groups

    /**
     Create a task Group, if the group already exists the root Task is appended to the other children.

     - parameter rootTask: the task to createTaskGroupFor.
     - parameter groupName:  its group name
     - parameter spaceUID:   the relevent DataSpace

     - throws: DataSpace Not found

     - returns: the Task group
     */
    public func createTaskGroupFor(rootTask: Task, groupedBy groupName: String, inDataSpace spaceUID: String) throws -> TasksGroup {
        let group=try self.taskGroupByName(groupName, inDataSpace: spaceUID)
        group.tasks.append(rootTask)
        group.priority=TasksGroup.Priority(rawValue:rootTask.priority.rawValue)!
        group.status=TasksGroup.Status(rawValue:rootTask.status.rawValue)!
        group.spaceUID=spaceUID
        let groupAlias: Alias<TasksGroup>=Alias(from:group)
        rootTask.group=groupAlias
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
    private func taskGroupByName(groupName: String, inDataSpace spaceUID: String) throws ->TasksGroup {
        if let group=_groups[groupName] {
            return group
        } else {
            if let document=Bartleby.sharedInstance.getRegistryByUID(spaceUID) as? BartlebyDocument {
                if let groups: [TasksGroup]=document.tasksGroups.filter({(group) -> Bool in return group.name==groupName}) {
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

    // MARK: - Task completion and Execution graph

    /**
     Called by a task on its completion.

     - parameter completedTask: the reference to the task
     */
    func onTaskCompletion(completedTask: Task) throws {
        if let aliasOfGroup=completedTask.group {
            if let group: TasksGroup = aliasOfGroup.toLocalInstance() {
                if group.status != .Paused {
                    // Group is Runnable
                    // We gonna start all the children of the task.
                    for child in completedTask.children {
                        if let task: Task=child.toLocalInstance() {
                            if let invocableTask = group.invocableTaskFrom(task) {
                                if TasksScheduler.DEBUG_TASKS {
                                    bprint("\(invocableTask.summary ?? invocableTask.UID )", file: #file, function: #function, line: #line)
                                }
                                task.status = .Running
                                invocableTask.invoke()
                            } else {
                                if TasksScheduler.DEBUG_TASKS {
                                    bprint("NonInvocableTask", file: #file, function: #function, line: #line)
                                }
                                throw TasksGroupError.NonInvocableTask(task: completedTask)
                            }
                        } else {
                            if TasksScheduler.DEBUG_TASKS {
                                bprint("TaskNotFound", file: #file, function: #function, line: #line)
                            }
                            throw TasksGroupError.TaskNotFound
                        }
                    }
                } else {
                    // Group is not Runnable
                }

                let runnableTasks = group.findRunnableTasks()
                if runnableTasks.count==0 {
                    // # Cleanup the task #
                    if let registry=Bartleby.sharedInstance.getRegistryByUID(group.spaceUID) {
                        for task in group.tasks.reverse() {
                            let linearListOfSubTasks=task.linearTaskList.reverse()
                            for subtask in linearListOfSubTasks {
                                if TasksScheduler.DEBUG_TASKS {
                                    bprint("Deleting \(subtask.summary ?? subtask.UID )", file: #file, function: #function, line: #line)
                                }
                                registry.delete(subtask)
                            }
                            group.tasks.removeLast()
                        }
                    }

                     // # Notify the group completion #
                    dispatch_async(dispatch_get_main_queue(), {
                        if TasksScheduler.DEBUG_TASKS {
                            bprint("Dispatching \(group.completionNotificationName)", file: #file, function: #function, line: #line)
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName(group.completionNotificationName, object: nil)
                    })
                } else {
                    if TasksScheduler.DEBUG_TASKS {
                        bprint("Still \(runnableTasks.count) task(s) to run", file: #file, function: #function, line: #line)
                    }
                }

            } else {
                if TasksScheduler.DEBUG_TASKS {
                    bprint("ERROR: local task group instance not found \(completedTask.summary ?? completedTask.UID )", file: #file, function: #function, line: #line)
                }
            }
        } else {
            if TasksScheduler.DEBUG_TASKS {
                bprint("ERROR: no alias group found in \(completedTask.summary ?? completedTask.UID )", file: #file, function: #function, line: #line)
            }
        }
    }
}
