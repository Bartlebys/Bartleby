//
//  BsyncDMGCard.swift
//  Bsync
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for Benoit Pereira da Silva https://pereira-da-silva.com/contact
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  Bartleby's https://bartlebys.org   All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
	import Alamofire
	import ObjectMapper
	import BartlebyKit
#endif

// MARK: A DMG card enable store the data required to unlock the DMG.
@objc(BsyncDMGCard) open class BsyncDMGCard : BartlebyObject{

    // Universal type support
    override open class func typeName() -> String {
        return "BsyncDMGCard"
    }

	static open let NO_PATH:String = "none"

	static open let NOT_SET:String = "not-set"

	static open let DMG_EXTENSION:String = "sparseimage"

	//The user Unique Identifier
	dynamic open var userUID:String = "\(BsyncDMGCard.NOT_SET)"{
	 
	    didSet { 
	       if userUID != oldValue {
	            self.provisionChanges(forKey: "userUID",oldValue: oldValue,newValue: userUID) 
	       } 
	    }
	}

	//Associated to a context (e.g. project UID)
	dynamic open var contextUID:String = "\(BsyncDMGCard.NOT_SET)"{
	 
	    didSet { 
	       if contextUID != oldValue {
	            self.provisionChanges(forKey: "contextUID",oldValue: oldValue,newValue: contextUID) 
	       } 
	    }
	}

	//The last kwnow path (if not correct the client should ask for a path  The full path including the ".sparseimage" extension.
	dynamic open var imagePath:String = "\(BsyncDMGCard.NO_PATH)"{
	 
	    didSet { 
	       if imagePath != oldValue {
	            self.provisionChanges(forKey: "imagePath",oldValue: oldValue,newValue: imagePath) 
	       } 
	    }
	}

	//The associated volumeName
	dynamic open var volumeName:String = "\(BsyncDMGCard.NOT_SET)"{
	 
	    didSet { 
	       if volumeName != oldValue {
	            self.provisionChanges(forKey: "volumeName",oldValue: oldValue,newValue: volumeName) 
	       } 
	    }
	}

	// You can provide an optionnal sync directive path
	dynamic open var directivesRelativePath:String = "\(BsyncDMGCard.NO_PATH)"{
	 
	    didSet { 
	       if directivesRelativePath != oldValue {
	            self.provisionChanges(forKey: "directivesRelativePath",oldValue: oldValue,newValue: directivesRelativePath) 
	       } 
	    }
	}

	//The size of the disk image : "1g" == 1 GB 
	dynamic open var size:String = "10g"{
	 
	    didSet { 
	       if size != oldValue {
	            self.provisionChanges(forKey: "size",oldValue: oldValue,newValue: size) 
	       } 
	    }
	}

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["userUID","contextUID","imagePath","volumeName","directivesRelativePath","size"])
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
            case "userUID":
                if let casted=value as? String{
                    self.userUID=casted
                }
            case "contextUID":
                if let casted=value as? String{
                    self.contextUID=casted
                }
            case "imagePath":
                if let casted=value as? String{
                    self.imagePath=casted
                }
            case "volumeName":
                if let casted=value as? String{
                    self.volumeName=casted
                }
            case "directivesRelativePath":
                if let casted=value as? String{
                    self.directivesRelativePath=casted
                }
            case "size":
                if let casted=value as? String{
                    self.size=casted
                }
            default:
                throw ObjectExpositionError.UnknownKey(key: key,forTypeName: BsyncDMGCard.typeName())
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
            case "userUID":
               return self.userUID
            case "contextUID":
               return self.contextUID
            case "imagePath":
               return self.imagePath
            case "volumeName":
               return self.volumeName
            case "directivesRelativePath":
               return self.directivesRelativePath
            case "size":
               return self.size
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
        self.silentGroupedChanges {
			self.userUID <- ( map["userUID"] )
			self.contextUID <- ( map["contextUID"] )
			self.imagePath <- ( map["imagePath"] )
			self.volumeName <- ( map["volumeName"] )
			self.directivesRelativePath <- ( map["directivesRelativePath"] )
			self.size <- ( map["size"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {super.init(coder: decoder)
        self.silentGroupedChanges {
			self.userUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "userUID")! as NSString)
			self.contextUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "contextUID")! as NSString)
			self.imagePath=String(describing: decoder.decodeObject(of: NSString.self, forKey: "imagePath")! as NSString)
			self.volumeName=String(describing: decoder.decodeObject(of: NSString.self, forKey: "volumeName")! as NSString)
			self.directivesRelativePath=String(describing: decoder.decodeObject(of: NSString.self, forKey: "directivesRelativePath")! as NSString)
			self.size=String(describing: decoder.decodeObject(of: NSString.self, forKey: "size")! as NSString)
        }
    }

    override open func encode(with coder: NSCoder) {super.encode(with:coder)
		coder.encode(self.userUID,forKey:"userUID")
		coder.encode(self.contextUID,forKey:"contextUID")
		coder.encode(self.imagePath,forKey:"imagePath")
		coder.encode(self.volumeName,forKey:"volumeName")
		coder.encode(self.directivesRelativePath,forKey:"directivesRelativePath")
		coder.encode(self.size,forKey:"size")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

     required public init() {
        super.init()
    }

    // MARK: Identifiable

    override open class var collectionName:String{
        return "bsyncDMGCards"
    }

    override open var d_collectionName:String{
        return BsyncDMGCard.collectionName
    }
}