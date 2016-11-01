//
//  Trigger.swift
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

// MARK: Bartleby's Core: a Trigger encapsulates a bunch of ExternalReferencees that's modelizes a state transformation
@objc(Trigger) open class Trigger : BartlebyObject{

    // Universal type support
    override open class func typeName() -> String {
        return "Trigger"
    }

	//The index is injected server side (each observationUID) has it own counter)
	dynamic open var index:Int = -1

	//The dataSpace UID
	dynamic open var spaceUID:String?

	//The observation UID for a given document correspond  to the BartlebyDocument.rootObjectUID
	dynamic open var observationUID:String?

	//The user.UID of the sender
	dynamic open var senderUID:String?

	//The UID of the instance of Bartleby client that has created the trigger.
	dynamic open var runUID:String?

	//The action that has initiated the trigger
	dynamic open var origin:String?

	//The targetted collection name
	dynamic open var targetCollectionName:String = ""

	//The server side creation date ( informative, use index for ranking)
	dynamic open var creationDate:Date?

	//The action name
	dynamic open var action:String = ""

	//A coma separated UIDS list
	dynamic open var UIDS:String = ""

	//The sseDbProcessingDuration is computed server side in SSE context only not when calling Triggers endpoints (it can be used for QOS computation)
	dynamic open var sseDbProcessingDuration:Double = -1

	//A collection of JSON payload
	dynamic open var payloads:[[String:Any]]?

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["index","spaceUID","observationUID","senderUID","runUID","origin","targetCollectionName","creationDate","action","UIDS","sseDbProcessingDuration","payloads"])
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
            case "index":
                if let casted=value as? Int{
                    self.index=casted
                }
            case "spaceUID":
                if let casted=value as? String{
                    self.spaceUID=casted
                }
            case "observationUID":
                if let casted=value as? String{
                    self.observationUID=casted
                }
            case "senderUID":
                if let casted=value as? String{
                    self.senderUID=casted
                }
            case "runUID":
                if let casted=value as? String{
                    self.runUID=casted
                }
            case "origin":
                if let casted=value as? String{
                    self.origin=casted
                }
            case "targetCollectionName":
                if let casted=value as? String{
                    self.targetCollectionName=casted
                }
            case "creationDate":
                if let casted=value as? Date{
                    self.creationDate=casted
                }
            case "action":
                if let casted=value as? String{
                    self.action=casted
                }
            case "UIDS":
                if let casted=value as? String{
                    self.UIDS=casted
                }
            case "sseDbProcessingDuration":
                if let casted=value as? Double{
                    self.sseDbProcessingDuration=casted
                }
            case "payloads":
                if let casted=value as? [[String:Any]]{
                    self.payloads=casted
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
            case "index":
               return self.index
            case "spaceUID":
               return self.spaceUID
            case "observationUID":
               return self.observationUID
            case "senderUID":
               return self.senderUID
            case "runUID":
               return self.runUID
            case "origin":
               return self.origin
            case "targetCollectionName":
               return self.targetCollectionName
            case "creationDate":
               return self.creationDate
            case "action":
               return self.action
            case "UIDS":
               return self.UIDS
            case "sseDbProcessingDuration":
               return self.sseDbProcessingDuration
            case "payloads":
               return self.payloads
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
			self.index <- ( map["index"] )
			self.spaceUID <- ( map["spaceUID"] )
			self.observationUID <- ( map["observationUID"] )
			self.senderUID <- ( map["senderUID"] )
			self.runUID <- ( map["runUID"] )
			self.origin <- ( map["origin"] )
			self.targetCollectionName <- ( map["targetCollectionName"] )
			self.creationDate <- ( map["creationDate"], ISO8601DateTransform() )
			self.action <- ( map["action"] )
			self.UIDS <- ( map["UIDS"] )
			self.sseDbProcessingDuration <- ( map["sseDbProcessingDuration"] )
			self.payloads <- ( map["payloads"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self.index=decoder.decodeInteger(forKey:"index") 
			self.spaceUID=String(describing: decoder.decodeObject(of: NSString.self, forKey:"spaceUID") as NSString?)
			self.observationUID=String(describing: decoder.decodeObject(of: NSString.self, forKey:"observationUID") as NSString?)
			self.senderUID=String(describing: decoder.decodeObject(of: NSString.self, forKey:"senderUID") as NSString?)
			self.runUID=String(describing: decoder.decodeObject(of: NSString.self, forKey:"runUID") as NSString?)
			self.origin=String(describing: decoder.decodeObject(of: NSString.self, forKey:"origin") as NSString?)
			self.targetCollectionName=String(describing: decoder.decodeObject(of: NSString.self, forKey: "targetCollectionName")! as NSString)
			self.creationDate=decoder.decodeObject(of: NSDate.self , forKey:"creationDate") as Date?
			self.action=String(describing: decoder.decodeObject(of: NSString.self, forKey: "action")! as NSString)
			self.UIDS=String(describing: decoder.decodeObject(of: NSString.self, forKey: "UIDS")! as NSString)
			self.sseDbProcessingDuration=decoder.decodeDouble(forKey:"sseDbProcessingDuration") 
			self.payloads=decoder.decodeObject(of: [NSArray.classForCoder(),NSDictionary.classForCoder()], forKey: "payloads") as? [[String:Any]]
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self.index,forKey:"index")
		if let spaceUID = self.spaceUID {
			coder.encode(spaceUID,forKey:"spaceUID")
		}
		if let observationUID = self.observationUID {
			coder.encode(observationUID,forKey:"observationUID")
		}
		if let senderUID = self.senderUID {
			coder.encode(senderUID,forKey:"senderUID")
		}
		if let runUID = self.runUID {
			coder.encode(runUID,forKey:"runUID")
		}
		if let origin = self.origin {
			coder.encode(origin,forKey:"origin")
		}
		coder.encode(self.targetCollectionName,forKey:"targetCollectionName")
		if let creationDate = self.creationDate {
			coder.encode(creationDate,forKey:"creationDate")
		}
		coder.encode(self.action,forKey:"action")
		coder.encode(self.UIDS,forKey:"UIDS")
		coder.encode(self.sseDbProcessingDuration,forKey:"sseDbProcessingDuration")
		if let payloads = self.payloads {
			coder.encode(payloads,forKey:"payloads")
		}
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

     required public init() {
        super.init()
    }

    // MARK: Identifiable

    override open class var collectionName:String{
        return "triggers"
    }

    override open var d_collectionName:String{
        return Trigger.collectionName
    }
}