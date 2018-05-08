//
//  ProvisionChanges.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

public protocol ProvisionChanges {
    /**
     Tags the changed keys
     And Mark that the instance requires to be committed if the auto commit observer is active
     This mechanism can replace KVO if necessary.

     - parameter key:      the key
     - parameter oldValue: the oldValue
     - parameter newValue: the newValue
     */
    func provisionChanges(forKey key: String, oldValue: Any?, newValue: Any?)

    /// Performs the deserialization without invoking provisionChanges
    ///
    /// - parameter changes: the changes closure
    func quietChanges(_ changes: () -> Void)

    /// Performs the deserialization without invoking provisionChanges
    ///
    /// - parameter changes: the changes closure
    func quietThrowingChanges(_ changes: () throws -> Void) rethrows
}
