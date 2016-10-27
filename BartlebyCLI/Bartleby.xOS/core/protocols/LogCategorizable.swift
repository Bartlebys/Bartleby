//
//  LogCategorizable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 22/10/2016.
//
//

import Foundation

public protocol LogCategorizable {
    static var logCategory: String { get }
}
