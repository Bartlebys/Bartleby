//
//  Initializable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 15/05/2016.
//
//

import Foundation

// Any Initializable Object should implement an argument free init.
// This force to have an inital consistent state to allow universal serialization / deserialization.
public protocol Initializable {
    init()
}
