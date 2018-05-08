//
//  ObjectExpositionError.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

public enum ObjectExpositionError: Error {
    case unknownKey(key: String, forTypeName: String)
}
