//
//  Task+Arguments.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/04/2016.
//
//

import Foundation

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
    public final func arguments<ArgumentType: Serializable>() throws -> ArgumentType {
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
        self.completionState=completionState
        self.status = .Completed
        try? Bartleby.scheduler.onCompletion(self)
    }

}


// MARK: - Linear list


extension Task {

    dynamic var linearTaskList: [Task] {
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
}

// MARK: - Children management

public extension Task {

    func addChildren(task: Task) {
        self.children.append(task.toAlias())
        task.group=self.group
        task.parent=self.toAlias()
    }

}
