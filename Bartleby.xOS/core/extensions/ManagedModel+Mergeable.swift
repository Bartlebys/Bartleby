//
//  ManagedModel+Mergeable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/12/2016.
//
//

import Foundation

extension ManagedModel:Mergeable{

    /// Merge the instance with another
    ///
    /// - parameter instance: the instance
    open func mergeWith(_ instance: Exposed) throws {
        for key in instance.exposedKeys{
            if self.exposedKeys.contains(key){
                let value = try instance.getExposedValueForKey(key)
                try self.setExposedValue(value, forKey: key)
            }else{
                self.log("Attempt to merge an unexisting key \(key) on \(instance))", file: #file, function: #function, line: #line, category: logsCategoryFor(self), decorative: false)
            }
        }
        self._commitCounter=Int(instance.commitCounter)
    }

}
