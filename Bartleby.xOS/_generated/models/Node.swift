//
//  Node.swift
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

// MARK: Bartleby's Synchronized File System: a node references a collection of blocks that compose a files, or an alias or a folder
@objc open class Node : ManagedModel{

    // Universal type support
    override open class func typeName() -> String {
        return "Node"
    }

	//The type of node is a classifier equivalent to a file extension.
	@objc dynamic open var type:String = "" {
	    didSet { 
	       if !self.wantsQuietChanges && type != oldValue {
	            self.provisionChanges(forKey: "type",oldValue: oldValue,newValue: type) 
	       } 
	    }
	}

	//The relative path inside the box
	@objc dynamic open var relativePath:String = Default.NO_PATH

	//A relative path for a proxy file (And the resolved path if nature==.alias)
	@objc dynamic open var proxyPath:String?

	//The max size of a block (defines the average size of the block last block excluded)
	@objc dynamic open var blocksMaxSize:Int = Default.MAX_INT

	//The total number of blocks
	@objc dynamic open var numberOfBlocks:Int = 0

	//The priority level of the node (is applicated to its block)
	@objc dynamic open var priority:Int = 0

	//The node nature
	public enum Nature:String{
		case file = "file"
		case folder = "folder"
		case alias = "alias"
		case flock = "flock"
	}
	open var nature:Nature = .file

	//Can be extracted from FileAttributeKey.modificationDate
	@objc dynamic open var modificationDate:Date?

	//Can be extracted from FileAttributeKey.creationDate
	@objc dynamic open var creationDate:Date?

	//If nature is .alias the UID of the referent node, else can be set to self.UID or not set at all
	@objc dynamic open var referentNodeUID:String?

	//The list of the authorized User.UID,(if set to ["*"] the block is reputed public). Replicated in any Block to allow pre-downloading during node Upload
	@objc dynamic open var authorized:[String] = [String]()

	//The size of the file
	@objc dynamic open var size:Int = Default.MAX_INT

	//The SHA1 digest of the node is the digest of all its blocks digest.
	@objc dynamic open var digest:String = Default.NO_DIGEST {
	    didSet { 
	       if !self.wantsQuietChanges && digest != oldValue {
	            self.provisionChanges(forKey: "digest",oldValue: oldValue,newValue: digest) 
	       } 
	    }
	}

	//If set to true the blocks should be compressed (using LZ4)
	@objc dynamic open var compressedBlocks:Bool = true

	//If set to true the blocks will be crypted (using AES256)
	@objc dynamic open var cryptedBlocks:Bool = true

	//The upload Progression State (not serializable, not supervisable directly by : self.addChangesSuperviser use self.uploadProgression.addChangesSuperviser)
	@objc dynamic open var uploadProgression:Progression = Progression()

	//The Download Progression State (not serializable, not supervisable directly by : self.addChangesSuperviser use self.downloadProgression.addChangesSuperviser)
	@objc dynamic open var downloadProgression:Progression = Progression()

	//Turned to true if there is an upload in progress (used for progress consolidation optimization)
	@objc dynamic open var uploadInProgress:Bool = false

	//Turned to true if there is an upload in progress (used for progress consolidation optimization)
	@objc dynamic open var downloadInProgress:Bool = false

	//Turned to true if there is an Assembly in progress (used for progress consolidation optimization)
	@objc dynamic open var assemblyInProgress:Bool = false


    // MARK: - Codable


    public enum NodeCodingKeys: String,CodingKey{
		case type
		case relativePath
		case proxyPath
		case blocksMaxSize
		case numberOfBlocks
		case priority
		case nature
		case modificationDate
		case creationDate
		case referentNodeUID
		case authorized
		case size
		case digest
		case compressedBlocks
		case cryptedBlocks
		case uploadProgression
		case downloadProgression
		case uploadInProgress
		case downloadInProgress
		case assemblyInProgress
    }

    required public init(from decoder: Decoder) throws{
		try super.init(from: decoder)
        try self.quietThrowingChanges {
			let values = try decoder.container(keyedBy: NodeCodingKeys.self)
			self.type = try values.decode(String.self,forKey:.type)
			self.relativePath = try values.decode(String.self,forKey:.relativePath)
			self.proxyPath = try values.decodeIfPresent(String.self,forKey:.proxyPath)
			self.blocksMaxSize = try values.decode(Int.self,forKey:.blocksMaxSize)
			self.numberOfBlocks = try values.decode(Int.self,forKey:.numberOfBlocks)
			self.priority = try values.decode(Int.self,forKey:.priority)
			self.nature = Node.Nature(rawValue: try values.decode(String.self,forKey:.nature)) ?? .file
			self.modificationDate = try values.decodeIfPresent(Date.self,forKey:.modificationDate)
			self.creationDate = try values.decodeIfPresent(Date.self,forKey:.creationDate)
			self.referentNodeUID = try values.decodeIfPresent(String.self,forKey:.referentNodeUID)
			self.authorized = try values.decode([String].self,forKey:.authorized)
			self.size = try values.decode(Int.self,forKey:.size)
			self.digest = try values.decode(String.self,forKey:.digest)
			self.compressedBlocks = try values.decode(Bool.self,forKey:.compressedBlocks)
			self.cryptedBlocks = try values.decode(Bool.self,forKey:.cryptedBlocks)
        }
    }

    override open func encode(to encoder: Encoder) throws {
		try super.encode(to:encoder)
		var container = encoder.container(keyedBy: NodeCodingKeys.self)
		try container.encode(self.type,forKey:.type)
		try container.encode(self.relativePath,forKey:.relativePath)
		try container.encodeIfPresent(self.proxyPath,forKey:.proxyPath)
		try container.encode(self.blocksMaxSize,forKey:.blocksMaxSize)
		try container.encode(self.numberOfBlocks,forKey:.numberOfBlocks)
		try container.encode(self.priority,forKey:.priority)
		try container.encode(self.nature.rawValue ,forKey:.nature)
		try container.encodeIfPresent(self.modificationDate,forKey:.modificationDate)
		try container.encodeIfPresent(self.creationDate,forKey:.creationDate)
		try container.encodeIfPresent(self.referentNodeUID,forKey:.referentNodeUID)
		try container.encode(self.authorized,forKey:.authorized)
		try container.encode(self.size,forKey:.size)
		try container.encode(self.digest,forKey:.digest)
		try container.encode(self.compressedBlocks,forKey:.compressedBlocks)
		try container.encode(self.cryptedBlocks,forKey:.cryptedBlocks)
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override  open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["type","relativePath","proxyPath","blocksMaxSize","numberOfBlocks","priority","nature","modificationDate","creationDate","referentNodeUID","authorized","size","digest","compressedBlocks","cryptedBlocks","uploadProgression","downloadProgression","uploadInProgress","downloadInProgress","assemblyInProgress"])
        return exposed
    }


    /// Set the value of the given key
    ///
    /// - parameter value: the value
    /// - parameter key:   the key
    ///
    /// - throws: throws an Exception when the key is not exposed
    override  open func setExposedValue(_ value:Any?, forKey key: String) throws {
        switch key {
            case "type":
                if let casted=value as? String{
                    self.type=casted
                }
            case "relativePath":
                if let casted=value as? String{
                    self.relativePath=casted
                }
            case "proxyPath":
                if let casted=value as? String{
                    self.proxyPath=casted
                }
            case "blocksMaxSize":
                if let casted=value as? Int{
                    self.blocksMaxSize=casted
                }
            case "numberOfBlocks":
                if let casted=value as? Int{
                    self.numberOfBlocks=casted
                }
            case "priority":
                if let casted=value as? Int{
                    self.priority=casted
                }
            case "nature":
                if let casted=value as? Node.Nature{
                    self.nature=casted
                }
            case "modificationDate":
                if let casted=value as? Date{
                    self.modificationDate=casted
                }
            case "creationDate":
                if let casted=value as? Date{
                    self.creationDate=casted
                }
            case "referentNodeUID":
                if let casted=value as? String{
                    self.referentNodeUID=casted
                }
            case "authorized":
                if let casted=value as? [String]{
                    self.authorized=casted
                }
            case "size":
                if let casted=value as? Int{
                    self.size=casted
                }
            case "digest":
                if let casted=value as? String{
                    self.digest=casted
                }
            case "compressedBlocks":
                if let casted=value as? Bool{
                    self.compressedBlocks=casted
                }
            case "cryptedBlocks":
                if let casted=value as? Bool{
                    self.cryptedBlocks=casted
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
            case "assemblyInProgress":
                if let casted=value as? Bool{
                    self.assemblyInProgress=casted
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
    override  open func getExposedValueForKey(_ key:String) throws -> Any?{
        switch key {
            case "type":
               return self.type
            case "relativePath":
               return self.relativePath
            case "proxyPath":
               return self.proxyPath
            case "blocksMaxSize":
               return self.blocksMaxSize
            case "numberOfBlocks":
               return self.numberOfBlocks
            case "priority":
               return self.priority
            case "nature":
               return self.nature
            case "modificationDate":
               return self.modificationDate
            case "creationDate":
               return self.creationDate
            case "referentNodeUID":
               return self.referentNodeUID
            case "authorized":
               return self.authorized
            case "size":
               return self.size
            case "digest":
               return self.digest
            case "compressedBlocks":
               return self.compressedBlocks
            case "cryptedBlocks":
               return self.cryptedBlocks
            case "uploadProgression":
               return self.uploadProgression
            case "downloadProgression":
               return self.downloadProgression
            case "uploadInProgress":
               return self.uploadInProgress
            case "downloadInProgress":
               return self.downloadInProgress
            case "assemblyInProgress":
               return self.assemblyInProgress
            default:
                return try super.getExposedValueForKey(key)
        }
    }
    // MARK: - Initializable
    required public init() {
        super.init()
    }

    // MARK: - UniversalType
    override  open class var collectionName:String{
        return "nodes"
    }

    override  open var d_collectionName:String{
        return Node.collectionName
    }
}