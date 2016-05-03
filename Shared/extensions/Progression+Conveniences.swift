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

public extension Progression {


    /**
     The initializer of the Progression state

     - parameter currentTaskIndex:    the current task index eg. 1
     - parameter totalTaskCount:      the total number of task
     - parameter currentTaskProgress: the progress of the current task
     - parameter message:             a message
     - parameter data:                some opaque data.

     - returns: the progression state.
     */
    public convenience init(currentTaskIndex: Int, totalTaskCount: Int = 0, currentTaskProgress: Double = 0, message: String = "", data: NSData? = nil) {
        self.init()
        self.currentTaskIndex = currentTaskIndex
        self.totalTaskCount = totalTaskCount
        self.currentTaskProgress = currentTaskProgress
        self.message = message
        self.data = data
    }


    /**
     The default state

     - returns: return value description
     */
    public static func defaultState() -> Progression {
         return Progression(currentTaskIndex: 0, totalTaskCount: 0, currentTaskProgress: 0, message: "", data: nil)
    }

    /**
     Returns self embedded in a progression Notification

     - returns: a Progression notification
     */
    public var progressionNotification: ProgressionNotification {
        get {
            return ProgressionNotification(state:self, object:nil, userInfo: nil)
        }
    }

}
