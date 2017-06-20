//
//  NSRange+Helper.swift
//  YouDub
//
//  Created by Benoit Pereira da Silva on 26/05/2017.
//  Copyright © 2017 Lylo Media Group SA. All rights reserved.
//

import Foundation

public func ==(lhr: NSRange, rhr: NSRange) -> Bool {
    return NSEqualRanges(lhr, rhr)
}

extension NSRange : Equatable, Hashable {

    public var hashValue: Int {
        // We could use https://en.wikipedia.org/wiki/Pairing_function#Cantor_pairing_function
        // but we prefer to use http://szudzik.com/ElegantPairing.pdf
        let a = self.location
        let b = self.length
        let A = a >= 0 ? 2 * a : -2 * a - 1
        let B = b >= 0 ? 2 * b : -2 * b - 1
        return A >= B ?  (A * A + A + B) : (A + B * B)
    }
}


extension NSRange:CustomStringConvertible{

    public var description: String {
        return "NSRange(location:\(self.location), length:\(self.length))"
    }

}

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
