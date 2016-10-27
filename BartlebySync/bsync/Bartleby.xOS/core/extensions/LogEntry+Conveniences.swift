//
//  LogEntry+Conveniences.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/10/2016.
//
//

import Foundation


/**
 *  A struct to insure temporary persistency of a BLogEntry
 */
extension LogEntry{

    public convenience init(counter:Int,message: String, file: String, function: String, line: Int, category: String,elapsed:CFAbsoluteTime,decorative:Bool=false){
        self.init()
        self.counter=counter
        self.message=message
        self.file=LogEntry.extractFileName(file)
        self.function=function
        self.line=line
        self.category=category
        self.elapsed=elapsed
        self.decorative=decorative
    }

    func padded<T>(_ number: T, _ numberOfDigit: Int, _ char: String=" ", _ left: Bool=true) -> String {
        var s="\(number)"
        while s.characters.count < numberOfDigit {
            if left {
                s=char+s
            } else {
                s=s+char
            }
        }
        return s
    }

    static func extractFileName(_ s: String) -> String {
        let components=s.components(separatedBy: "/")
        if components.count>0 {
            return components.last!
        }
        return ""
    }

    override open var description: String {
        if decorative {
            return "\(message)"
        }
        let s="\(self.padded(counter, 6)) \( category) | \(self.padded( elapsed, 3, "0", false)) \(file)/\(function)#\(line) : \(message)"
        return  s
    }

}
