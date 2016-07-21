//
//  PString.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 19/12/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

// The goal of PString is to facilitate PHP to SWIFT port
// It focuses on translating litteraly the PHP style string processing.
// For example Flexions' Pluralization.php has been ported to swift in a few minutes
// You can compare Pluralization.swift & Pluralization.php

// MARK: - global PHP Style String functions

public struct PString {

    public static func strtoupper(string: String) -> String {
        return string.uppercaseString
    }

    public static func strtolower(string: String) -> String {
        return string.lowercaseString
    }

    public static func substr(string: String, _ start: Int) -> String? {
        if(start>0) {
            return substr(string, start, string.characters.count)
        } else {
            return substr(string, string.characters.count+start, string.characters.count)
        }
    }

    /**
     Left trims the characters specified in the characterSet

     E.g:
     + PString.ltrim("   *   Hello    *    ",characterSet: NSCharacterSet(charactersInString:" *")) // returns "Hello    *    "
     + PString.ltrim(",A,B,C",characterSet: NSCharacterSet(charactersInString:",")) // Returns "A,B,C"

     - parameter string:       the string
     - parameter characterSet: the character set (White spaces and new line by default)

     - returns: the string
     */
    public static func ltrim(string: String, characterSet: NSCharacterSet=NSCharacterSet.whitespaceAndNewlineCharacterSet()) -> String {
        if let range = string.rangeOfCharacterFromSet(characterSet.invertedSet) {
            return string[range.startIndex..<string.endIndex]
        }
        return string
    }

    /**
     Left trims the characters specified in the characters

     E.g:
     + PString.ltrim("   *   Hello    *    ",characters:" *") // returns "Hello    *    "
     + PString.ltrim(",A,B,C",characters:",")) // Returns "A,B,C"

     - parameter string:       the string
     - parameter characterSet: the character set (White spaces and new line by default)

     - returns: the string
     */
    public static func ltrim(string: String, characters: String) -> String {
        return ltrim(string, characterSet: NSCharacterSet(charactersInString:characters) )
    }




    /**
     Right trim the characters specified in the characterSet

     - parameter string:       the string
     - parameter characters: the character set (White spaces and new line by default)

     - returns: the string
     */

    public static func rtrim(string: String, characterSet: NSCharacterSet=NSCharacterSet.whitespaceAndNewlineCharacterSet()) -> String {
        if let range = string.rangeOfCharacterFromSet(characterSet.invertedSet, options: NSStringCompareOptions.BackwardsSearch) {
            return string[string.startIndex...range.startIndex]
        }
        return string
    }
    /**
     Right trim the characters specified in the characters

     - parameter string:     the string
     - parameter characters: the characters

     - returns: the string
     */
    public static func rtrim(string: String, characters: String) -> String {
        return rtrim(string, characterSet: NSCharacterSet(charactersInString:characters) )
    }


    /**
     Returns a sub string

     - parameter string: the string
     - parameter start:  If start is negative, the returned string will start at the start'th character from the end of string.
     - parameter length: length

     - returns: the sub string
     */
    public static func substr(string: String, _ start: Int, _ length: Int) -> String {
        let startIndex: String.Index?
        if start<0 {
            let l=strlen(string)
            let from=l-start
            if from>=l {
                startIndex=string.endIndex
            } else {
                startIndex=string.startIndex.advancedBy(from)
            }
        } else if start==0 {
            startIndex=string.startIndex
        } else {
            startIndex=string.startIndex.advancedBy(start)
        }
        let endIndex = string.startIndex.advancedBy(length)
        return string.substringWithRange(startIndex! ..< endIndex)
    }

    public static func strlen(string: String) -> Int {
        return string.characters.count
    }

    public static func lcfirst(string: String) -> String {
        var tstring=string
        let first=tstring.firstCharacterRange()
        tstring.replaceRange(first, with:tstring.substringWithRange(first).lowercaseString)
        return tstring
    }

    public static func ucfirst(string: String) -> String {
        var tstring=string
        let first=tstring.firstCharacterRange()
        tstring.replaceRange(first, with:tstring.substringWithRange(first).uppercaseString)
        return tstring
    }

    //preg_match PREG_OFFSET_CAPTURE flag is currently not implemented

    static let PREG_OFFSET_CAPTURE=1

    public static func preg_match(pattern: String, _ subject: String, inout _ matches: [String], _ flags: Int = 0, _ offset: Int = 0) -> Int {
        let subjectWithOffset=substr(subject, offset, strlen(subject))
        if subjectWithOffset.isMatching(pattern) {
            return 1
        }
        return 0
    }

    public static func preg_replace (pattern: String, _ replacement: String, _ subject: String, _ limit: Int = -1) -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.CaseInsensitive])
            return regex.stringByReplacingMatchesInString(subject, options: [], range: NSMakeRange(0, strlen(subject)), withTemplate:replacement)
        } catch {
            bprint("\(error)", file:#file, function:#function, line: #line)
        }
        return subject
    }


    public static func preg_replace (pattern: String, _ replacement: String, _ subject: [String], _ limit: Int = -1) -> [String] {
        var r=[String]()
        for subSubject in subject {
            r.append(preg_replace(pattern, replacement, subSubject, limit))
        }
        return r
    }
}



// MARK: - String extension

extension String {

    func contains(string: String) -> Bool {
        return (self.rangeOfString(string) != nil)
    }

    func isMatching(regex: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let matchCount = regex.numberOfMatchesInString(self, options: [], range: NSMakeRange(0, self.characters.count))
            return matchCount > 0
        } catch {
            bprint("\(error)", file:#file, function:#function, line: #line)
        }
        return false
    }

    func getMatches(regex: String, options: NSRegularExpressionOptions) -> [NSTextCheckingResult]? {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: options)
            let matches = regex.matchesInString(self, options: [], range: NSMakeRange(0, self.characters.count))
            return matches
        } catch {
            bprint("\(error)", file:#file, function:#function, line: #line)
        }
        return nil
    }

    func fullCharactersRange() -> Range<Index> {
        return Range<String.Index>(self.startIndex ... self.endIndex)
    }

    func firstCharacterRange()->Range<Index> {
        return Range<String.Index>(self.startIndex ... self.startIndex)
    }

    func lastCharacterRange()->Range<Index> {
        return Range<String.Index>(self.endIndex ... self.endIndex)
    }

}
