//
//  KeyedChanges.swift
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

// MARK: Bartleby's Core: used to keep track of changes in memory when inspecting an App (Value Object)

@objc open class KeyedChanges: UnManagedModel {
    // DeclaredTypeName support
    open override class func typeName() -> String {
        return "KeyedChanges"
    }

    //the elapsed time since the app has been launched
    @objc open dynamic var elapsed: Double = Bartleby.elapsedTime

    //the key
    @objc open dynamic var key: String = Default.NO_KEY

    // A description of the changes that have occured
    @objc open dynamic var changes: String = Default.NO_MESSAGE

    // MARK: - Codable

    public enum KeyedChangesCodingKeys: String, CodingKey {
        case elapsed
        case key
        case changes
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        try quietThrowingChanges {
            let values = try decoder.container(keyedBy: KeyedChangesCodingKeys.self)
            self.elapsed = try values.decode(Double.self, forKey: .elapsed)
            self.key = try values.decode(String.self, forKey: .key)
            self.changes = try values.decode(String.self, forKey: .changes)
        }
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: KeyedChangesCodingKeys.self)
        try container.encode(elapsed, forKey: .elapsed)
        try container.encode(key, forKey: .key)
        try container.encode(changes, forKey: .changes)
    }

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    open override var exposedKeys: [String] {
        var exposed = super.exposedKeys
        exposed.append(contentsOf: ["elapsed", "key", "changes"])
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
        case "elapsed":
            if let casted = value as? Double {
                elapsed = casted
            }
        case "key":
            if let casted = value as? String {
                self.key = casted
            }
        case "changes":
            if let casted = value as? String {
                changes = casted
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
        case "elapsed":
            return elapsed
        case "key":
            return self.key
        case "changes":
            return changes
        default:
            return try super.getExposedValueForKey(key)
        }
    }

    // MARK: - Initializable

    public required init() {
        super.init()
    }
}
