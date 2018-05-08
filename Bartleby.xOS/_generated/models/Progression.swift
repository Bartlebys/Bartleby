//
//  Progression.swift
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

// MARK: Bartleby's Commons: A progression state

@objc open class Progression: UnManagedModel {
    // DeclaredTypeName support
    open override class func typeName() -> String {
        return "Progression"
    }

    // The start time of the progression state
    open var startTime: Double?

    // Index of the task
    @objc open dynamic var currentTaskIndex: Int = 0

    // Total number of tasks
    @objc open dynamic var totalTaskCount: Int = 0

    // 0 to 100
    @objc open dynamic var currentPercentProgress: Double = 0

    // The Message
    @objc open dynamic var message: String = ""

    // The consolidated information (may include the message)
    @objc open dynamic var informations: String = ""

    // The associated data
    @objc open dynamic var data: Data?

    // A category to discriminate bunch of progression states
    @objc open dynamic var category: String = ""

    // An external identifier
    @objc open dynamic var externalIdentifier: String = ""

    // MARK: - Codable

    public enum ProgressionCodingKeys: String, CodingKey {
        case startTime
        case currentTaskIndex
        case totalTaskCount
        case currentPercentProgress
        case message
        case informations
        case data
        case category
        case externalIdentifier
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        try quietThrowingChanges {
            let values = try decoder.container(keyedBy: ProgressionCodingKeys.self)
            self.startTime = try values.decodeIfPresent(Double.self, forKey: .startTime)
            self.currentTaskIndex = try values.decode(Int.self, forKey: .currentTaskIndex)
            self.totalTaskCount = try values.decode(Int.self, forKey: .totalTaskCount)
            self.currentPercentProgress = try values.decode(Double.self, forKey: .currentPercentProgress)
            self.message = try values.decode(String.self, forKey: .message)
            self.informations = try values.decode(String.self, forKey: .informations)
            self.data = try values.decodeIfPresent(Data.self, forKey: .data)
            self.category = try values.decode(String.self, forKey: .category)
            self.externalIdentifier = try values.decode(String.self, forKey: .externalIdentifier)
        }
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: ProgressionCodingKeys.self)
        try container.encodeIfPresent(startTime, forKey: .startTime)
        try container.encode(currentTaskIndex, forKey: .currentTaskIndex)
        try container.encode(totalTaskCount, forKey: .totalTaskCount)
        try container.encode(currentPercentProgress, forKey: .currentPercentProgress)
        try container.encode(message, forKey: .message)
        try container.encode(informations, forKey: .informations)
        try container.encodeIfPresent(data, forKey: .data)
        try container.encode(category, forKey: .category)
        try container.encode(externalIdentifier, forKey: .externalIdentifier)
    }

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    open override var exposedKeys: [String] {
        var exposed = super.exposedKeys
        exposed.append(contentsOf: ["startTime", "currentTaskIndex", "totalTaskCount", "currentPercentProgress", "message", "informations", "data", "category", "externalIdentifier"])
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
        case "startTime":
            if let casted = value as? Double {
                startTime = casted
            }
        case "currentTaskIndex":
            if let casted = value as? Int {
                currentTaskIndex = casted
            }
        case "totalTaskCount":
            if let casted = value as? Int {
                totalTaskCount = casted
            }
        case "currentPercentProgress":
            if let casted = value as? Double {
                currentPercentProgress = casted
            }
        case "message":
            if let casted = value as? String {
                message = casted
            }
        case "informations":
            if let casted = value as? String {
                informations = casted
            }
        case "data":
            if let casted = value as? Data {
                data = casted
            }
        case "category":
            if let casted = value as? String {
                category = casted
            }
        case "externalIdentifier":
            if let casted = value as? String {
                externalIdentifier = casted
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
        case "startTime":
            return startTime
        case "currentTaskIndex":
            return currentTaskIndex
        case "totalTaskCount":
            return totalTaskCount
        case "currentPercentProgress":
            return currentPercentProgress
        case "message":
            return message
        case "informations":
            return informations
        case "data":
            return data
        case "category":
            return category
        case "externalIdentifier":
            return externalIdentifier
        default:
            return try super.getExposedValueForKey(key)
        }
    }

    // MARK: - Initializable

    public required init() {
        super.init()
    }
}
