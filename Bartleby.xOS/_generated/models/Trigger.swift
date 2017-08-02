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
#endif

// MARK: Bartleby's Core: a Trigger encapsulates a bunch of that's modelizes a state transformation
@objc(Trigger) open class Trigger : UnManagedModel {


	//The index is injected server side (each observationUID) has it own counter)
	@objc dynamic open var index:Int = -1

	//The dataSpace UID
	@objc dynamic open var spaceUID:String?

	//The observation UID
	@objc dynamic open var observationUID:String?

	//The user.UID of the sender
	@objc dynamic open var senderUID:String?

	//The UID of the instance of Bartleby client that has created the trigger.
	@objc dynamic open var runUID:String?

	//The action that has initiated the trigger
	@objc dynamic open var origin:String?

	//The targetted collection name
	@objc dynamic open var targetCollectionName:String = ""

	//The server side creation date ( informative, use index for ranking)
	@objc dynamic open var creationDate:Date?

	//The action name
	@objc dynamic open var action:String = ""

	//A coma separated UIDS list
	@objc dynamic open var UIDS:String = ""

	//The sseDbProcessingDuration is computed server side in SSE context only not when calling Triggers endpoints (it can be used for QOS computation)
	@objc dynamic open var sseDbProcessingDuration:Double = -1

	//A collection of JSON payload
	@objc dynamic open var payloads:[Data]?


    // MARK: - Codable


    enum TriggerCodingKeys: String,CodingKey{
		case index
		case spaceUID
		case observationUID
		case senderUID
		case runUID
		case origin
		case targetCollectionName
		case creationDate
		case action
		case UIDS
		case sseDbProcessingDuration
		case payloads
    }

    required public init(from decoder: Decoder) throws{
		try super.init(from: decoder)
        try self.quietThrowingChanges {
			let values = try decoder.container(keyedBy: TriggerCodingKeys.self)
			self.index = try values.decode(Int.self,forKey:.index)
			self.spaceUID = try values.decodeIfPresent(String.self,forKey:.spaceUID)
			self.observationUID = try values.decodeIfPresent(String.self,forKey:.observationUID)
			self.senderUID = try values.decodeIfPresent(String.self,forKey:.senderUID)
			self.runUID = try values.decodeIfPresent(String.self,forKey:.runUID)
			self.origin = try values.decodeIfPresent(String.self,forKey:.origin)
			self.targetCollectionName = try values.decode(String.self,forKey:.targetCollectionName)
			self.creationDate = try values.decodeIfPresent(Date.self,forKey:.creationDate)
			self.action = try values.decode(String.self,forKey:.action)
			self.UIDS = try values.decode(String.self,forKey:.UIDS)
			self.sseDbProcessingDuration = try values.decode(Double.self,forKey:.sseDbProcessingDuration)
			self.payloads = try values.decodeIfPresent([Data].self,forKey:.payloads)
        }
    }

    override open func encode(to encoder: Encoder) throws {
		try super.encode(to:encoder)
		var container = encoder.container(keyedBy: TriggerCodingKeys.self)
		try container.encode(self.index,forKey:.index)
		try container.encodeIfPresent(self.spaceUID,forKey:.spaceUID)
		try container.encodeIfPresent(self.observationUID,forKey:.observationUID)
		try container.encodeIfPresent(self.senderUID,forKey:.senderUID)
		try container.encodeIfPresent(self.runUID,forKey:.runUID)
		try container.encodeIfPresent(self.origin,forKey:.origin)
		try container.encode(self.targetCollectionName,forKey:.targetCollectionName)
		try container.encodeIfPresent(self.creationDate,forKey:.creationDate)
		try container.encode(self.action,forKey:.action)
		try container.encode(self.UIDS,forKey:.UIDS)
		try container.encode(self.sseDbProcessingDuration,forKey:.sseDbProcessingDuration)
		try container.encodeIfPresent(self.payloads,forKey:.payloads)
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override  open var exposedKeys:[String] {
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
    override  open func setExposedValue(_ value:Any?, forKey key: String) throws {
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
                if let casted=value as? [Data]{
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
    override  open func getExposedValueForKey(_ key:String) throws -> Any?{
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
    // MARK: - Initializable
     required public init() {
        super.init()
    }
}