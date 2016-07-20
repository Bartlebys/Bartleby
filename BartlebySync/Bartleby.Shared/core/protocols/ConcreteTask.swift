//
//  ConcreteTask.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 08/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

// MARK: Concrete Task protocol

/*

 # A concrete task can be executed in a TasksGroup by a TaskScheduler

 Task are implemented using GCD, and not NSOperationQueue.
 They are not committed to light footprint or performance

 Tasks are suitable for :

 - concurent graph execution
 - supervised monitoring
 - interruptibility (serialization & deserialization of the process)
 - distribution ( run on multiple nodes)
 - ...


 To obtain those goals you must conform to strict implementation rules.

 # How to implement a concreteTask ?

 1. Your concrete task must be `Invocable`(Inheritate from Task or ReactiveTask).
 2. You MUST define the associated ArgumentType.
 3. The convenience initializer MUST Call self.configureWithArguments(arguments)

```
convenience required public init(arguments: ArgumentType) {
    self.init()
    self.configureWithArguments(arguments)
}
```

 4. On invoke()
 4.1 call `super.invoke()`
 4.2 try to deserialize the arguments `let user: ArgumentType = try self.arguments() as ArgumentType`
 4.3 on any case call `self.complete(completionState)`

```
    override public func invoke()  {
        super.invoke()
        do{
            if let user: ArgumentType = try self.arguments() as ArgumentType {
                // do something
                // On success call : `self.complete(Completion.successState())`
                // On failure call : `self.complete(completionState)`
                // You can  call : `forward(progressionState)` if the task is long
            }

            }catch{
                self.complete(Completion.failureState("Argument type missmatch", statusCode: StatusOfCompletion.Precondition_Failed))
            }
        }
    }
```

 You can check implementations samples in the unit test or analyze `PushOperationTask` and `CommitAndPushPendingOperationsTask`

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



// MARK: Invocable protocol

public protocol Invocable: Collectible {

    /**
        Runs the invocation on the Group Dispatch Queue
        All the logic is encapuslated.
     */
    func invoke()


    /**
     Register the state and forwards the completion.
     **Important!** During invocation you must in any cases call this method (on success or failure)

     - parameter state: the completion state
     */
    func complete(state: Completion)

    /**
     (!) This method is implemented as final in Task Extension to guarantee the task scheduler consistency
     This method is called by `complete()` when the task is completed.

     it will forward the state on the main queue.

     - parameter state: the Forwardable state
     */
    func forward<T: ForwardableState>(state: T)


}

// MARK: Invocable protocol

public protocol ForwardableState {
}
