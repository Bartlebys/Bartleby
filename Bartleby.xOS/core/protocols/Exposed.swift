//
//  Exposed.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/10/2016.
//
//

import Foundation

public protocol Exposed {
    /// Return all the exposed instance variables names. Exposed means public and modifiable.
    var exposedKeys: [String] { get }

    /// Set the value of the given key
    ///
    /// - parameter value: the value
    /// - parameter key:   the key
    ///
    /// - throws: throws Exception when the key is not exposed
    func setExposedValue(_ value: Any?, forKey key: String) throws

    /// Returns the value of an exposed key.
    ///
    /// - parameter key: the key
    ///
    /// - throws: throws Exception when the key is not exposed
    ///
    /// - returns: returns the value
    func getExposedValueForKey(_ key: String) throws -> Any?
}
