//
//  Progression+Facilities.swift
//  bsync
//
//  Created by Martin Delille on 26/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

// MARK: - Progression

extension Progression:Descriptible {

    public func toString() -> String {
        var dataString = ""
        if let data = data{
            if data.count > 0{
                dataString = "\(data.count) bytes of data."
            }
        }
        let percent = String(format:"%.2f",self.currentPercentProgress)
        let elapsed = String(format:"%.2f",self.elapsedTime)
        let remaining = String(format:"%.0f",floor(self.remaining))
        return "\(percent)% (\(self.currentTaskIndex)/\(self.totalTaskCount)) Elapsed: \(elapsed)s Remaining:\(remaining)s | \(dataString): \(message) [\(category)-\(externalIdentifier)]"
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



    /// Allows to convert a Progress object to a Progression
    ///
    /// - Parameter progress: the progress
    /// - Returns: the encoded Progression
    public static func from(_ progress: Progress) -> Progression{
        let progression = Progression()
        progression.totalTaskCount = Int(progress.totalUnitCount)
        progression.currentTaskIndex = Int(progress.completedUnitCount)
        progression.currentPercentProgress = progression.totalTaskCount != 0 ? Double( progression.currentTaskIndex)*Double(100)/Double(progression.totalTaskCount) : -1
        progression.externalIdentifier = progress.kind?.rawValue != nil ? progress.kind!.rawValue : "?"
        progression.message = progression.externalIdentifier 
        return progression
    }


    /// Update progression from Foundation.Progress
    ///
    /// - Parameter progress: the progress
    public func updateProgression(from progress:Foundation.Progress){
        self.currentTaskIndex=min(Int(progress.completedUnitCount)+1,Int(progress.totalUnitCount))
        self.totalTaskCount=Int(progress.totalUnitCount)
        self.currentPercentProgress=Double(self.currentTaskIndex)*Double(100)/Double(self.totalTaskCount)
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
