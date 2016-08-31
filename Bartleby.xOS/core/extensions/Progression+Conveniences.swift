//
//  Progression+Facilities.swift
//  bsync
//
//  Created by Martin Delille on 26/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

// MARK: - Progression

extension Progression:ForwardableState {

}


extension Progression:Descriptible {

    public func toString() -> String {
        return "Progression. \(currentTaskIndex)/\(totalTaskCount) - \(floor(currentPercentProgress))% - \(data?.length ?? 0 ) bytes of data.\n\(message) [\(category)/\(externalIdentifier)]"
    }

}



public extension Progression {

    /**
     The initializer of the Progression state

     - parameter currentTaskIndex:    the current task index eg. 1
     - parameter totalTaskCount:      the total number of task
     - parameter currentPercentProgress: the progress of the current task
     - parameter message:             a message
     - parameter data:                some opaque data.

     - returns: the progression state.
     */
    public convenience init(currentTaskIndex: Int, totalTaskCount: Int = 0, currentPercentProgress: Double = 0, message: String = "", data: NSData? = nil) {
        self.init()
        self.currentTaskIndex = currentTaskIndex
        self.totalTaskCount = totalTaskCount
        self.currentPercentProgress = currentPercentProgress
        self.message = message
        self.data = data
    }


    /**
     Used to identify states

     - parameter category: the category classifier
     - parameter identity: the identity

     - returns: the state
     */
    public func identifiedBy(_ category:String,_ identity:String)->Progression{
        self.category=category
        self.externalIdentifier=identity
        return self
    }

    /**
     The default state

     - returns: return value description
     */
    public static func defaultState() -> Progression {
         return Progression(currentTaskIndex: 0, totalTaskCount: 0, currentPercentProgress: 0, message: "", data: nil)
    }

    /**
     Returns self embedded in a progression Notification

     - returns: a Progression notification
     */
    public var progressionNotification: NSNotification {
        get {
            return NSNotification(progressionState:self, object:nil)
        }
    }

}
