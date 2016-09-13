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
@objc(Locker) open class Locker : JObject{

    // Universal type support
    override open class func typeName() -> String {
        return "Locker"
    }

	//The associated registry UID.
	dynamic open var registryUID:String? {	 
	    didSet { 
	       if registryUID != oldValue {
	            self.provisionChanges(forKey: "registryUID",oldValue: oldValue,newValue: registryUID) 
	       } 
	    }
	}

	//The subject UID you want to lock
	dynamic open var subjectUID:String = "\(Default.NO_UID)"{	 
	    didSet { 
	       if subjectUID != oldValue {
	            self.provisionChanges(forKey: "subjectUID",oldValue: oldValue,newValue: subjectUID) 
	       } 
	    }
	}

	//The userUID that can unlock the locker
	dynamic open var userUID:String = "\(Default.NO_UID)"{	 
	    didSet { 
	       if userUID != oldValue {
	            self.provisionChanges(forKey: "userUID",oldValue: oldValue,newValue: userUID) 
	       } 
	    }
	}

	//the locker mode
	public enum Mode:String{
		case autoDestructive = "autoDestructive"
		case persistent = "persistent"
	}
	open var mode:Mode = .autoDestructive  {	 
	    didSet { 
	       if mode != oldValue {
	            self.provisionChanges(forKey: "mode",oldValue: oldValue.rawValue,newValue: mode.rawValue)  
	       } 
	    }
	}

	//the locker mode
	public enum VerificationMethod:String{
		case online = "online"
		case offline = "offline"
	}
	open var verificationMethod:VerificationMethod = .online  {	 
	    didSet { 
	       if verificationMethod != oldValue {
	            self.provisionChanges(forKey: "verificationMethod",oldValue: oldValue.rawValue,newValue: verificationMethod.rawValue)  
	       } 
	    }
	}

	//This code should be crypted / decrypted
	dynamic open var code:String = "\(Bartleby.randomStringWithLength(6,signs:"0123456789ABCDEFGHJKMNPQRZTUVW"))"{	 
	    didSet { 
	       if code != oldValue {
	            self.provisionChanges(forKey: "code",oldValue: oldValue,newValue: code) 
	       } 
	    }
	}

	//The number of attempts
	dynamic open var numberOfAttempt:Int = 3  {	 
	    didSet { 
	       if numberOfAttempt != oldValue {
	            self.provisionChanges(forKey: "numberOfAttempt",oldValue: oldValue,newValue: numberOfAttempt)  
	       } 
	    }
	}

	dynamic open var startDate:Date = Date.distantPast  {	 
	    didSet { 
	       if startDate != oldValue {
	            self.provisionChanges(forKey: "startDate",oldValue: oldValue,newValue: startDate)  
	       } 
	    }
	}

	dynamic open var endDate:Date = Date.distantFuture  {	 
	    didSet { 
	       if endDate != oldValue {
	            self.provisionChanges(forKey: "endDate",oldValue: oldValue,newValue: endDate)  
	       } 
	    }
	}

	//Thoses data gems will be return on success
	dynamic open var gems:String = "\(Default.NO_GEM)"{	 
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

    override open func mapping(_ map: Map) {
        super.mapping(map)
        self.disableSupervisionAndCommit()
		self.registryUID <- ( map["registryUID"] )
		self.subjectUID <- ( map["subjectUID"] )
		self.userUID <- ( map["userUID"] )
		self.mode <- ( map["mode"] )
		self.verificationMethod <- ( map["verificationMethod"] )
		self.code <- ( map["code"] )
		self.numberOfAttempt <- ( map["numberOfAttempt"] )
		self.startDate <- ( map["startDate"], ISO8601DateTransform() )
		self.endDate <- ( map["endDate"], ISO8601DateTransform() )
		self.gems <- ( map["gems"] )
        self.enableSuperVisionAndCommit()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.disableSupervisionAndCommit()
		self.registryUID=String(describing: decoder.decodeObject(of: NSString.self, forKey:"registryUID") as NSString?)
		self.subjectUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "subjectUID")! as NSString)
		self.userUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "userUID")! as NSString)
		self.mode=Locker.Mode(rawValue:String(describing: decoder.decodeObject(of: NSString.self, forKey: "mode")! as NSString))! 
		self.verificationMethod=Locker.VerificationMethod(rawValue:String(describing: decoder.decodeObject(of: NSString.self, forKey: "verificationMethod")! as NSString))! 
		self.code=String(describing: decoder.decodeObject(of: NSString.self, forKey: "code")! as NSString)
		self.numberOfAttempt=decoder.decodeInteger(forKey:"numberOfAttempt") 
		self.startDate=decoder.decodeObject(of: NSDate.self , forKey: "startDate")! as Date
		self.endDate=decoder.decodeObject(of: NSDate.self , forKey: "endDate")! as Date
		self.gems=String(describing: decoder.decodeObject(of: NSString.self, forKey: "gems")! as NSString)
        self.disableSupervisionAndCommit()
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		if let registryUID = self.registryUID {
			coder.encode(registryUID,forKey:"registryUID")
		}
		coder.encode(self.subjectUID,forKey:"subjectUID")
		coder.encode(self.userUID,forKey:"userUID")
		coder.encode(self.mode.rawValue ,forKey:"mode")
		coder.encode(self.verificationMethod.rawValue ,forKey:"verificationMethod")
		coder.encode(self.code,forKey:"code")
		coder.encode(self.numberOfAttempt,forKey:"numberOfAttempt")
		coder.encode(self.startDate,forKey:"startDate")
		coder.encode(self.endDate,forKey:"endDate")
		coder.encode(self.gems,forKey:"gems")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }


    required public init() {
        super.init()
    }

    // MARK: Identifiable

    override open class var collectionName:String{
        return "lockers"
    }

    override open var d_collectionName:String{
        return Locker.collectionName
    }


}

