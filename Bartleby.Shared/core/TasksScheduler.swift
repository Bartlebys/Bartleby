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

 Child tasks are reputed "concurential".
 When its parent is completed the scheduler run all its direct children.
 According to the group context it can use paralelism via GCD

 TasksGroup can be paused.
 When you pause a group the running tasks are completed but the graph execution is interupted.

 The Task Scheduler performs locally
 That's why we use local reference "taskExternalReference.toLocalInstance()"
 If you need to taskGroupFor distant task you should grab the distant task (eg: ReadTaskById...)


 */
enum TasksSchedulerError: ErrorType {
    case DataSpaceNotFound
    case TaskGroupNotFound
    case TaskGroupUndefined
    case TaskIsNotInvocable
    case TaskNotFound(UID:String)
    case UnconsistentGroup
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
    func onAnyTaskCompletion(completedTask: Task) throws {
        if let groupExtRef=completedTask.group {
            if let group: TasksGroup = groupExtRef.toLocalInstance() {
                if group.status != .Paused {
                    // We gonna start all the children of the task.
                    for child in completedTask.children {
                        if let task: Task=child.toLocalInstance() {
                            if let invocableTask = task as? Invocable {
                                // Then invoke its invocable instance.
                                dispatch_async(group.dispatchQueue, {
                                    do {
                                        try invocableTask.invoke()
                                    } catch {
                                        if TasksScheduler.DEBUG_TASKS {
                                            bprint("\(error) on \(invocableTask.summary ?? invocableTask.UID)", file: #file, function: #function, line: #line)
                                        }
                                    }
                                })

                            } else {
                                task.complete(Completion.failureState("Not invocable", statusCode: CompletionStatus.Precondition_Failed))
                                throw TasksSchedulerError.TaskIsNotInvocable
                            }
                        } else {
                            throw TasksSchedulerError.TaskNotFound(UID: child.iUID)
                        }
                    }
                }
                let runnableTasksCount=group.runnableTaskCount()
                if runnableTasksCount==0 {
                    // We dispatch the completion of the group on the main Queue
                    dispatch_async(GlobalQueue.Main.get(), {
                        do {
                            try self._onGroupCompletion(group, lastCompletedTask:completedTask)
                        } catch {
                             bprint("\(error) on group completion \(group.UID)", file: #file, function: #function, line: #line)
                        }

                    })
                }
            } else {
                throw TasksSchedulerError.TaskGroupNotFound
            }
        } else {
            throw TasksSchedulerError.TaskGroupUndefined
        }
    }


    private func _onGroupCompletion(group: TasksGroup, lastCompletedTask: Task) throws {

        var hasInconsistencies=false
        let errorTasks=group.findTasks { (task) -> Bool in
                if let completed=task.completionState {
                    return completed.success==false
                } else {
                    hasInconsistencies=true
                }
                return false
        }
        if hasInconsistencies {
            throw TasksSchedulerError.UnconsistentGroup
        }


        let errorTasksCount=errorTasks.count
        if errorTasksCount==0 {
            // # Cleanup the tasks #

            if let registry=Bartleby.sharedInstance.getRegistryByUID(group.spaceUID) {
                if TasksScheduler.DEBUG_TASKS {
                    bprint("Deleting tasks of \(group.name)", file: #file, function: #function, line: #line)
                }
                for taskReference in group.tasks.reverse() {
                    if let task: Task=taskReference.toLocalInstance() {
                        let linearListOfSubTasks=task.linearTaskList.reverse()
                        for subtask in linearListOfSubTasks {
                            registry.delete(subtask)
                        }
                        registry.delete(task)
                    }

                }
            }


            group.tasks.removeAll()

            // Determine the completion state.
            // We use the last TASK
            group.completionState = Completion.successState("Task group \(group.name) has been completed",
                                                            statusCode:.OK,
                                                            data: lastCompletedTask.completionState?.data)
        } else {
            // We donnot cleanup the tasks
            group.completionState = Completion.successState("\(errorTasksCount) error(s)",
                                                            statusCode:.Expectation_Failed,
                                                            data: nil)
        }

        // We call the completion off the group.
        group.handlers.on(group.completionState!)

        // Then we Notify the group completion #
        if TasksScheduler.DEBUG_TASKS {
            bprint("Dispatching completion \(group.completionNotificationName)", file: #file, function: #function, line: #line)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(group.completionNotificationName, object: nil)

    }


    /**
     Resets all the task with Errors.

     - parameter group: the group to be reset
    */
    func resetAllTasksWithErrors(group: TasksGroup) {
        let errorTasks=group.findTasks { (task) -> Bool in
            if let completed=task.completionState {
                return completed.success == false
            } else {
                return false
            }
        }
        for task in errorTasks {
            task.completionState=nil
            task.status = .Runnable
            task.progressionState=nil
        }
    }



    /**
     Returns the queue for the group.


     - parameter group: the tasks group

     - returns: the queue
     */
    func getQueueFor(group: TasksGroup) -> dispatch_queue_t {
        switch group.priority {
        case .Background:
            return GlobalQueue.Background.get()
        case .Low:
            return GlobalQueue.Utility.get()
        case .Default:
            return GlobalQueue.UserInitiated.get()
        case .High:
            return GlobalQueue.UserInteractive.get()
        }

        /*

         let groupName=group.name
         let priority=group.priority

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
         */

    }



}
