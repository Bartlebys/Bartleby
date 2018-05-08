//
//  JSONSerializer.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 24/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

open class JSONSerializer: Serializer {
    // The containing document reference
    public var document: BartlebyDocument

    /// The file extension for file based serializers.
    open var fileExtension: String { return "json" }

    // The initializer
    public required init(document: BartlebyDocument) {
        self.document = document
    }

    // MARK: - Deserialization

    /// Deserializes a fully typed object
    ///
    /// - Parameters:
    ///   - data: the opaque data
    ///   - register: should we register to document and collection?
    /// - Returns: the deserialized object
    /// - Throws: Deserialization exceptions
    open func deserialize<T: Collectible>(_ data: Data, register: Bool) throws -> T {
        return try _deserializeFromData(data, register: register)
    }

    ///  The concrete deserialization logic with auto decrypt logic.
    /// - Parameters:
    ///   - data: the data
    ///   - register: should we register to document and collection?
    /// - Returns: the Serializable instance
    /// - Throws: SerializableError and CryptoError
    fileprivate func _deserializeFromData<T: Collectible>(_ data: Data, register: Bool) throws -> T {
        var instance = try JSON.decoder.decode(T.self, from: data)
        // Set up the runtime references.
        if register {
            if (instance is BartlebyCollection) || (instance is BartlebyOperation) {
                // Add the document reference
                instance.referentDocument = document
            } else {
                // Add the collection reference
                // Calls the Bartleby.register(self)
                instance.collection = document.collectionByName(instance.d_collectionName)
            }
        }
        return instance
    }

    /// Deserializes from an UTF8 string
    /// - Parameters:
    ///   - string: the string
    ///   - register: should we register to document and collection?
    /// - Returns: the deserialized object
    /// - Throws: Variable exception (serializer based)
    open func deserializeFromUTF8String<T: Collectible>(_ string: String, register: Bool) throws -> T {
        if let data = string.data(using: .utf8) {
            return try _deserializeFromData(data, register: register)
        }
        throw SerializableError.invalidUTF8String
    }

    // MARK: - Serialization

    ///  Serializes an instance
    ///
    /// - Parameter instance: the Serializable instance
    /// - Returns: the data
    open func serialize(_ instance: Collectible) -> Data {
        return instance.serialize() as Data
    }

    /// Serializes the current instance to an UTF8 String
    ///
    /// - Parameter instance: the serializable instance
    /// - Returns: the UTF8 string
    open func serializeToUTF8String(_ instance: Collectible) -> String {
        return instance.serializeToUFf8String()
    }
}
