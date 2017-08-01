//
//  Box.swift
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
#endif

// MARK: Bartleby's Synchronized File System: A box is a logical reference for Nodes and Blocks
@objc(Box) open class Box : ManagedModel{

    // Universal type support
    override open class func typeName() -> String {
        return "Box"
    }

	//Turned to true when the box is mounted (not serializable, not supervisable)
	@objc dynamic open var isMounted:Bool = false

	//Turned to true if there is an Assembly in progress (used for progress consolidation optimization)
	@objc dynamic open var assemblyInProgress:Bool = false

	//A volatile box is unmounted automatically
	@objc dynamic open var volatile:Bool = true

	//The upload Progression State (not serializable, not supervisable directly by : self.addChangesSuperviser use self.uploadProgression.addChangesSuperviser)
	@objc dynamic open var uploadProgression:Progression = Progression()

	//The Download Progression State (not serializable, not supervisable directly by : self.addChangesSuperviser use self.downloadProgression.addChangesSuperviser)
	@objc dynamic open var downloadProgression:Progression = Progression()

	//The Assembly Progression State (not serializable, not supervisable directly by : self.addChangesSuperviser use self.downloadProgression.addChangesSuperviser)
	@objc dynamic open var assemblyProgression:Progression = Progression()

	//Turned to true if there is an upload in progress (used for progress consolidation optimization)
	@objc dynamic open var uploadInProgress:Bool = false

	//Turned to true if there is an upload in progress (used for progress consolidation optimization)
	@objc dynamic open var downloadInProgress:Bool = false


    // MARK: - Codable


    enum BoxCodingKeys: String,CodingKey{
		case isMounted
		case assemblyInProgress
		case volatile
		case uploadProgression
		case downloadProgression
		case assemblyProgression
		case uploadInProgress
		case downloadInProgress
    }

    required public init(from decoder: Decoder) throws{
		try super.init(from: decoder)
        try self.quietThrowingChanges {
			let values = try decoder.container(keyedBy: BoxCodingKeys.self)
        }
    }

    override open func encode(to encoder: Encoder) throws {
		try super.encode(to:encoder)
		var container = encoder.container(keyedBy: BoxCodingKeys.self)
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override  open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["isMounted","assemblyInProgress","volatile","uploadProgression","downloadProgression","assemblyProgression","uploadInProgress","downloadInProgress"])
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
            case "isMounted":
                if let casted=value as? Bool{
                    self.isMounted=casted
                }
            case "assemblyInProgress":
                if let casted=value as? Bool{
                    self.assemblyInProgress=casted
                }
            case "volatile":
                if let casted=value as? Bool{
                    self.volatile=casted
                }
            case "uploadProgression":
                if let casted=value as? Progression{
                    self.uploadProgression=casted
                }
            case "downloadProgression":
                if let casted=value as? Progression{
                    self.downloadProgression=casted
                }
            case "assemblyProgression":
                if let casted=value as? Progression{
                    self.assemblyProgression=casted
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
    override  open func getExposedValueForKey(_ key:String) throws -> Any?{
        switch key {
            case "isMounted":
               return self.isMounted
            case "assemblyInProgress":
               return self.assemblyInProgress
            case "volatile":
               return self.volatile
            case "uploadProgression":
               return self.uploadProgression
            case "downloadProgression":
               return self.downloadProgression
            case "assemblyProgression":
               return self.assemblyProgression
            case "uploadInProgress":
               return self.uploadInProgress
            case "downloadInProgress":
               return self.downloadInProgress
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
        return "boxes"
    }

    override  open var d_collectionName:String{
        return Box.collectionName
    }
}