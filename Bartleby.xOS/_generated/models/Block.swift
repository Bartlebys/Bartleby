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
	import Alamofire
	import ObjectMapper
#endif

// MARK: Bartleby's Synchronized File System: a block references bytes
@objc(Block) open class Block : ManagedModel{

    // Universal type support
    override open class func typeName() -> String {
        return "Block"
    }

	//The SHA1 digest of the block
	dynamic open var digest:String = "\(Default.NO_DIGEST)"{
	    didSet { 
	       if !self.wantsQuietChanges && digest != oldValue {
	            self.provisionChanges(forKey: "digest",oldValue: oldValue,newValue: digest) 
	       } 
	    }
	}

	//The rank of the Block in the node
	dynamic open var rank:Int = 0

	//The starting bytes of the block in the Node (== the position of the block in the file)
	dynamic open var startsAt:Int = 0

	//The size of the Block
	dynamic open var size:Int = Default.MAX_INT

	//The priority level of the block (higher priority produces the block to be synchronized before the lower priority blocks)
	dynamic open var priority:Int = 0

	//If set to true the blocks should be compressed (using LZ4)
	dynamic open var compressed:Bool = true

	//If set to true the blocks will be crypted (using AES256)
	dynamic open var crypted:Bool = true

	//The upload Progression State (not serializable, not supervisable directly by : self.addChangesSuperviser use self.uploadProgression.addChangesSuperviser)
	dynamic open var uploadProgression:Progression = Progression()

	//The Download Progression State (not serializable, not supervisable directly by : self.addChangesSuperviser use self.downloadProgression.addChangesSuperviser)
	dynamic open var downloadProgression:Progression = Progression()

	//Turned to true if there is an upload in progress (used for progress consolidation optimization)
	dynamic open var uploadInProgress:Bool = false

	//Turned to true if there is an upload in progress (used for progress consolidation optimization)
	dynamic open var downloadInProgress:Bool = false

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["digest","rank","startsAt","size","priority","compressed","crypted","uploadProgression","downloadProgression","uploadInProgress","downloadInProgress"])
        return exposed
    }


    /// Set the value of the given key
    ///
    /// - parameter value: the value
    /// - parameter key:   the key
    ///
    /// - throws: throws an Exception when the key is not exposed
    override open func setExposedValue(_ value:Any?, forKey key: String) throws {
        switch key {
            case "digest":
                if let casted=value as? String{
                    self.digest=casted
                }
            case "rank":
                if let casted=value as? Int{
                    self.rank=casted
                }
            case "startsAt":
                if let casted=value as? Int{
                    self.startsAt=casted
                }
            case "size":
                if let casted=value as? Int{
                    self.size=casted
                }
            case "priority":
                if let casted=value as? Int{
                    self.priority=casted
                }
            case "compressed":
                if let casted=value as? Bool{
                    self.compressed=casted
                }
            case "crypted":
                if let casted=value as? Bool{
                    self.crypted=casted
                }
            case "uploadProgression":
                if let casted=value as? Progression{
                    self.uploadProgression=casted
                }
            case "downloadProgression":
                if let casted=value as? Progression{
                    self.downloadProgression=casted
                }
            case "uploadInProgress":
                if let casted=value as? Bool{
                    self.uploadInProgress=casted
                }
            case "downloadInProgress":
                if let casted=value as? Bool{
                    self.downloadInProgress=casted
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
    override open func getExposedValueForKey(_ key:String) throws -> Any?{
        switch key {
            case "digest":
               return self.digest
            case "rank":
               return self.rank
            case "startsAt":
               return self.startsAt
            case "size":
               return self.size
            case "priority":
               return self.priority
            case "compressed":
               return self.compressed
            case "crypted":
               return self.crypted
            case "uploadProgression":
               return self.uploadProgression
            case "downloadProgression":
               return self.downloadProgression
            case "uploadInProgress":
               return self.uploadInProgress
            case "downloadInProgress":
               return self.downloadInProgress
            default:
                return try super.getExposedValueForKey(key)
        }
    }
    // MARK: - Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }

    override open func mapping(map: Map) {
        super.mapping(map: map)
        self.quietChanges {
			self.digest <- ( map["digest"] )
			self.rank <- ( map["rank"] )
			self.startsAt <- ( map["startsAt"] )
			self.size <- ( map["size"] )
			self.priority <- ( map["priority"] )
			self.compressed <- ( map["compressed"] )
			self.crypted <- ( map["crypted"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.quietChanges {
			self.digest=String(describing: decoder.decodeObject(of: NSString.self, forKey: "digest")! as NSString)
			self.rank=decoder.decodeInteger(forKey:"rank") 
			self.startsAt=decoder.decodeInteger(forKey:"startsAt") 
			self.size=decoder.decodeInteger(forKey:"size") 
			self.priority=decoder.decodeInteger(forKey:"priority") 
			self.compressed=decoder.decodeBool(forKey:"compressed") 
			self.crypted=decoder.decodeBool(forKey:"crypted") 
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self.digest,forKey:"digest")
		coder.encode(self.rank,forKey:"rank")
		coder.encode(self.startsAt,forKey:"startsAt")
		coder.encode(self.size,forKey:"size")
		coder.encode(self.priority,forKey:"priority")
		coder.encode(self.compressed,forKey:"compressed")
		coder.encode(self.crypted,forKey:"crypted")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

     required public init() {
        super.init()
    }

    override open class var collectionName:String{
        return "blocks"
    }

    override open var d_collectionName:String{
        return Block.collectionName
    }
}