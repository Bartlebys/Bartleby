//
//  NSRange+Helper.swift
//  YouDub
//
//  Created by Benoit Pereira da Silva on 26/05/2017.
//  Copyright © 2017 Lylo Media Group SA. All rights reserved.
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

    // MARK: - Operations on ranges

    public func union(_ range: NSRange) -> NSRange {
        return NSUnionRange(self, range)
    }

    public func intersection(_ range: NSRange) -> NSRange {
        return NSIntersectionRange(self, range)
    }

}
