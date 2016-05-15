//
//  Task+Arguments.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/04/2016.
//
//

import Foundation

/**
 The tasks errors

 - ArgumentsTypeMisMatch: There is a problem with the Arguments casting
 - NoArgument:            There is no argument.
 */
public enum TaskError: ErrorType {
    case ArgumentsTypeMisMatch
    case NoArgument
}


// MARK: - Serializable Arguments


extension Task:SerializableArguments {

    /**
     - throws: Error on deserialization and type missmatch

     - returns: A collectible object
     */
    public final func arguments<ArgumentType: Collectible>() throws -> ArgumentType {
        if let argumentsData = self.argumentsData {
            let deserialized=try JSerializer.deserialize(argumentsData)
            if let arguments = deserialized as? ArgumentType {
                return arguments
            } else {
                throw TaskError.ArgumentsTypeMisMatch
            }
        }
        throw TaskError.NoArgument
    }

}


extension Task {

    /**
     Final forwarding method.
     We forward on the main queue.
     Supports currently Completion and Progression states.

     If the task is not in group we do nothing on forward.

     - parameter completionState: the completion state
     */
    final public func forward<T: ForwardableStates>(state: T) {
        if let aliasOfGroup=self.group {
            if let group: TasksGroup = aliasOfGroup.toLocalInstance() {
                dispatch_sync(group.dispatchQueue, {
                    if state is Completion {
                        self.completionState  = state as! Completion
                        self.status = .Completed
                        // We Relay the completion as a progression to the group progression !
                        // Including its data.

                        let total=group.totalTaskCount()
                        let executed=total-group.runnableTaskCount()
                        let progress: Double = Double(executed)/Double(total)
                        let groupProgression=Progression(currentTaskIndex:executed, totalTaskCount:total, currentTaskProgress:progress, message:"", data:self.completionState.data)

                        group.handlers.notify(groupProgression)

                        do {
                            if TasksScheduler.DEBUG_TASKS {
                                bprint("Marking Completion on \(self.summary ?? self.UID) \(executed)/\(total)", file: #file, function: #function, line: #line)
                            }
                            // WE CALL the onTaskCompletion on the main queue (!)
                            try Bartleby.scheduler.onTaskCompletion(self)
                        } catch {
                            if TasksScheduler.DEBUG_TASKS {
                                let t = self.summary ?? self.UID
                                bprint("ERROR Task Forwarding  of \(t) \(error)", file: #file, function: #function, line: #line)
                            }
                        }
                    } else if state is Progression {

                        // We relay also the discreet task as a progression group progression !
                        // Including its data.
                        // May be it could be distincted from completion
                        self.progressionState = state as! Progression
                        let total=group.totalTaskCount()
                        let executed=total-group.runnableTaskCount()
                        let progress: Double = Double(executed)/Double(total)
                        let groupProgression=Progression(currentTaskIndex:executed, totalTaskCount:total, currentTaskProgress:progress, message:self.progressionState.message, data:self.progressionState.data)

                        group.handlers.notify(groupProgression)


                    } else {
                        if TasksScheduler.DEBUG_TASKS {
                            bprint("ERROR unsupported ForwardableStates", file: #file, function: #function, line: #line)
                        }
                    }


                })
            } else {
                if TasksScheduler.DEBUG_TASKS {
                    bprint("ERROR No TaskGroup on \(self)", file: #file, function: #function, line: #line)
                }
            }
        }
        //})
    }


    /**
     The public final implementation of configureWithArguments

     - parameter arguments: the collectible arguments.
     */
    public final func configureWithArguments(arguments: Collectible) {
        self.argumentsData=arguments.serialize()
    }

    // A linearized list from the tasks graph
    public dynamic var linearTaskList: [Task] {
        get {
            // Return a linear task List
            var list=[Task]()
            func childrens(parent: Task, inout tasks: [Task]) {
                tasks.append(parent)
                for taskReference in parent.children {
                    if let task:Task=taskReference.toLocalInstance() {
                        childrens(task, tasks: &tasks)
                    }
                }
            }
            childrens(self, tasks: &list)
            return list
        }
    }

    /**
     Adds a children task to a task and setup its parent and group aliases

     - parameter task: the children to be added.
     */
    public func addChildren(task: Task) {
        let taskReference=ExternalReference(from: task)
        self.children.append(taskReference)
        if let g=self.group {
            task.group=g
        } else {
            if TasksScheduler.DEBUG_TASKS {
                bprint("Adding \(self.summary ?? self.UID) has no tasks group alias", file: #file, function: #function, line: #line)

            }
        }
        task.parent=ExternalReference(from:self)
        if TasksScheduler.DEBUG_TASKS {
            let s = task.summary ?? task.UID
            let t = self.summary ?? self.UID
            let g = task.group?.UID ?? Default.NO_GROUP
            bprint("Adding \(s) to \(t) in \(g)", file: #file, function: #function, line: #line)
        }
    }

}
