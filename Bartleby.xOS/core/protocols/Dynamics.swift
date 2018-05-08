//
//  DynamicSerializer.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/08/2017.
//

import Foundation

public enum DynamicsError: Error {
    case typeNotFound
    case collectionTypeRequired
    case injectionHasFailed
    case jsonDeserializationFailure
}

// We use dynamic deserialization to handle triggers, operation provisionning and Server sent events.
// Everywhere else you should use the standard Serializer
public protocol Dynamics {
    /// Deserializes dynamically an entity based on its Class name.
    ///
    /// - Parameters:
    ///   - typeName: the typeName
    ///   - data: the encoded data
    ///   - document: the document to register In the instance (if set to nil the instance will not be registred
    /// - Returns: the dynamic instance that you cast..?
    func deserialize(typeName: String, data: Data, document: BartlebyDocument?) throws -> Any

    /// This is a Dyamic Factory
    ///
    /// - Parameter typeName: the class name
    /// - Returns: the new instance
    func newInstanceOf(_ typeName: String) throws -> Any

    // MARK: - Patch (migration support)

    /// You can patch some data providing default values.
    ///
    /// - Parameters:
    ///   - data: the Data to patch
    ///   - dictionary: the dictionary
    /// - Returns: the patched data
    func patchProperties(data: Data, patchDictionary: [String: Any]) throws -> Data

    /// You can patch some data providing
    ///
    /// - Parameters:
    ///   - data:  the Data to patch
    ///   - injectedDictionary: the dictionary to be injected
    ///   - keyPath: the key path to be used
    ///   - forced: if set to true the key path will be replaced in any case (use carefully)
    /// - Returns: the patched data
    func patchItemsInCollection(data: Data, injectedDictionary: [String: Any], keyPath: DictionaryKeyPath, forced: Bool) throws -> Data

    // Changes the property name from an old to a new name
    ///
    /// - Parameters:
    ///   - data: the Data to patch
    ///   - oldName: the old property name
    ///   - newName: the new property name
    /// - Returns: the patched data
    func changeItemsPropertyName(data: Data, oldName: String, newName: String) throws -> Data
}
