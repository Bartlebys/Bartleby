//
//  PString.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 19/12/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

#if os(OSX)
    import AppKit
#else
    import UIKit
#endif



// The goal of PString is to facilitate PHP to SWIFT port
// It focuses on translating litteraly the PHP style string processing.
// For example Flexions' Pluralization.php has been ported to swift in a few minutes
// You can compare Pluralization.swift & Pluralization.php

// MARK: - global PHP Style String functions

public struct PString {

    public static func strtoupper(_ string: String) -> String {
        return string.uppercased()
    }

    public static func strtolower(_ string: String) -> String {
        return string.lowercased()
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
    public static func ltrim(_ string: String, characterSet: CharacterSet=CharacterSet.whitespacesAndNewlines) -> String {
        if let range = string.rangeOfCharacter(from: characterSet.inverted) {
            return string[range.lowerBound..<string.endIndex]
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
    public static func ltrim(_ string: String, characters: String) -> String {
        return ltrim(string, characterSet: CharacterSet(charactersIn:characters) )
    }


    /**
     Right trim the characters specified in the characterSet

     - parameter string:       the string
     - parameter characters: the character set (White spaces and new line by default)

     - returns: the string
     */

    public static func rtrim(_ string: String, characterSet: CharacterSet=CharacterSet.whitespacesAndNewlines) -> String {
        if let range = string.rangeOfCharacter(from: characterSet.inverted, options: NSString.CompareOptions.backwards) {
            return string[string.startIndex...range.lowerBound]
        }
        return string
    }
    /**
     Right trim the characters specified in the characters

     - parameter string:     the string
     - parameter characters: the characters

     - returns: the string
     */
    public static func rtrim(_ string: String, characters: String) -> String {
        return rtrim(string, characterSet: CharacterSet(charactersIn:characters) )
    }


    public static func trim(_ string: String,characters: String) -> String {
        return rtrim(ltrim(string,characters:characters),characters:characters)
    }




    public static func trim(_ string: String) -> String {
        return rtrim(ltrim(string))
    }



    ///Returns a sub string
    ///behaves 100% like PHP substring http://php.net/manual/en/function.substr.php
    ///
    /// - Parameters:
    /// - parameter string: the string
    /// - parameter start:  If start is negative, the returned string will start at the start'th character from the end of string.
    /// - Returns: the sub string
    public static func substr(_ string: String, _ start: Int) -> String {
        return PString.substr(string, start, nil)
    }

    /**
     Returns a sub string
     behaves 100% like PHP substring http://php.net/manual/en/function.substr.php

     - parameter string: the string
     - parameter start:  If start is negative, the returned string will start at the start'th character from the end of string.
     - parameter length: length

     - returns: the sub string
     */
    public static func substr(_ string: String, _ start: Int, _ length: Int?) -> String {

        let strLength=Int(string.characters.count)
        var start=start
        let length:Int=length ?? strLength

        if start<0{
            start=strLength+start
        }

        var rightPos:Int=start+length

        if length<0{
            rightPos=strLength+length
        }

        var leftPos:Int=start

        leftPos =  max(0,leftPos)
        rightPos = max(0,rightPos)

        leftPos =  min(strLength,leftPos)
        rightPos = min(strLength,rightPos)

        let startIndex = (leftPos==0) ? string.startIndex : string.index(string.startIndex, offsetBy: leftPos)
        let endIndex = (rightPos==0) ? string.startIndex : string.index(string.startIndex, offsetBy: rightPos)

        return string.substring(with: startIndex..<endIndex)
    }


    public static func strlen(_ string: String) -> Int {
        return string.characters.count
    }

    public static func lcfirst(_ string: String) -> String {
        var tstring=string
        let first=tstring.firstCharacterRange()
        tstring.replaceSubrange(first, with:tstring.substring(with: first).lowercased())
        return tstring
    }

    public static func ucfirst(_ string: String) -> String {
        var tstring=string
        let first=tstring.firstCharacterRange()
        tstring.replaceSubrange(first, with:tstring.substring(with:first).uppercased())
        return tstring
    }

    //preg_match PREG_OFFSET_CAPTURE flag is currently not implemented

    static let PREG_OFFSET_CAPTURE=1

    public static func preg_match(_ pattern: String, _ subject: String, _ matches: inout [String], _ flags: Int = 0, _ offset: Int = 0) -> Int {
        let subjectWithOffset=substr(subject, offset, strlen(subject))
        if subjectWithOffset.isMatching(pattern) {
            return 1
        }
        return 0
    }

    public static func preg_replace (_ pattern: String, _ replacement: String, _ subject: String, _ limit: Int = -1) -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            return regex.stringByReplacingMatches(in: subject, options: [], range: NSMakeRange(0, strlen(subject)), withTemplate:replacement)
        } catch {
            glog("\(error)", file:#file, function:#function, line: #line)
        }
        return subject
    }


    public static func preg_replace (_ pattern: String, _ replacement: String, _ subject: [String], _ limit: Int = -1) -> [String] {
        var r=[String]()
        for subSubject in subject {
            r.append(preg_replace(pattern, replacement, subSubject, limit))
        }
        return r
    }
}






