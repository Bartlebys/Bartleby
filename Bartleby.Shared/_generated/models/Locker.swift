//
//  Locker.swift
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

// MARK: Bartleby's Core: a locker
@objc(Locker) public class Locker : JObject{

    // Universal type support
    override public class func typeName() -> String {
        return "Locker"
    }

	//The spaceUID is the data space UID.
	public var spaceUID:String? {	 
	    didSet { 
	       if spaceUID != oldValue {
	            self.provisionChanges(forKey: "spaceUID",oldValue: oldValue,newValue: spaceUID) 
	       } 
	    }
	}

	//The subject UID you want to lock
	public var subjectUID:String = "\(Default.NO_UID)"{	 
	    didSet { 
	       if subjectUID != oldValue {
	            self.provisionChanges(forKey: "subjectUID",oldValue: oldValue,newValue: subjectUID) 
	       } 
	    }
	}

	//The userUID that can unlock the locker
	public var userUID:String = "\(Default.NO_UID)"{	 
	    didSet { 
	       if userUID != oldValue {
	            self.provisionChanges(forKey: "userUID",oldValue: oldValue,newValue: userUID) 
	       } 
	    }
	}

	//the locker mode
	public enum Mode:String{
		case AutoDestructive = "AutoDestructive"
		case Persistent = "Persistent"
	}
	public var mode:Mode = .AutoDestructive  {	 
	    didSet { 
	       if mode != oldValue {
	            self.provisionChanges(forKey: "mode",oldValue: oldValue.rawValue,newValue: mode.rawValue)  
	       } 
	    }
	}

	//the locker mode
	public enum VerificationMethod:String{
		case Online = "Online"
		case Offline = "Offline"
	}
	public var verificationMethod:VerificationMethod = .Online  {	 
	    didSet { 
	       if verificationMethod != oldValue {
	            self.provisionChanges(forKey: "verificationMethod",oldValue: oldValue.rawValue,newValue: verificationMethod.rawValue)  
	       } 
	    }
	}

	//This code should be crypted / decrypted
	public var code:String = "\(Bartleby.randomStringWithLength(6,signs:"0123456789ABCDEFGHJKMNPQRZTUVW"))"{	 
	    didSet { 
	       if code != oldValue {
	            self.provisionChanges(forKey: "code",oldValue: oldValue,newValue: code) 
	       } 
	    }
	}

	//The number of attempts
	public var numberOfAttempt:Int = 3  {	 
	    didSet { 
	       if numberOfAttempt != oldValue {
	            self.provisionChanges(forKey: "numberOfAttempt",oldValue: oldValue,newValue: numberOfAttempt)  
	       } 
	    }
	}

	public var startDate:NSDate = NSDate.distantPast()  {	 
	    didSet { 
	       if startDate != oldValue {
	            self.provisionChanges(forKey: "startDate",oldValue: oldValue,newValue: startDate)  
	       } 
	    }
	}

	public var endDate:NSDate = NSDate.distantFuture()  {	 
	    didSet { 
	       if endDate != oldValue {
	            self.provisionChanges(forKey: "endDate",oldValue: oldValue,newValue: endDate)  
	       } 
	    }
	}

	//Thoses data gems will be return on success
	public var gems:String = "\(Default.NO_GEM)"{	 
	    didSet { 
	       if gems != oldValue {
	            self.provisionChanges(forKey: "gems",oldValue: oldValue,newValue: gems) 
	       } 
	    }
	}



    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
        self.disableSupervision()
        self.disableAutoCommit()
		self.spaceUID <- ( map["spaceUID"] )
		self.subjectUID <- ( map["subjectUID"] )
		self.userUID <- ( map["userUID"] )
		self.mode <- ( map["mode"] )
		self.verificationMethod <- ( map["verificationMethod"] )
		self.code <- ( map["code"] )
		self.numberOfAttempt <- ( map["numberOfAttempt"] )
		self.startDate <- ( map["startDate"], ISO8601DateTransform() )
		self.endDate <- ( map["endDate"], ISO8601DateTransform() )
		self.gems <- ( map["gems"] )
        self.enableSupervision()
        self.enableAutoCommit()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.disableSupervision()
        self.disableAutoCommit()
		self.spaceUID=String(decoder.decodeObjectOfClass(NSString.self, forKey:"spaceUID") as NSString?)
		self.subjectUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "subjectUID")! as NSString)
		self.userUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "userUID")! as NSString)
		self.mode=Locker.Mode(rawValue:String(decoder.decodeObjectOfClass(NSString.self, forKey: "mode")! as NSString))! 
		self.verificationMethod=Locker.VerificationMethod(rawValue:String(decoder.decodeObjectOfClass(NSString.self, forKey: "verificationMethod")! as NSString))! 
		self.code=String(decoder.decodeObjectOfClass(NSString.self, forKey: "code")! as NSString)
		self.numberOfAttempt=decoder.decodeIntegerForKey("numberOfAttempt") 
		self.startDate=decoder.decodeObjectOfClass(NSDate.self, forKey: "startDate")! as NSDate
		self.endDate=decoder.decodeObjectOfClass(NSDate.self, forKey: "endDate")! as NSDate
		self.gems=String(decoder.decodeObjectOfClass(NSString.self, forKey: "gems")! as NSString)

        self.enableSupervision()
        self.enableAutoCommit()
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
		coder.encodeObject(self.gems,forKey:"gems")
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


}

