//
//  ManagedModel+Mergeable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/12/2016.
//
//

import Foundation

extension ManagedModel: Mergeable {
    /// Merge the instance with another
    ///
    /// - parameter instance: the instance
    open func mergeWith(_ instance: Exposed) throws {
        let preservedId = _id
        for key in instance.exposedKeys {
            if exposedKeys.contains(key) {
                let value = try instance.getExposedValueForKey(key)
                try setExposedValue(value, forKey: key)
            } else {
                log("Attempt to merge an unexisting key \(key) on \(instance))", file: #file, function: #function, line: #line, category: logsCategoryFor(self), decorative: false)
            }
        }
        _id = preservedId
    }
}
