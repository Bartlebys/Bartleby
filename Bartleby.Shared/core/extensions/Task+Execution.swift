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
    case MissingTaskGroup
    case UnSupportedForwardableState
    case MissingExternalReference
    case MultipleAttemptToRunTask
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
     Call to signal completion

     - parameter state: the completionState
     */
    public func complete(state: Completion) {
        self.completionState = state
    }

    /**
     This implementation should be calld in any Task invoke override
     To Detect multiple attempt to run the task

     - throws: MultipleAttemptToRunTAsk
     */
    public func invoke() throws {
        if self.status != .Runnable {
            throw TaskError.MultipleAttemptToRunTask
        } else {
            self.status = .Running
        }
        if TasksScheduler.DEBUG_TASKS {
            bprint("Running \(self.summary ?? self.UID)", file: #file, function: #function, line: #line)
        }
    }


    public var hasBeenSuccessfullyCompleted: Bool {
        get {
            if let c=self.completionState {
                 return c.success
            }
            return false
        }
    }


    /**
     Final forwarding method.
     We forward on the main queue.
     Supports currently Completion and Progression states.

     If the task is not in group we do nothing on forward.

     - parameter completionState: the completion state
     */
    final public func forward<T: ForwardableStates>(state: T) throws {
        if let groupExtRef=self.group {
            if let group: TasksGroup = groupExtRef.toLocalInstance() {
                    if let state = state as? Completion {
                        self.completionState  = state
                        
                        // We Relay the completion as a progression to the group progression !
                        // Including its data.

                        let total=group.totalTaskCount()
                        let executed=total-group.runnableTaskCount()
                        let progress: Double = Double(executed)/Double(total)
                        let groupProgression=Progression(currentTaskIndex:executed, totalTaskCount:total, currentTaskProgress:progress, message:"", data:self.completionState?.data)

                        group.handlers.notify(groupProgression)

                        if TasksScheduler.DEBUG_TASKS {
                            bprint("Marking Completion on \(self.summary ?? self.UID) \(executed)/\(total)", file: #file, function: #function, line: #line)
                        }
                        try Bartleby.scheduler.onAnyTaskCompletion(self)
                    } else if state is Progression {
                        // We relay also the discreet task as a progression group progression !
                        // Including its data.
                        // May be it could be distincted from completion
                        self.progressionState = state as? Progression
                        let total=group.totalTaskCount()
                        let executed=total-group.runnableTaskCount()
                        let progress: Double = Double(executed)/Double(total)
                        let groupProgression=Progression(currentTaskIndex:executed, totalTaskCount:total, currentTaskProgress:progress, message:self.progressionState?.message ?? Default.NO_MESSAGE, data:self.progressionState?.data)
                        group.handlers.notify(groupProgression)
                    } else {
                        throw TaskError.UnSupportedForwardableState
                    }

            } else {
                throw TaskError.MissingTaskGroup
            }
        }
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
                    if let task: Task=taskReference.toLocalInstance() {
                        childrens(task, tasks: &tasks)
                    }
                }
            }
            childrens(self, tasks: &list)
            return list
        }
    }

    /**
     Adds a children task to a task and setup its parent and group externalReferences

     - parameter task: the children to be added.
     */
    public func addChildren(task: Task) throws {
        let taskReference=ExternalReference(from: task)
        self.children.append(taskReference)
        if let g=self.group {
            task.group=g
        } else {
            throw TaskError.MissingTaskGroup
        }
        task.parent=ExternalReference(from:self)
        if TasksScheduler.DEBUG_TASKS {
            let s = task.summary ?? task.UID
            let t = self.summary ?? self.UID
            let g = task.group?.iUID ?? Default.NO_GROUP
            bprint("Adding \(s) to \(t) in \(g)", file: #file, function: #function, line: #line)
        }
    }

}
