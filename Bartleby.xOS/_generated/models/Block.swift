//
//  Block.swift
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

// MARK: Bartleby's Synchronized File System: a block references bytes

@objc open class Block: ManagedModel {
    // Universal type support
    open override class func typeName() -> String {
        return "Block"
    }

    // The SHA1 digest of the block
    @objc open dynamic var digest: String = Default.NO_DIGEST {
        didSet {
            if !self.wantsQuietChanges && digest != oldValue {
                self.provisionChanges(forKey: "digest", oldValue: oldValue, newValue: digest)
            }
        }
    }

    // The rank of the Block in the node
    @objc open dynamic var rank: Int = 0

    // The starting bytes of the block in the Node (== the position of the block in the file)
    @objc open dynamic var startsAt: Int = 0

    // The size of the Block
    @objc open dynamic var size: Int = Default.MAX_INT

    // The priority level of the block (higher priority produces the block to be synchronized before the lower priority blocks)
    @objc open dynamic var priority: Int = 0

    // If set to true the blocks should be compressed (using LZ4)
    @objc open dynamic var compressed: Bool = true

    // If set to true the blocks will be crypted (using AES256)
    @objc open dynamic var crypted: Bool = true

    // The upload Progression State (not serializable, not supervisable directly by : self.addChangesSuperviser use self.uploadProgression.addChangesSuperviser)
    @objc open dynamic var uploadProgression: Progression = Progression()

    // The Download Progression State (not serializable, not supervisable directly by : self.addChangesSuperviser use self.downloadProgression.addChangesSuperviser)
    @objc open dynamic var downloadProgression: Progression = Progression()

    // Turned to true if there is an upload in progress (used for progress consolidation optimization)
    @objc open dynamic var uploadInProgress: Bool = false

    // Turned to true if there is an upload in progress (used for progress consolidation optimization)
    @objc open dynamic var downloadInProgress: Bool = false

    // MARK: - Codable

    public enum BlockCodingKeys: String, CodingKey {
        case digest
        case rank
        case startsAt
        case size
        case priority
        case compressed
        case crypted
        case uploadProgression
        case downloadProgression
        case uploadInProgress
        case downloadInProgress
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        try quietThrowingChanges {
            let values = try decoder.container(keyedBy: BlockCodingKeys.self)
            self.digest = try values.decode(String.self, forKey: .digest)
            self.rank = try values.decode(Int.self, forKey: .rank)
            self.startsAt = try values.decode(Int.self, forKey: .startsAt)
            self.size = try values.decode(Int.self, forKey: .size)
            self.priority = try values.decode(Int.self, forKey: .priority)
            self.compressed = try values.decode(Bool.self, forKey: .compressed)
            self.crypted = try values.decode(Bool.self, forKey: .crypted)
        }
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: BlockCodingKeys.self)
        try container.encode(digest, forKey: .digest)
        try container.encode(rank, forKey: .rank)
        try container.encode(startsAt, forKey: .startsAt)
        try container.encode(size, forKey: .size)
        try container.encode(priority, forKey: .priority)
        try container.encode(compressed, forKey: .compressed)
        try container.encode(crypted, forKey: .crypted)
    }

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    open override var exposedKeys: [String] {
        var exposed = super.exposedKeys
        exposed.append(contentsOf: ["digest", "rank", "startsAt", "size", "priority", "compressed", "crypted", "uploadProgression", "downloadProgression", "uploadInProgress", "downloadInProgress"])
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
        case "digest":
            if let casted = value as? String {
                digest = casted
            }
        case "rank":
            if let casted = value as? Int {
                rank = casted
            }
        case "startsAt":
            if let casted = value as? Int {
                startsAt = casted
            }
        case "size":
            if let casted = value as? Int {
                size = casted
            }
        case "priority":
            if let casted = value as? Int {
                priority = casted
            }
        case "compressed":
            if let casted = value as? Bool {
                compressed = casted
            }
        case "crypted":
            if let casted = value as? Bool {
                crypted = casted
            }
        case "uploadProgression":
            if let casted = value as? Progression {
                uploadProgression = casted
            }
        case "downloadProgression":
            if let casted = value as? Progression {
                downloadProgression = casted
            }
        case "uploadInProgress":
            if let casted = value as? Bool {
                uploadInProgress = casted
            }
        case "downloadInProgress":
            if let casted = value as? Bool {
                downloadInProgress = casted
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
        case "digest":
            return digest
        case "rank":
            return rank
        case "startsAt":
            return startsAt
        case "size":
            return size
        case "priority":
            return priority
        case "compressed":
            return compressed
        case "crypted":
            return crypted
        case "uploadProgression":
            return uploadProgression
        case "downloadProgression":
            return downloadProgression
        case "uploadInProgress":
            return uploadInProgress
        case "downloadInProgress":
            return downloadInProgress
        default:
            return try super.getExposedValueForKey(key)
        }
    }

    // MARK: - Initializable

    public required init() {
        super.init()
    }

    // MARK: - UniversalType

    open override class var collectionName: String {
        return "blocks"
    }

    open override var d_collectionName: String {
        return Block.collectionName
    }
}
