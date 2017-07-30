//
//  Locker.swift
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

// MARK: Bartleby's Core: a locker
@objc(Locker) open class Locker : ManagedModel{

    // Universal type support
    override open class func typeName() -> String {
        return "Locker"
    }

	//The associated document UID.
	dynamic open var associatedDocumentUID:String? {
	    didSet { 
	       if !self.wantsQuietChanges && associatedDocumentUID != oldValue {
	            self.provisionChanges(forKey: "associatedDocumentUID",oldValue: oldValue,newValue: associatedDocumentUID) 
	       } 
	    }
	}

	//The subject UID you want to lock
	dynamic open var subjectUID:String = "\(Default.NO_UID)"{
	    didSet { 
	       if !self.wantsQuietChanges && subjectUID != oldValue {
	            self.provisionChanges(forKey: "subjectUID",oldValue: oldValue,newValue: subjectUID) 
	       } 
	    }
	}

	//The userUID that can unlock the locker
	dynamic open var userUID:String = "\(Default.NO_UID)"{
	    didSet { 
	       if !self.wantsQuietChanges && userUID != oldValue {
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
	       if !self.wantsQuietChanges && mode != oldValue {
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
	       if !self.wantsQuietChanges && verificationMethod != oldValue {
	            self.provisionChanges(forKey: "verificationMethod",oldValue: oldValue.rawValue,newValue: verificationMethod.rawValue)  
	       } 
	    }
	}

	//the locker Security If set to .skipSecondaryAuthFactor mode the GetActivationCode will return the Locker (it skips second auth factor)
	public enum Security:String{
		case skipSecondaryAuthFactor = "skipSecondaryAuthFactor"
		case secondaryAuthFactorRequired = "secondaryAuthFactorRequired"
	}
	open var security:Security = .secondaryAuthFactorRequired  {
	    didSet { 
	       if !self.wantsQuietChanges && security != oldValue {
	            self.provisionChanges(forKey: "security",oldValue: oldValue.rawValue,newValue: security.rawValue)  
	       } 
	    }
	}

	//This code should be cryptable / decryptable
	dynamic open var code:String = "\(Bartleby.randomStringWithLength(6,signs:"0123456789ABCDEFGHJKMNPQRZTUVW"))"{
	    didSet { 
	       if !self.wantsQuietChanges && code != oldValue {
	            self.provisionChanges(forKey: "code",oldValue: oldValue,newValue: code) 
	       } 
	    }
	}

	//The number of attempts
	dynamic open var numberOfAttempt:Int = 3  {
	    didSet { 
	       if !self.wantsQuietChanges && numberOfAttempt != oldValue {
	            self.provisionChanges(forKey: "numberOfAttempt",oldValue: oldValue,newValue: numberOfAttempt)  
	       } 
	    }
	}

	dynamic open var startDate:Date = Date()  {
	    didSet { 
	       if !self.wantsQuietChanges && startDate != oldValue {
	            self.provisionChanges(forKey: "startDate",oldValue: oldValue,newValue: startDate)  
	       } 
	    }
	}

	dynamic open var endDate:Date = Date()  {
	    didSet { 
	       if !self.wantsQuietChanges && endDate != oldValue {
	            self.provisionChanges(forKey: "endDate",oldValue: oldValue,newValue: endDate)  
	       } 
	    }
	}

	//Thoses data gems will be return on success (the gems are crypted client side)
	dynamic open var gems:String = "\(Default.NO_GEM)"{
	    didSet { 
	       if !self.wantsQuietChanges && gems != oldValue {
	            self.provisionChanges(forKey: "gems",oldValue: oldValue,newValue: gems) 
	       } 
	    }
	}

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["associatedDocumentUID","subjectUID","userUID","mode","verificationMethod","security","code","numberOfAttempt","startDate","endDate","gems"])
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
            case "associatedDocumentUID":
                if let casted=value as? String{
                    self.associatedDocumentUID=casted
                }
            case "subjectUID":
                if let casted=value as? String{
                    self.subjectUID=casted
                }
            case "userUID":
                if let casted=value as? String{
                    self.userUID=casted
                }
            case "mode":
                if let casted=value as? Locker.Mode{
                    self.mode=casted
                }
            case "verificationMethod":
                if let casted=value as? Locker.VerificationMethod{
                    self.verificationMethod=casted
                }
            case "security":
                if let casted=value as? Locker.Security{
                    self.security=casted
                }
            case "code":
                if let casted=value as? String{
                    self.code=casted
                }
            case "numberOfAttempt":
                if let casted=value as? Int{
                    self.numberOfAttempt=casted
                }
            case "startDate":
                if let casted=value as? Date{
                    self.startDate=casted
                }
            case "endDate":
                if let casted=value as? Date{
                    self.endDate=casted
                }
            case "gems":
                if let casted=value as? String{
                    self.gems=casted
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
            case "associatedDocumentUID":
               return self.associatedDocumentUID
            case "subjectUID":
               return self.subjectUID
            case "userUID":
               return self.userUID
            case "mode":
               return self.mode
            case "verificationMethod":
               return self.verificationMethod
            case "security":
               return self.security
            case "code":
               return self.code
            case "numberOfAttempt":
               return self.numberOfAttempt
            case "startDate":
               return self.startDate
            case "endDate":
               return self.endDate
            case "gems":
               return self.gems
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
        self.quietChanges {
			self.associatedDocumentUID <- ( map["associatedDocumentUID"] )
			self.subjectUID <- ( map["subjectUID"] )
			self.userUID <- ( map["userUID"] )
			self.mode <- ( map["mode"] )
			self.verificationMethod <- ( map["verificationMethod"] )
			self.security <- ( map["security"] )
			self.code <- ( map["code"] )
			self.numberOfAttempt <- ( map["numberOfAttempt"] )
			self.startDate <- ( map["startDate"], ISO8601DateTransform() )
			self.endDate <- ( map["endDate"], ISO8601DateTransform() )
			self.gems <- ( map["gems"], CryptedStringTransform() )
        }
    }

     required public init() {
        super.init()
    }

    override open class var collectionName:String{
        return "lockers"
    }

    override open var d_collectionName:String{
        return Locker.collectionName
    }
}