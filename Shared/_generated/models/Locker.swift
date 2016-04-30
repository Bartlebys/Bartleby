//
//  Locker.swift
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

// MARK: Model Locker
@objc(Locker) public class Locker : BaseObject{


	//The spaceUID is the data space UID.
	public var spaceUID:String?
	//The subject UID you want to lock
	public var subjectUID:String = "\(Default.NO_UID)"
	//The userUID that can unlock the locker
	public var userUID:String = "\(Default.NO_UID)"
	//the locker mode
	public enum Mode:String{
		case AutoDestructive = "AutoDestructive"
		case Persistent = "Persistent"
	}
	public var mode:Mode = .AutoDestructive
	//the locker mode
	public enum VerificationMethod:String{
		case Online = "Online"
		case Offline = "Offline"
	}
	public var verificationMethod:VerificationMethod = .Online
	//This code should be crypted / decrypted
	public var code:String = "\(Bartleby.randomStringWithLength(6,signs:"0123456789ABCDEFGHJKMNPQRZTUVW"))"
	//The number of attempts
	public var numberOfAttempt:Int = 3
	public var startDate:NSDate = NSDate.distantPast()
	public var endDate:NSDate = NSDate.distantFuture()
	//This cake will be return on success
	public var cake:String = "\(Default.NO_CAKE)"


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
        mapping(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
		self.spaceUID <- map["spaceUID"]
		self.subjectUID <- map["subjectUID"]
		self.userUID <- map["userUID"]
		self.mode <- map["mode"]
		self.verificationMethod <- map["verificationMethod"]
		self.code <- map["code"]
		self.numberOfAttempt <- map["numberOfAttempt"]
		self.startDate <- (map["startDate"],ISO8601DateTransform())
		self.endDate <- (map["endDate"],ISO8601DateTransform())
		self.cake <- map["cake"]
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
		self.spaceUID=String(decoder.decodeObjectOfClass(NSString.self, forKey:"spaceUID") as NSString?)
		self.subjectUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "subjectUID")! as NSString)
		self.userUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "userUID")! as NSString)
		self.mode=Locker.Mode(rawValue:String(decoder.decodeObjectOfClass(NSString.self, forKey: "mode")! as NSString))! 
		self.verificationMethod=Locker.VerificationMethod(rawValue:String(decoder.decodeObjectOfClass(NSString.self, forKey: "verificationMethod")! as NSString))! 
		self.code=String(decoder.decodeObjectOfClass(NSString.self, forKey: "code")! as NSString)
		self.numberOfAttempt=decoder.decodeIntegerForKey("numberOfAttempt") 
		self.startDate=decoder.decodeObjectOfClass(NSDate.self, forKey: "startDate")! as NSDate
		self.endDate=decoder.decodeObjectOfClass(NSDate.self, forKey: "endDate")! as NSDate
		self.cake=String(decoder.decodeObjectOfClass(NSString.self, forKey: "cake")! as NSString)

    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		if let spaceUID = self.spaceUID {
			coder.encodeObject(spaceUID,forKey:"spaceUID")
		}
		coder.encodeObject(self.subjectUID,forKey:"subjectUID")
		coder.encodeObject(self.userUID,forKey:"userUID")
		coder.encodeObject(self.mode.rawValue ,forKey:"mode")
		coder.encodeObject(self.verificationMethod.rawValue ,forKey:"verificationMethod")
		coder.encodeObject(self.code,forKey:"code")
		coder.encodeInteger(self.numberOfAttempt,forKey:"numberOfAttempt")
		coder.encodeObject(self.startDate,forKey:"startDate")
		coder.encodeObject(self.endDate,forKey:"endDate")
		coder.encodeObject(self.cake,forKey:"cake")
    }


    override public class func supportsSecureCoding() -> Bool{
        return true
    }


    required public init() {
        super.init()
    }

    // MARK: Identifiable

    override public class var collectionName:String{
        return "lockers"
    }

    override public var d_collectionName:String{
        return Locker.collectionName
    }


    // MARK: Persistent

    override public func toPersistentRepresentation()->(UID:String,collectionName:String,serializedUTF8String:String,A:Double,B:Double,C:Double,D:Double,E:Double,S:String){
        var r=super.toPersistentRepresentation()
        r.A=NSDate().timeIntervalSince1970
        return r
    }

}

