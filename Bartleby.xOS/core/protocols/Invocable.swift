//
//  Invocable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 20/07/2016.
//
//

import Foundation


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
