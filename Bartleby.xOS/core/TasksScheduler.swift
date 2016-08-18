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
}


public class TasksScheduler: BprintCategorizable {

    // Task may be difficult to debug
    // So we expose a debug setting
    static public let DEBUG_TASKS=false

    static public let BPRINT_CATEGORY="TasksScheduler"

    //Storage
    private var _groups=Dictionary<String, TasksGroup>()

    // Dispatch Queues
    private var _queues=Dictionary<String, dispatch_queue_t>()

    // MARK: - Tasks Groups

    /**
     Return a group

     - parameter groupName:  its group name
     - parameter document:  the document

     - throws: DataSpace Not found

     - returns: the Task group
     */
    public func getTaskGroupWithName(groupName: String, inDocument document: BartlebyDocument) throws -> TasksGroup {
        let group=try self._taskGroupByName(groupName, inDocument: document)
        group.registryUID=document.UID
        return group
    }


    /**
     Returns a TaskGroup by its name.
     If necessary it creates the group

     - parameter groupName: the group name

     - returns: a task group
     */
    private func _taskGroupByName(groupName: String, inDocument document: BartlebyDocument) throws ->TasksGroup {
        let groupNameForDocument=groupName+"."+document.UID
        if let group=_groups[groupNameForDocument] {
            return group
        } else {
            if let groups: [TasksGroup]=document.tasksGroups.filter({(group) -> Bool in return group.name==groupNameForDocument}) {
                if groups.count>0 {
                    // Reallocate the document reference
                    groups.first!.document=document
                    _groups[groupNameForDocument]=groups.first!
                    return groups.first!
                }
                let group=TasksGroup()
                // Allocate the document reference
                group.document=document
                // Set up the group
                group.name=groupNameForDocument
                // We add the synchronization handlers on group creation
                group.handlers.appendChainedHandlers(document.synchronizationHandlers)
                _groups[groupName+document.UID]=group
                document.tasksGroups.add(group,commit: true)
                return group
            } else {
                throw TasksSchedulerError.TaskGroupNotFound
            }
        }
    }

    /**
     Returns a qualified infos string

     - parameter groupName: the name of the group
     - parameter document:  the document

     - returns: the informations on the current state of the group.
     */
    public func groupInfos(groupName: String, inDocument document: BartlebyDocument) -> String {
        do {
            let group = try getTaskGroupWithName(groupName, inDocument: document)
            return group.toString()
        } catch {
         return "Error while attempting to find \(groupName) in \(document.UID) \(error)"
        }
    }

    // MARK: - Task completion and Execution graph

    /**
     Called by a task on its completion.
     Executed on the main queue

     - parameter completedTask: the reference to the task
     */
    func onAnyTaskCompletion(completedTask: Task) {
        if let groupExtRef=completedTask.group {
            if let group: TasksGroup = groupExtRef.toLocalInstance() {
                if group.status != .Paused {
                    dispatch_async(group.dispatchQueue, {
                        // We gonna start all the children of the task.
                        for child in completedTask.children {
                            if let task: Task=child.toLocalInstance() {
                                if let invocableTask = task as? Invocable {
                                    invocableTask.invoke()
                                } else {
                                    let failureState=Completion.failureState("Task \(task.summary ?? task.UID) is not invocable", statusCode: StatusOfCompletion.Precondition_Failed)
                                    bprint(failureState, file: #file, function: #function, line: #line, category:TasksScheduler.BPRINT_CATEGORY)
                                    // Mark task completion
                                    task.complete(failureState)
                                    // Handle the failure
                                    group.handlers.on(failureState)
                                }
                            } else {
                                let failureState=Completion.failureState("External reference of Task \(child.summary ?? child.iUID) not found", statusCode: StatusOfCompletion.Precondition_Failed)
                                bprint(failureState, file: #file, function: #function, line: #line, category:TasksScheduler.BPRINT_CATEGORY)
                                group.handlers.on(failureState)
                            }
                        }
                    })
                }
                // We dispatch the completion of the group on the main Queue
                dispatch_async(GlobalQueue.Main.get(), {
                    let residualTasksCount=group.countTasks({ return $0.status == .Runnable ||  $0.status == .Running })
                    if residualTasksCount==0 {
                        self._onGroupCompletion(group, lastCompletedTask:completedTask)
                    }
                })

            } else {
                bprint("External reference of TaskGroup \(groupExtRef.summary ?? groupExtRef.iUID) not found", file: #file, function: #function, line: #line, category:TasksScheduler.BPRINT_CATEGORY)
            }
        } else {
            bprint("Task Group undefined in \(completedTask.summary ?? completedTask.UID)", file: #file, function: #function, line: #line, category:TasksScheduler.BPRINT_CATEGORY)
        }
    }


    private func _onGroupCompletion(group: TasksGroup, lastCompletedTask: Task) {

        var inconsistencyDetails=""
        let errorTasks=group.findTasks { (task) -> Bool in
            if let completed=task.completionState {
                // Include the task that are completed with failure
                return completed.success==false
            } else {
                // Mark the not completed tasks as anomalies
                inconsistencyDetails += "Not Completed "+(task.summary ?? task.UID)+"\n"
                return false
            }
        }

        let errorTasksCount=errorTasks.count
        if errorTasksCount==0 {
            // Relay success state
            group.completionState = Completion.successState("Task group \(group.name) has been completed",
                                                            statusCode:.OK,
                                                            data: nil)

            // Erase the tasks
            if let document=group.document {
                bprint("Deleting tasks of \(group.name)", file: #file, function: #function, line: #line, category:TasksScheduler.BPRINT_CATEGORY)
                for taskReference in group.tasks.reverse() {
                    if let task: Task=taskReference.toLocalInstance() {
                        let linearListOfSubTasks=task.linearTaskList.reverse()
                        for subtask in linearListOfSubTasks {
                            document.delete(subtask)
                        }
                        document.delete(task)
                    }
                }
            }


        } else {
            group.completionState = Completion.failureState("UnConsistent Tasks Group "+inconsistencyDetails, statusCode: StatusOfCompletion.Not_Acceptable)
        }

        if let completionState=group.completionState {
            // We call the completion off the group.
            group.handlers.on(completionState)
            // Notify the group completion #
            NSNotificationCenter.defaultCenter().postNotificationName(group.completionNotificationName, object: nil)
            bprint("Completion of Tasks Group \(group.name) \(completionState)", file: #file, function: #function, line: #line, category:TasksScheduler.BPRINT_CATEGORY)
            if completionState.success {
                // Then Clean up and auto delete the group
                self._cleanUpGroup(group)
            }
        }

    }


    /**
     We "cleanup" the handlers and reset the status.
     On Completion (successful or not).

     - parameter group: the Task Group
     */
    private func _cleanUpGroup(group: TasksGroup) {

        // Remove the group from the dictionnary
        _groups.removeValueForKey(group.name)

        // Explicit removal
        group.tasks.removeAll()
        group.status = .Paused
        group.handlers = Handlers.withoutCompletion()
        group.lastChainedTask=nil
        group.progressionState=nil
        group.completionState=nil

        // Remove the group from the registry.
        if let document=group.document {
            document.tasksGroups.removeObject(group, commit: true)
        }
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
    }

}


// MARK: Descriptible protocol

extension TasksScheduler:Descriptible {

    public func toString() -> String {
        var infos="\n# TasksScheduler\n"
        infos += "Number of Groups: \(_groups.count)\n"
        for (_, group) in _groups {
             infos += "## \(group.name) \n"
            infos += " Number of task: \(group.totalTaskCount()), \(group.progressionState ?? "" ), \(group.completionState ?? "" ) \n"
        }
        return infos
    }

}
