//
//  PushOperation.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for b@bartlebys.org
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  Bartleby's | https://bartlebys.org  All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
import Alamofire
import ObjectMapper
#endif

// MARK: Bartleby's Core: an object used to provision serialized operation. All its properties are not supervisable
@objc(PushOperation) open class PushOperation : JObject{

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


    // MARK: Mappable

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


    // MARK: NSSecureCoding

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

