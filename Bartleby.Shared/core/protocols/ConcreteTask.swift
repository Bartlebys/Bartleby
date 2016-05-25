//
//  ConcreteTask.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 08/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

public protocol Invocable: Collectible {

    /**
        Runs the invocation on the Group Dispatch Queue
        All the logic is encapuslated.
        You must call super.invoke() and forward() on completion
     */
    func invoke()


    /**
     (!) This method is implemented as final in Task Extension to guarantee the task scheduler consistency
     You must call this method when the task is completed.

     it will forward the state on the main queue.

     - parameter completionState: the completion state
     */
    func forward<T: ForwardableState>(state: T)

}


public protocol ForwardableState {
}


/*

 To implement a concreteTask :

 1. Inheritate from Task or ReactiveTask.
 2. You MUST define an associated type.
 3. The convenience initializer MUST Call self.configureWithArguments(arguments)
    E.g:    convenience required public init(arguments: ArgumentType) {
                self.init()
                self.configureWithArguments(arguments)
            }



 */
public protocol ConcreteTask: Invocable {

    /**
     You MUST define an associated type.

     - returns: A collectible argument type
     */
    associatedtype ArgumentType:Serializable

    /**
     This initializer MUST !
     - Call self.configureWithArguments(arguments)

     ```

     - parameter arguments: the arguments

     - returns: a well initialized task.
     */
    init(arguments: ArgumentType)



    // (!) This method is implemented as final in a Task extension to force Type Matching Safety
    // it throws Task.ArgumentsTypeMisMatch
    func arguments<ExpectedType: Serializable>() throws -> ExpectedType

}
