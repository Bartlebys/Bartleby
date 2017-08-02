//
//  ManagedModel+Serializable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

// MARK: - Serializable

extension ManagedModel:Serializable{

    open func serialize() -> Data {
        do {
          return try JSONEncoder().encode(self)
        } catch {
            return Data()
        }
    }


    /// Serialize the current object to an UTF8 string
    ///
    /// - Returns: return an UTF8 string
    open func serializeToUFf8String()->String{
        return self.toJSONString(false)
    }

    open func updateData(_ data: Data,provisionChanges:Bool) throws -> Serializable {
        do {
            let deserialized = try JSONDecoder().decode(type(of: self), from: data)
            try self.mergeWith(deserialized)
            if provisionChanges && self.isInspectable {
                self.provisionChanges(forKey: "*", oldValue: self, newValue: self)
            }
        }catch{
            // Silent
        }
        return self
    }

}
