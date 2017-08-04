//
//  UnManagedModel+Serializable.swift
//  Bartleby macOS
//
//  Created by Benoit Pereira da silva on 04/08/2017.
//

import Foundation

extension UnManagedModel:Serializable{

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

}
