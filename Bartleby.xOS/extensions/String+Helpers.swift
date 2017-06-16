//
//  String+Helpers.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 08/06/2017.
//
//

import Foundation


// MARK: - String extension

public extension String {

    public func contains(string: String) -> Bool {
        return (self.range(of: string) != nil)
    }

    public func contains(_ string: String,compareOptions:NSString.CompareOptions) -> Bool {
        return (self.range(of: string, options: compareOptions, range: self.fullCharactersRange(), locale: Locale.current) != nil )
    }

    public func isMatching(_ regex: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let matchCount = regex.numberOfMatches(in: self, options: [], range: NSMakeRange(0, self.characters.count))
            return matchCount > 0
        } catch {
            glog("\(error)", file:#file, function:#function, line: #line)
        }
        return false
    }

    public func getMatches(_ regex: String, options: NSRegularExpression.Options) -> [NSTextCheckingResult]? {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: options)
            let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, self.characters.count))
            return matches
        } catch {
            glog("\(error)", file:#file, function:#function, line: #line)
        }
        return nil
    }

    public func fullCharactersRange() -> Range<Index> {
        return Range(uncheckedBounds: (lower: self.startIndex, upper: self.endIndex))
    }

    public func firstCharacterRange()->Range<Index> {
        return Range(uncheckedBounds: (lower: self.startIndex, upper: self.startIndex))
    }

    public func lastCharacterRange()->Range<Index> {
        return Range(uncheckedBounds: (lower: self.endIndex, upper: self.endIndex))
    }


    public func jsonPrettify()->String{
        do {
            if let d=self.data(using:.utf8){
                let jsonObject = try JSONSerialization.jsonObject(with: d, options:[])
                let jsonObjectData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                if let prettyString = String(data: jsonObjectData, encoding: .utf8){
                    return prettyString
                }
            }
        } catch {
            return self
        }
        return self
    }

    public func fullNSRange()->NSRange{
        return NSRange(location: 0, length: self.characters.count)
    }

    public func nsRange(from range: Range<String.Index>) -> NSRange {
        let utf16 = self.utf16
        let from = range.lowerBound.samePosition(in: utf16)
        let to = range.upperBound.samePosition(in: utf16)
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),
                       length: utf16.distance(from: from, to: to))
    }


    public func range(from nsRange: NSRange) -> Range<String.Index>? {
        let utf16 = self.utf16
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
            else { return nil }
        return from ..< to
    }


    /// Removes the characters in the sub NSRange.
    /// The method ignores the invalid ranges.
    ///
    /// - Parameter range: the range of char to remove
    public mutating func removeSubNSRange(_ range:NSRange){
        let rangeEndLocation = range.location + range.length
        let charCount = self.characters.count
        let prefixed =  range.location > 0 ? PString.substr(self, 0, range.location) : ""
        let postFixed = rangeEndLocation < charCount ? PString.substr(self, rangeEndLocation) : ""
        self = prefixed + postFixed
    }


    
}
