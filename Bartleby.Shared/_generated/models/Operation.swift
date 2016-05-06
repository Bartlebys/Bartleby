//
//  Operation.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for benoit@pereira-da-silva.com
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
// WE TRY TO GENERATE ANY REPETITIVE CODE AND TO IMPROVE THE QUALITY ITERATIVELY
//
// Copyright (c) 2015  Chaosmos | https://chaosmos.fr  All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
import Alamofire
import ObjectMapper
#endif

// MARK: Model Operation
@objc(Operation) public class Operation : JObject{


	//The dictionary representation of a serialized action call
	public var toDictionary:Dictionary<String, AnyObject>?
	//The dictionary representation of the last response serialized data
	public var responseDictionary:Dictionary<String, AnyObject>?
	public var baseUrl:NSURL?
	//The invocation Status
	public enum Status:String{
		case None = "none"
		case Pending = "pending"
		case InProgress = "inProgress"
		case Successful = "successful"
		case Unsucessful = "unsucessful"
	}
	public var status:Status = .None
	//The data space UID can be shared between multiple registries.
	dynamic public var spaceUID:String = "\(Default.NO_UID)"
	//The invocation counter
	public var counter:Int?
	//The creationdate
	public var creationDate:NSDate?
	//The last invocation date
	public var lastInvocationDate:NSDate?


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
        mapping(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
		self.toDictionary <- map["toDictionary"]
		self.responseDictionary <- map["responseDictionary"]
		self.baseUrl <- (map["baseUrl"],URLTransform())
		self.status <- map["status"]
		self.spaceUID <- map["spaceUID"]
		self.counter <- map["counter"]
		self.creationDate <- (map["creationDate"],ISO8601DateTransform())
		self.lastInvocationDate <- (map["lastInvocationDate"],ISO8601DateTransform())
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
		self.toDictionary=decoder.decodeObjectOfClasses(NSSet(array: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()]), forKey: "toDictionary")as? Dictionary<String, AnyObject>
		self.responseDictionary=decoder.decodeObjectOfClasses(NSSet(array: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()]), forKey: "responseDictionary")as? Dictionary<String, AnyObject>
		self.baseUrl=decoder.decodeObjectOfClass(NSURL.self, forKey:"baseUrl") as NSURL?
		self.status=Operation.Status(rawValue:String(decoder.decodeObjectOfClass(NSString.self, forKey: "status")! as NSString))! 
		self.spaceUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "spaceUID")! as NSString)
		self.counter=decoder.decodeIntegerForKey("counter") 
		self.creationDate=decoder.decodeObjectOfClass(NSDate.self, forKey:"creationDate") as NSDate?
		self.lastInvocationDate=decoder.decodeObjectOfClass(NSDate.self, forKey:"lastInvocationDate") as NSDate?

    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		if let toDictionary = self.toDictionary {
			coder.encodeObject(toDictionary,forKey:"toDictionary")
		}
		if let responseDictionary = self.responseDictionary {
			coder.encodeObject(responseDictionary,forKey:"responseDictionary")
		}
		if let baseUrl = self.baseUrl {
			coder.encodeObject(baseUrl,forKey:"baseUrl")
		}
		coder.encodeObject(self.status.rawValue ,forKey:"status")
		coder.encodeObject(self.spaceUID,forKey:"spaceUID")
		if let counter = self.counter {
			coder.encodeInteger(counter,forKey:"counter")
		}
		if let creationDate = self.creationDate {
			coder.encodeObject(creationDate,forKey:"creationDate")
		}
		if let lastInvocationDate = self.lastInvocationDate {
			coder.encodeObject(lastInvocationDate,forKey:"lastInvocationDate")
		}
    }


    override public class func supportsSecureCoding() -> Bool{
        return true
    }


    required public init() {
        super.init()
    }

    // MARK: Identifiable

    override public class var collectionName:String{
        return "operations"
    }

    override public var d_collectionName:String{
        return Operation.collectionName
    }


    // MARK: Persistent

    override public func toPersistentRepresentation()->(UID:String,collectionName:String,serializedUTF8String:String,A:Double,B:Double,C:Double,D:Double,E:Double,S:String){
        var r=super.toPersistentRepresentation()
        r.A=NSDate().timeIntervalSince1970
        return r
    }

}

