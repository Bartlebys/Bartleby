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
    If you need to taskGroupFor distant task you should grab the distant task (eg: ReadTaskById...)


*/
enum TasksSchedulerError: ErrorType {
    case DataSpaceNotFound
    case TaskGroupNotFound
}

public class TasksScheduler {

    // Task may be difficult to debug
    // So we expose a debug setting
    static public var DEBUG_TASKS=false

    //Storage
    private var _groups=Dictionary<String, TasksGroup>()

    // Dispatch Queues
    private var _queues=Dictionary<String, dispatch_queue_t>()

    // MARK: - Tasks Groups

    /**
    Return a group

     - parameter groupName:  its group name
     - parameter spaceUID:   the relevent DataSpace

     - throws: DataSpace Not found

     - returns: the Task group
     */
    public func getTaskGroupWithName(groupName: String, inDataSpace spaceUID: String) throws -> TasksGroup {
        let group=try self._taskGroupByName(groupName, inDataSpace: spaceUID)
        group.spaceUID=spaceUID
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
    private func _taskGroupByName(groupName: String, inDataSpace spaceUID: String) throws ->TasksGroup {
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
     Executed on the main queue

     - parameter completedTask: the reference to the task
     */
    func onTaskCompletion(completedTask: Task) throws {
        if let aliasOfGroup=completedTask.group {
            if let group: TasksGroup = aliasOfGroup.toLocalInstance() {

                // Post invocation handler
                func __postInvocation(lastCompletedTask: Task) {
                    let runnableTasks = group.findRunnableTasks()
                    if runnableTasks.count==0 {
                        // # Cleanup the tasks #
                        if let registry=Bartleby.sharedInstance.getRegistryByUID(group.spaceUID) {
                            for task in group.tasks.reverse() {
                                let linearListOfSubTasks=task.linearTaskList.reverse()
                                for subtask in linearListOfSubTasks {
                                    if TasksScheduler.DEBUG_TASKS {
                                        bprint("Deleting \(subtask.summary ?? subtask.UID )", file: #file, function: #function, line: #line)
                                    }
                                    registry.delete(subtask)
                                }
                                registry.delete(task)
                            }
                        }
                        group.tasks.removeAll()

                        // Determine the completion state.
                        // We use the last TASK
                        group.completionState = Completion.successState("Task group \(group.name) has been completed",
                                                                        statusCode:.OK,
                                                                        data: lastCompletedTask.completionState.data)
                        
                        // We call the completion off the group.
                        group.handlers.on(group.completionState)

                        // Then we Notify the group completion #
                        if TasksScheduler.DEBUG_TASKS {
                            bprint("Dispatching completion \(group.completionNotificationName)", file: #file, function: #function, line: #line)
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName(group.completionNotificationName, object: nil)
                    } else {
                        if TasksScheduler.DEBUG_TASKS {
                            bprint("Still \(runnableTasks.count) task(s) to run", file: #file, function: #function, line: #line)
                        }
                    }
                }

                // If there is a failure task let's invoke this task
                if completedTask.completionState.success==false {
                    if let onFailureAlias=group.onFailure {
                        if let onFailureTask=onFailureAlias.toLocalInstance() {
                            if let onFailureTask = onFailureTask as? Invocable {
                                // We run the failure task on the main queue
                                dispatch_async(dispatch_get_main_queue(), {
                                    onFailureTask.invoke()
                                    __postInvocation(completedTask)
                                })
                            } else {
                                throw TasksGroupError.InterruptedOnFault
                            }
                        } else {
                             throw TasksGroupError.InterruptedOnFault
                        }
                    } else {
                         throw TasksGroupError.InterruptedOnFault
                    }
                } else {

                    // It is a success
                    if group.status != .Paused {
                        // Group is Runnable
                        // We gonna start all the children of the task.
                        for child in completedTask.children {
                            if let task: Task=child.toLocalInstance() {
                                if let invocableTask = task as? Invocable {
                                    if TasksScheduler.DEBUG_TASKS {
                                        bprint("\(invocableTask.summary ?? invocableTask.UID )", file: #file, function: #function, line: #line)
                                    }
                                    task.status = .Running
                                    dispatch_async(group.dispatchQueue, {
                                        // Then invoke its invocable instance.
                                        invocableTask.invoke()
                                        __postInvocation(completedTask)
                                    })
                                } else {
                                    __postInvocation(completedTask)
                                    if TasksScheduler.DEBUG_TASKS {
                                        bprint("NonInvocableTask", file: #file, function: #function, line: #line)
                                    }
                                    throw TasksGroupError.NonInvocableTask(task: completedTask)
                                }
                            } else {
                                __postInvocation(completedTask)
                                if TasksScheduler.DEBUG_TASKS {
                                    bprint("TaskNotFound", file: #file, function: #function, line: #line)
                                }
                                throw TasksGroupError.TaskNotFound
                            }
                        }
                    } else {
                        // Group is not Runnable
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


    /**
     Returns the queue for the group.

     - parameter group: the tasks group

     - returns: the queue
     */
    func getQueueFor(group: TasksGroup) -> dispatch_queue_t {

        let groupName=group.name
        let priority=group.priority

       /**
        *  - DISPATCH_QUEUE_PRIORITY_HIGH:         QOS_CLASS_USER_INITIATED
        *  - DISPATCH_QUEUE_PRIORITY_DEFAULT:      QOS_CLASS_DEFAULT
        *  - DISPATCH_QUEUE_PRIORITY_LOW:          QOS_CLASS_UTILITY
        *  - DISPATCH_QUEUE_PRIORITY_BACKGROUND:   QOS_CLASS_BACKGROUND
        */
        let queueName="org.bartlebys.\(groupName)_\(priority)"
        if let queue: dispatch_queue_t=_queues[queueName] {
            return queue
        }

        // Create the queue if necessary
        if #available(OSX 10.10, *) {
            var qos: qos_class_t=QOS_CLASS_DEFAULT
            switch group.priority {
            case .Background:
                qos=QOS_CLASS_BACKGROUND
            case .Low:
                qos=QOS_CLASS_UTILITY
            case .Default:
                qos=QOS_CLASS_DEFAULT
            case .High:
                qos=QOS_CLASS_USER_INITIATED
            }

            let attr: dispatch_queue_attr_t = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, qos, 0)
            let queue: dispatch_queue_t = dispatch_queue_create(queueName, attr)
            _queues[queueName]=queue
            return queue
        } else {
            // Fallback on earlier versions
            // TODO @bpds older approach ? + IOS?
            return dispatch_get_main_queue()
        }

    }



}
