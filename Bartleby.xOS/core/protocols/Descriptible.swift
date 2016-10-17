//
//  Descriptible.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 15/05/2016.
//
//

import Foundation

// Is used to propose an alternative to CustomConvertibleString
// CustomConvertibleString in BartlebyObject for example normally expose the JSON serialized string.
// We want sometimes more user frendly
// That's the purpose of Descriptible.
// By convention we use MarkDown.
public protocol Descriptible {
    func toString() -> String
}
