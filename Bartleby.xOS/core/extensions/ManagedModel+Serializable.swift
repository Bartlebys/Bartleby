//
//  ManagedModel+Serializable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

// MARK: - Serializable

extension ManagedModel: Serializable {
    open func serialize() -> Data {
        do {
            return try JSON.encoder.encode(self)
        } catch {
            return Data()
        }
    }

    /// Serialize the current object to an UTF8 string
    ///
    /// - Returns: return an UTF8 string
    open func serializeToUFf8String() -> String {
        return toJSONString(false)
    }
}
