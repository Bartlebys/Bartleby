//
//  ConcreteTask.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 08/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation


public protocol SerializableArguments {
    // (!) This method is implemented as final in a Task extension to force Type Matching Safety
    // it throws Task.ArgumentsTypeMisMatch
    func arguments<ExpectedType: Collectible>() throws -> ExpectedType
}

public protocol Invocable: Collectible {

    /**
        Runs the invocation
        All the logic is encapuslated.
        You should call forward() on completion
     */
    func invoke()

    /**
     (!) This method is implemented as final in Task Extension to guarantee the task scheduler consistency
     You must call this method when the task is completed.
     - parameter completionState: the completion state
     */
    func forward(completionState: Completion)

}


public protocol ConcreteTask: SerializableArguments, Invocable {

    /**
     This initializer **MUST:**
     - Store the Serialized Argument into argumentsData
     - Set the explicit concrete task class name

     E.g :
     ```swift
     convenience required public init (arguments: Serializable) {
        self.init()
        self.argumentsData=arguments.serialize()
        self.taskClassName=self.typeName // (!) Used to force the transitionnal casting
     }
     ```

     - parameter arguments: the arguments

     - returns: a well initialized task.
     */
    init(arguments: Collectible)
}
