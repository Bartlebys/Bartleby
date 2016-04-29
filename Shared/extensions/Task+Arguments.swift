//
//  Task+Arguments.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/04/2016.
//
//

import Foundation

public enum TaskError : ErrorType {
    case ArgumentsTypeMisMatch
    case NoArgument
}

extension Task:SerializableArguments{

    
    /**
    - throws: Error on deserialization and type missmatch
    
    - returns: A collectible object
    */
    public final func arguments<ArgumentType:Serializable>() throws -> ArgumentType{
        if let argumentsData = self.argumentsData {
            //@bpds(#MAJOR) exception on deserialization of CollectionControllers
            //The KVO stack produces EXCEPTION, and we cannot use a Proxy+Patch Approach
            let deserialized=JSerializer.deserialize(argumentsData)
            if let arguments = deserialized as? ArgumentType{
                return arguments
            }else{
                throw TaskError.ArgumentsTypeMisMatch
            }
        }
        throw TaskError.NoArgument
    }
    
}


// MARK : Linear list


extension Task{
    
    dynamic var linearTaskList:[Task]{
        get{
            // Return a linear task List
            var tasks=[Task]()
            func childrens(parent:Task, inout tasks:[Task]){
                tasks.append(parent)
                for child in parent.children{
                    childrens(child, tasks: &tasks)
                }
            }
            childrens(self, tasks: &tasks)
            return tasks
        }
    }
    
}