//
//  Descriptible.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 15/05/2016.
//
//

import Foundation

// Is used to propose an alternative to CustomConvertibleString
// CustomConvertibleString in JObject for example normally expose the JSON serialized string.
// We want sometimes more user frendly may be internationalized string description.
// That's the purpose of Descriptible.
public protocol Descriptible {
    func toString() -> String
}
