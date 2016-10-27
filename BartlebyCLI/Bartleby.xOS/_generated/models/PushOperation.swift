//
//  PushOperation.swift
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

// MARK: Bartleby's Core: an object used to provision serialized operation. All its properties are not supervisable
@objc(PushOperation) open class PushOperation : BartlebyObject{

    // Universal type support
    override open class func typeName() -> String {
        return "PushOperation"
    }

	//The unique identifier of the related Command
	dynamic open var commandUID:String?

	//The dictionary representation of a serialized action call
	dynamic open var toDictionary:[String:Any]?

	//The dictionary representation of the last response serialized data
	open var responseDictionary:[String:Any]?

	//The completion state of the operation
	dynamic open var completionState:Completion?

	//The invocation Status None: on creation, Pending: can be pushed, Provisionned: is currently in an operation bunch, InProgress: the endpoint has been called, Completed : The end point call has been completed
	public enum Status:String{
		case none = "none"
		case pending = "pending"
		case provisionned = "provisionned"
		case inProgress = "inProgress"
		case completed = "completed"
	}
	open var status:Status = .none

	//The invocation counter
	dynamic open var counter:Int = -1

	//The creationdate
	dynamic open var creationDate:Date?

	//The last invocation date
	dynamic open var lastInvocationDate:Date?

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["commandUID","toDictionary","responseDictionary","completionState","status","counter","creationDate","lastInvocationDate"])
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
            case "commandUID":
                if let casted=value as? String{
                    self.commandUID=casted
                }
            case "toDictionary":
                if let casted=value as? [String:Any]{
                    self.toDictionary=casted
                }
            case "responseDictionary":
                if let casted=value as? [String:Any]{
                    self.responseDictionary=casted
                }
            case "completionState":
                if let casted=value as? Completion{
                    self.completionState=casted
                }
            case "status":
                if let casted=value as? PushOperation.Status{
                    self.status=casted
                }
            case "counter":
                if let casted=value as? Int{
                    self.counter=casted
                }
            case "creationDate":
                if let casted=value as? Date{
                    self.creationDate=casted
                }
            case "lastInvocationDate":
                if let casted=value as? Date{
                    self.lastInvocationDate=casted
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
            case "commandUID":
               return self.commandUID
            case "toDictionary":
               return self.toDictionary
            case "responseDictionary":
               return self.responseDictionary
            case "completionState":
               return self.completionState
            case "status":
               return self.status
            case "counter":
               return self.counter
            case "creationDate":
               return self.creationDate
            case "lastInvocationDate":
               return self.lastInvocationDate
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
			self.commandUID <- ( map["commandUID"] )
			self.toDictionary <- ( map["toDictionary"] )
			self.responseDictionary <- ( map["responseDictionary"] )
			self.completionState <- ( map["completionState"] )
			self.status <- ( map["status"] )
			self.counter <- ( map["counter"] )
			self.creationDate <- ( map["creationDate"], ISO8601DateTransform() )
			self.lastInvocationDate <- ( map["lastInvocationDate"], ISO8601DateTransform() )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self.commandUID=String(describing: decoder.decodeObject(of: NSString.self, forKey:"commandUID") as NSString?)
			self.toDictionary=decoder.decodeObject(of: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()], forKey: "toDictionary")as? [String:Any]
			self.responseDictionary=decoder.decodeObject(of: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()], forKey: "responseDictionary")as? [String:Any]
			self.completionState=decoder.decodeObject(of:Completion.self, forKey: "completionState") 
			self.status=PushOperation.Status(rawValue:String(describing: decoder.decodeObject(of: NSString.self, forKey: "status")! as NSString))! 
			self.counter=decoder.decodeInteger(forKey:"counter") 
			self.creationDate=decoder.decodeObject(of: NSDate.self , forKey:"creationDate") as Date?
			self.lastInvocationDate=decoder.decodeObject(of: NSDate.self , forKey:"lastInvocationDate") as Date?
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		if let commandUID = self.commandUID {
			coder.encode(commandUID,forKey:"commandUID")
		}
		if let toDictionary = self.toDictionary {
			coder.encode(toDictionary,forKey:"toDictionary")
		}
		if let responseDictionary = self.responseDictionary {
			coder.encode(responseDictionary,forKey:"responseDictionary")
		}
		if let completionState = self.completionState {
			coder.encode(completionState,forKey:"completionState")
		}
		coder.encode(self.status.rawValue ,forKey:"status")
		coder.encode(self.counter,forKey:"counter")
		if let creationDate = self.creationDate {
			coder.encode(creationDate,forKey:"creationDate")
		}
		if let lastInvocationDate = self.lastInvocationDate {
			coder.encode(lastInvocationDate,forKey:"lastInvocationDate")
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
        return "pushOperations"
    }

    override open var d_collectionName:String{
        return PushOperation.collectionName
    }
}