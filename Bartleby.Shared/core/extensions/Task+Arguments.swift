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
            //@bpds(#MAJOR) exception on deserialization of CollectionControllers
            //The KVO stack produces EXCEPTION, and we cannot use a Proxy+Patch Approach
            let deserialized=JSerializer.deserialize(argumentsData)
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

     - parameter completionState: the completion state
     */
    final public func forward(completionState: Completion) {
        // IMPORTANT(!) the task is trans-serialized
        // So we must store the status and completion state in its "Original"
        // And forget the Live instance.
        if let aliasOfGroup=self.group {
            if let group: TasksGroup = aliasOfGroup.toLocalInstance() {
                let originalTask = group.originalTaskFrom(self)
                originalTask.status = .Completed
                originalTask.completionState = completionState
            } else {
                if TasksScheduler.DEBUG_TASKS {
                    bprint("ERROR No TaskGroup on \(self)", file: #file, function: #function, line: #line)
                }
            }
        } else {
            if TasksScheduler.DEBUG_TASKS {
                bprint("ERROR No TaskGroup Alias on \(self)", file: #file, function: #function, line: #line)
            }
        }
        do {
            if TasksScheduler.DEBUG_TASKS {
                bprint("Marking Completion on \(self.summary ?? self.UID)", file: #file, function: #function, line: #line)
            }
            try Bartleby.scheduler.onTaskCompletion(self)
        } catch {
            if TasksScheduler.DEBUG_TASKS {
                let t = self.summary ?? self.UID
                bprint("ERROR Task Forwarding  of \(t) \(error)", file: #file, function: #function, line: #line)
            }
        }
    }

    /**
    The public final implementation of configureWithArguments

     - parameter arguments: the collectible arguments.
     */
    public final func configureWithArguments(arguments: Collectible) {
        self.argumentsData=arguments.serialize()
        self.taskClassName=self.typeName()
    }

    // A linearized list from the tasks graph
    public dynamic var linearTaskList: [Task] {
        get {
            // Return a linear task List
            var list=[Task]()
            func childrens(parent: Task, inout tasks: [Task]) {
                tasks.append(parent)
                for taskAlias in parent.children {
                    if let task=taskAlias.toLocalInstance() {
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
        let taskAlias: Alias<Task>=Alias(from: task)
        self.children.append(taskAlias)
        if let g=self.group {
             task.group=g
        } else {
            if TasksScheduler.DEBUG_TASKS {
                bprint("Adding \(self.summary ?? self.UID) has no tasks group alias", file: #file, function: #function, line: #line)

            }
        }
        task.parent=Alias(from:self)
        if TasksScheduler.DEBUG_TASKS {
            let s = task.summary ?? task.UID
            let t = self.summary ?? self.UID
            let g = task.group?.UID ?? Default.NO_GROUP
            bprint("Adding \(s) to \(t) in \(g)", file: #file, function: #function, line: #line)
        }
    }

}
