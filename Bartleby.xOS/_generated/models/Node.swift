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
	import Alamofire
	import ObjectMapper
#endif

// MARK: Bartleby's Synchronized File System: a node references a collection of blocks that compose a files, or an alias or a folder
@objc(Node) open class Node : ManagedModel{

    // Universal type support
    override open class func typeName() -> String {
        return "Node"
    }

	//The type of node is a classifier equivalent to a file extension.
	dynamic open var type:String = ""{
	    didSet { 
	       if !self.wantsQuietChanges && type != oldValue {
	            self.provisionChanges(forKey: "type",oldValue: oldValue,newValue: type) 
	       } 
	    }
	}

	//The relative path inside the box
	dynamic open var relativePath:String = "\(Default.NO_PATH)"

	//A relative path for a proxy file (And the resolved path if nature==.alias)
	dynamic open var proxyPath:String?

	//The max size of a block (defines the average size of the block last block excluded)
	dynamic open var blocksMaxSize:Int = Default.MAX_INT

	//The total number of blocks
	dynamic open var numberOfBlocks:Int = 0

	//The priority level of the node (is applicated to its block)
	dynamic open var priority:Int = 0

	//The node nature
	public enum Nature:String{
		case file = "file"
		case folder = "folder"
		case alias = "alias"
		case flock = "flock"
	}
	open var nature:Nature = .file

	//Can be extracted from FileAttributeKey.modificationDate
	dynamic open var modificationDate:Date?

	//Can be extracted from FileAttributeKey.creationDate
	dynamic open var creationDate:Date?

	//If nature is .alias the UID of the referent node, else can be set to self.UID or not set at all
	dynamic open var referentNodeUID:String?

	//The list of the authorized User.UID,(if set to ["*"] the block is reputed public). Replicated in any Block to allow pre-downloading during node Upload
	dynamic open var authorized:[String] = [String]()

	//The size of the file
	dynamic open var size:Int = Default.MAX_INT

	//The SHA1 digest of the node is the digest of all its blocks digest.
	dynamic open var digest:String = "\(Default.NO_DIGEST)"{
	    didSet { 
	       if !self.wantsQuietChanges && digest != oldValue {
	            self.provisionChanges(forKey: "digest",oldValue: oldValue,newValue: digest) 
	       } 
	    }
	}

	//If set to true the blocks should be compressed (using LZ4)
	dynamic open var compressedBlocks:Bool = true

	//If set to true the blocks will be crypted (using AES256)
	dynamic open var cryptedBlocks:Bool = true

	//The upload Progression State (not serializable, not supervisable directly by : self.addChangesSuperviser use self.uploadProgression.addChangesSuperviser)
	dynamic open var uploadProgression:Progression = Progression()

	//The Download Progression State (not serializable, not supervisable directly by : self.addChangesSuperviser use self.downloadProgression.addChangesSuperviser)
	dynamic open var downloadProgression:Progression = Progression()

	//Turned to true if there is an upload in progress (used for progress consolidation optimization)
	dynamic open var uploadInProgress:Bool = false

	//Turned to true if there is an upload in progress (used for progress consolidation optimization)
	dynamic open var downloadInProgress:Bool = false

	//Turned to true if there is an Assembly in progress (used for progress consolidation optimization)
	dynamic open var assemblyInProgress:Bool = false

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
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
    override open func setExposedValue(_ value:Any?, forKey key: String) throws {
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
    override open func getExposedValueForKey(_ key:String) throws -> Any?{
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
    // MARK: - Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }

    override open func mapping(map: Map) {
        super.mapping(map: map)
        self.quietChanges {
			self.type <- ( map["type"] )
			self.relativePath <- ( map["relativePath"] )
			self.proxyPath <- ( map["proxyPath"] )
			self.blocksMaxSize <- ( map["blocksMaxSize"] )
			self.numberOfBlocks <- ( map["numberOfBlocks"] )
			self.priority <- ( map["priority"] )
			self.nature <- ( map["nature"] )
			self.modificationDate <- ( map["modificationDate"], ISO8601DateTransform() )
			self.creationDate <- ( map["creationDate"], ISO8601DateTransform() )
			self.referentNodeUID <- ( map["referentNodeUID"] )
			self.authorized <- ( map["authorized"] )// @todo marked generatively as Cryptable Should be crypted!
			self.size <- ( map["size"] )
			self.digest <- ( map["digest"] )
			self.compressedBlocks <- ( map["compressedBlocks"] )
			self.cryptedBlocks <- ( map["cryptedBlocks"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.quietChanges {
			self.type=String(describing: decoder.decodeObject(of: NSString.self, forKey: "type")! as NSString)
			self.relativePath=String(describing: decoder.decodeObject(of: NSString.self, forKey: "relativePath")! as NSString)
			self.proxyPath=String(describing: decoder.decodeObject(of: NSString.self, forKey:"proxyPath") as NSString?)
			self.blocksMaxSize=decoder.decodeInteger(forKey:"blocksMaxSize") 
			self.numberOfBlocks=decoder.decodeInteger(forKey:"numberOfBlocks") 
			self.priority=decoder.decodeInteger(forKey:"priority") 
			self.nature=Node.Nature(rawValue:String(describing: decoder.decodeObject(of: NSString.self, forKey: "nature")! as NSString))! 
			self.modificationDate=decoder.decodeObject(of: NSDate.self , forKey:"modificationDate") as Date?
			self.creationDate=decoder.decodeObject(of: NSDate.self , forKey:"creationDate") as Date?
			self.referentNodeUID=String(describing: decoder.decodeObject(of: NSString.self, forKey:"referentNodeUID") as NSString?)
			self.authorized=decoder.decodeObject(of: [NSArray.classForCoder(),NSString.self], forKey: "authorized")! as! [String]
			self.size=decoder.decodeInteger(forKey:"size") 
			self.digest=String(describing: decoder.decodeObject(of: NSString.self, forKey: "digest")! as NSString)
			self.compressedBlocks=decoder.decodeBool(forKey:"compressedBlocks") 
			self.cryptedBlocks=decoder.decodeBool(forKey:"cryptedBlocks") 
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self.type,forKey:"type")
		coder.encode(self.relativePath,forKey:"relativePath")
		if let proxyPath = self.proxyPath {
			coder.encode(proxyPath,forKey:"proxyPath")
		}
		coder.encode(self.blocksMaxSize,forKey:"blocksMaxSize")
		coder.encode(self.numberOfBlocks,forKey:"numberOfBlocks")
		coder.encode(self.priority,forKey:"priority")
		coder.encode(self.nature.rawValue ,forKey:"nature")
		if let modificationDate = self.modificationDate {
			coder.encode(modificationDate,forKey:"modificationDate")
		}
		if let creationDate = self.creationDate {
			coder.encode(creationDate,forKey:"creationDate")
		}
		if let referentNodeUID = self.referentNodeUID {
			coder.encode(referentNodeUID,forKey:"referentNodeUID")
		}
		coder.encode(self.authorized,forKey:"authorized")
		coder.encode(self.size,forKey:"size")
		coder.encode(self.digest,forKey:"digest")
		coder.encode(self.compressedBlocks,forKey:"compressedBlocks")
		coder.encode(self.cryptedBlocks,forKey:"cryptedBlocks")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

     required public init() {
        super.init()
    }

    override open class var collectionName:String{
        return "nodes"
    }

    override open var d_collectionName:String{
        return Node.collectionName
    }
}