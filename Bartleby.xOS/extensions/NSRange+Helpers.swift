//
//  NSRange+Helper.swift
//  YouDub
//
//  Created by Benoit Pereira da Silva on 26/05/2017.
//  Copyright © 2017 https://pereira-da-silva.com/ All rights reserved.
//

import Foundation


// MARK: - Helper

extension NSRange{

    /// Consistant name for clear code
    public var firstLocation:Int { return self.location }

    // Correspond to the last valid index
    // Can be equal to firstLocation if the length <= 0
    public var lastLocation: Int { return self.length==0 ? self.location : self.location + (self.length - 1) }

    // The Centered location
    public var centeredLocation: Int { return max(firstLocation,(self.lastLocation + self.firstLocation)/2) }

    public func intersects(_ range:NSRange)->Bool{
        return NSIntersectionRange(range, self).length > 0
    }

    public func containsLocation(_ location:Int)->Bool{
       return location >= self.firstLocation && location <= self.lastLocation
    }

    // This method works with ranges with length of 0 
    // You can use intersects ranges with length > 0
    public func containsAtLeastOneLocationFromRange( _ range:NSRange)->Bool{
        for location in range.firstLocation ... range.lastLocation{
            if self.containsLocation(location){
                return true
            }
        }
        return false
    }

    public func containsRange(_ range:NSRange)->Bool{
        let r = range.firstLocation >= self.firstLocation && range.lastLocation <= self.lastLocation
        return r
    }


    /// Return the inverted ranges from an Array of NSRange
    ///
    /// - Parameters:
    ///   - ranges: the array of range
    ///   - fullRange: the full range
    /// - Returns: the inverse of the array of NSRange
    public static func invertedNSRangesFrom(_ ranges:[NSRange],with fullRange:NSRange)->[NSRange]{
        var invertedRanges = [NSRange]()
        var lastRange:NSRange = NSMakeRange(-1,0)
        for range in ranges{
            if lastRange.lastLocation <= range.firstLocation{
                invertedRanges.append(NSMakeRange(lastRange.lastLocation+1,range.firstLocation-lastRange.lastLocation-1))
            }
            lastRange = range
        }
        if lastRange.lastLocation < fullRange.length{
            invertedRanges.append(NSMakeRange(lastRange.lastLocation+1,fullRange.lastLocation-lastRange.lastLocation))
        }
        return invertedRanges
    }

}
