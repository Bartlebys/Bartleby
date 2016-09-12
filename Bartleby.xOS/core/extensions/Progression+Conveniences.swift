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
        return "Progression. \(currentTaskIndex)/\(totalTaskCount) - \(floor(currentPercentProgress))% - \(data?.count ?? 0 ) bytes of data.\n\(message) [\(category)/\(externalIdentifier)]"
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
    public convenience init(currentTaskIndex: Int, totalTaskCount: Int = 0, currentPercentProgress: Double = 0, message: String = "", data: Data? = nil) {
        self.init()
        self.currentTaskIndex = currentTaskIndex
        self.totalTaskCount = totalTaskCount
        self.currentPercentProgress = currentPercentProgress
        self.message = message
        self.data = data
        self.startTime=CFAbsoluteTimeGetCurrent()
    }


    ///  Proportionnal Probable duration
    public var probableDuration:Double{
        if self.currentPercentProgress==0{
            return -1 // We donnot want to predict the unpredictable
        }
        // c    100
        //    x
        // e     ?
        return self.elapsedTime * 100 / self.currentPercentProgress
    }


    // Remaining by projection
    public var remaining:Double{
        return self.probableDuration-self.elapsedTime
    }

    /// Returns the elapsed time since the instanciation of the progression State
    public var elapsedTime:Double{
        if let startTime=self.startTime{
            return CFAbsoluteTimeGetCurrent() - startTime

        }else{
            return 0
        }
    }

    /// Returns a rounded version of the probable duration.
    public var roundedProbableDuration:Int{
        return Int(ceil(self.probableDuration))
    }

    /// Returns a rounded version of the probable duration.
    public var roundedRemaining:Int{
        return Int(ceil(self.remaining))
    }

    ///  Returns a rounded version of the elapsed time
    public var roundedElapsedTime:Int{
        return Int(ceil(self.elapsedTime))
    }

    /**
     Used to identify states

     - parameter category: the category classifier
     - parameter identity: the identity

     - returns: the state
     */
    public func identifiedBy(_ category:String,identity:String)->Progression{
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


}
