//
//  CollectionMetadatum.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for [Benoit Pereira da Silva] (https://pereira-da-silva.com/contact)
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  [Bartleby's org] (https://bartlebys.org)   All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
#endif

// MARK: Bartleby's Core: Collection Metadatum. Complete implementation in CollectionMetadatum

@objc open class CollectionMetadatum: UnManagedModel {
    // DeclaredTypeName support
    open override class func typeName() -> String {
        return "CollectionMetadatum"
    }

    //the used file storage
    public enum Storage: String {
        case monolithicFileStorage
    }

    open var storage: Storage = .monolithicFileStorage

    // The holding collection name
    @objc open dynamic var collectionName: String = Default.NO_NAME

    // The proxy object (not serializable, not supervisable)
    @objc open dynamic var proxy: ManagedModel?

    // Allow distant persistency?
    @objc open dynamic var persistsDistantly: Bool = true

    // In Memory?
    @objc open dynamic var inMemory: Bool = true

    // MARK: - Codable

    public enum CollectionMetadatumCodingKeys: String, CodingKey {
        case storage
        case collectionName
        case proxy
        case persistsDistantly
        case inMemory
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        try quietThrowingChanges {
            let values = try decoder.container(keyedBy: CollectionMetadatumCodingKeys.self)
            self.storage = CollectionMetadatum.Storage(rawValue: try values.decode(String.self, forKey: .storage)) ?? .monolithicFileStorage
            self.collectionName = try values.decode(String.self, forKey: .collectionName)
            self.persistsDistantly = try values.decode(Bool.self, forKey: .persistsDistantly)
            self.inMemory = try values.decode(Bool.self, forKey: .inMemory)
        }
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CollectionMetadatumCodingKeys.self)
        try container.encode(storage.rawValue, forKey: .storage)
        try container.encode(collectionName, forKey: .collectionName)
        try container.encode(persistsDistantly, forKey: .persistsDistantly)
        try container.encode(inMemory, forKey: .inMemory)
    }

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    open override var exposedKeys: [String] {
        var exposed = super.exposedKeys
        exposed.append(contentsOf: ["storage", "collectionName", "proxy", "persistsDistantly", "inMemory"])
        return exposed
    }

    /// Set the value of the given key
    ///
    /// - parameter value: the value
    /// - parameter key:   the key
    ///
    /// - throws: throws an Exception when the key is not exposed
    open override func setExposedValue(_ value: Any?, forKey key: String) throws {
        switch key {
        case "storage":
            if let casted = value as? CollectionMetadatum.Storage {
                storage = casted
            }
        case "collectionName":
            if let casted = value as? String {
                collectionName = casted
            }
        case "proxy":
            if let casted = value as? ManagedModel {
                proxy = casted
            }
        case "persistsDistantly":
            if let casted = value as? Bool {
                persistsDistantly = casted
            }
        case "inMemory":
            if let casted = value as? Bool {
                inMemory = casted
            }
        default:
            return try super.setExposedValue(value, forKey: key)
        }
    }

    /// Returns the value of an exposed key.
    ///
    /// - parameter key: the key
    ///
    /// - throws: throws Exception when the key is not exposed
    ///
    /// - returns: returns the value
    open override func getExposedValueForKey(_ key: String) throws -> Any? {
        switch key {
        case "storage":
            return storage
        case "collectionName":
            return collectionName
        case "proxy":
            return proxy
        case "persistsDistantly":
            return persistsDistantly
        case "inMemory":
            return inMemory
        default:
            return try super.getExposedValueForKey(key)
        }
    }

    // MARK: - Initializable

    public required init() {
        super.init()
    }
}
