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
     Saves the state and forwards the completion.
     **Important!** During invocation you must in any cases call this method (on success or failure)
    (!) This method is implemented as final in Task Extension to guarantee the task scheduler consistency

     - parameter state: the Completion state
     */
    func complete(_ state: Completion)


    /**
     Saves and Transmits the progression state
       (!) This method is implemented as final in Task Extension to guarantee the task scheduler consistency
     - parameter state: the Progression state
     */
    func transmit(_ state: Progression)

}
