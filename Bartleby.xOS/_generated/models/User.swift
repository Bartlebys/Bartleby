//
//  User.swift
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

// MARK: Bartleby's Core: a user in a specified data Space
@objc(User) open class User : ManagedModel{

    // Universal type support
    override open class func typeName() -> String {
        return "User"
    }

	//The spaceUID. A user with the same credentials can exists within multiple Data space.
	dynamic open var spaceUID:String = "\(Bartleby.createUID())"{
	    didSet { 
	       if !self.wantsQuietChanges && spaceUID != oldValue {
	            self.provisionChanges(forKey: "spaceUID",oldValue: oldValue,newValue: spaceUID) 
	       } 
	    }
	}

	//the verification method
	public enum VerificationMethod:String{
		case none = "none"
		case byPhoneNumber = "byPhoneNumber"
		case byEmail = "byEmail"
	}
	open var verificationMethod:VerificationMethod = .byPhoneNumber  {
	    didSet { 
	       if !self.wantsQuietChanges && verificationMethod != oldValue {
	            self.provisionChanges(forKey: "verificationMethod",oldValue: oldValue.rawValue,newValue: verificationMethod.rawValue)  
	       } 
	    }
	}

	//The localAssociationID is an UID used to group accounts that are stored in the KeyChain. The first Created Account determines that UID
	dynamic open var localAssociationID:String = "\(Default.NO_UID)"{
	    didSet { 
	       if !self.wantsQuietChanges && localAssociationID != oldValue {
	            self.provisionChanges(forKey: "localAssociationID",oldValue: oldValue,newValue: localAssociationID) 
	       } 
	    }
	}

	dynamic open var firstname:String = "\(Bartleby.randomStringWithLength(5))"{
	    didSet { 
	       if !self.wantsQuietChanges && firstname != oldValue {
	            self.provisionChanges(forKey: "firstname",oldValue: oldValue,newValue: firstname) 
	       } 
	    }
	}

	dynamic open var lastname:String = "\(Bartleby.randomStringWithLength(5))"{
	    didSet { 
	       if !self.wantsQuietChanges && lastname != oldValue {
	            self.provisionChanges(forKey: "lastname",oldValue: oldValue,newValue: lastname) 
	       } 
	    }
	}

	//The user's email. 
	dynamic open var email:String = ""{
	    didSet { 
	       if !self.wantsQuietChanges && email != oldValue {
	            self.provisionChanges(forKey: "email",oldValue: oldValue,newValue: email) 
	       } 
	    }
	}

	//The user's phone country code
	dynamic open var phoneCountryCode:String = ""{
	    didSet { 
	       if !self.wantsQuietChanges && phoneCountryCode != oldValue {
	            self.provisionChanges(forKey: "phoneCountryCode",oldValue: oldValue,newValue: phoneCountryCode) 
	       } 
	    }
	}

	//The user's phone number
	dynamic open var phoneNumber:String = ""{
	    didSet { 
	       if !self.wantsQuietChanges && phoneNumber != oldValue {
	            self.provisionChanges(forKey: "phoneNumber",oldValue: oldValue,newValue: phoneNumber) 
	       } 
	    }
	}

	//The user password
	dynamic open var password:String = ""{
	    didSet { 
	       if !self.wantsQuietChanges && password != oldValue {
	            self.provisionChanges(forKey: "password",oldValue: oldValue,newValue: password) 
	       } 
	    }
	}

	//User Status
	public enum Status:String{
		case new = "new"
		case actived = "actived"
		case suspended = "suspended"
	}
	open var status:Status = .new  {
	    didSet { 
	       if !self.wantsQuietChanges && status != oldValue {
	            self.provisionChanges(forKey: "status",oldValue: oldValue.rawValue,newValue: status.rawValue)  
	       } 
	    }
	}

	//Notes
	dynamic open var notes:String? {
	    didSet { 
	       if !self.wantsQuietChanges && notes != oldValue {
	            self.provisionChanges(forKey: "notes",oldValue: oldValue,newValue: notes) 
	       } 
	    }
	}

	//set to true on the first successfull login in the session (this property is not serialized)
	dynamic open var loginHasSucceed:Bool = false

	//Can a user memorize her/his password
	dynamic open var supportsPasswordMemorization:Bool = Bartleby.configuration.SUPPORTS_PASSWORD_MEMORIZATION_BY_DEFAULT  {
	    didSet { 
	       if !self.wantsQuietChanges && supportsPasswordMemorization != oldValue {
	            self.provisionChanges(forKey: "supportsPasswordMemorization",oldValue: oldValue,newValue: supportsPasswordMemorization)  
	       } 
	    }
	}

	//Can a user update her/his  own password
	dynamic open var supportsPasswordUpdate:Bool = Bartleby.configuration.SUPPORTS_PASSWORD_UPDATE_BY_DEFAULT  {
	    didSet { 
	       if !self.wantsQuietChanges && supportsPasswordUpdate != oldValue {
	            self.provisionChanges(forKey: "supportsPasswordUpdate",oldValue: oldValue,newValue: supportsPasswordUpdate)  
	       } 
	    }
	}

	//If a local user has the same credentials can her/his password be syndicated
	dynamic open var supportsPasswordSyndication:Bool = Bartleby.configuration.SUPPORTS_PASSWORD_SYNDICATION_BY_DEFAULT  {
	    didSet { 
	       if !self.wantsQuietChanges && supportsPasswordSyndication != oldValue {
	            self.provisionChanges(forKey: "supportsPasswordSyndication",oldValue: oldValue,newValue: supportsPasswordSyndication)  
	       } 
	    }
	}

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["spaceUID","verificationMethod","localAssociationID","firstname","lastname","email","phoneCountryCode","phoneNumber","password","status","notes","loginHasSucceed","supportsPasswordMemorization","supportsPasswordUpdate","supportsPasswordSyndication"])
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
            case "spaceUID":
                if let casted=value as? String{
                    self.spaceUID=casted
                }
            case "verificationMethod":
                if let casted=value as? User.VerificationMethod{
                    self.verificationMethod=casted
                }
            case "localAssociationID":
                if let casted=value as? String{
                    self.localAssociationID=casted
                }
            case "firstname":
                if let casted=value as? String{
                    self.firstname=casted
                }
            case "lastname":
                if let casted=value as? String{
                    self.lastname=casted
                }
            case "email":
                if let casted=value as? String{
                    self.email=casted
                }
            case "phoneCountryCode":
                if let casted=value as? String{
                    self.phoneCountryCode=casted
                }
            case "phoneNumber":
                if let casted=value as? String{
                    self.phoneNumber=casted
                }
            case "password":
                if let casted=value as? String{
                    self.password=casted
                }
            case "status":
                if let casted=value as? User.Status{
                    self.status=casted
                }
            case "notes":
                if let casted=value as? String{
                    self.notes=casted
                }
            case "loginHasSucceed":
                if let casted=value as? Bool{
                    self.loginHasSucceed=casted
                }
            case "supportsPasswordMemorization":
                if let casted=value as? Bool{
                    self.supportsPasswordMemorization=casted
                }
            case "supportsPasswordUpdate":
                if let casted=value as? Bool{
                    self.supportsPasswordUpdate=casted
                }
            case "supportsPasswordSyndication":
                if let casted=value as? Bool{
                    self.supportsPasswordSyndication=casted
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
            case "spaceUID":
               return self.spaceUID
            case "verificationMethod":
               return self.verificationMethod
            case "localAssociationID":
               return self.localAssociationID
            case "firstname":
               return self.firstname
            case "lastname":
               return self.lastname
            case "email":
               return self.email
            case "phoneCountryCode":
               return self.phoneCountryCode
            case "phoneNumber":
               return self.phoneNumber
            case "password":
               return self.password
            case "status":
               return self.status
            case "notes":
               return self.notes
            case "loginHasSucceed":
               return self.loginHasSucceed
            case "supportsPasswordMemorization":
               return self.supportsPasswordMemorization
            case "supportsPasswordUpdate":
               return self.supportsPasswordUpdate
            case "supportsPasswordSyndication":
               return self.supportsPasswordSyndication
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
			self.spaceUID <- ( map["spaceUID"] )
			self.verificationMethod <- ( map["verificationMethod"] )
			self.localAssociationID <- ( map["localAssociationID"] )
			self.firstname <- ( map["firstname"] )
			self.lastname <- ( map["lastname"] )
			self.email <- ( map["email"] )
			self.phoneCountryCode <- ( map["phoneCountryCode"] )
			self.phoneNumber <- ( map["phoneNumber"] )
			self.password <- ( map["password"], CryptedStringTransform() )
			self.status <- ( map["status"] )
			self.notes <- ( map["notes"] )
			self.supportsPasswordMemorization <- ( map["supportsPasswordMemorization"] )
			self.supportsPasswordUpdate <- ( map["supportsPasswordUpdate"] )
			self.supportsPasswordSyndication <- ( map["supportsPasswordSyndication"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.quietChanges {
			self.spaceUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "spaceUID")! as NSString)
			self.verificationMethod=User.VerificationMethod(rawValue:String(describing: decoder.decodeObject(of: NSString.self, forKey: "verificationMethod")! as NSString))! 
			self.localAssociationID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "localAssociationID")! as NSString)
			self.firstname=String(describing: decoder.decodeObject(of: NSString.self, forKey: "firstname")! as NSString)
			self.lastname=String(describing: decoder.decodeObject(of: NSString.self, forKey: "lastname")! as NSString)
			self.email=String(describing: decoder.decodeObject(of: NSString.self, forKey: "email")! as NSString)
			self.phoneCountryCode=String(describing: decoder.decodeObject(of: NSString.self, forKey: "phoneCountryCode")! as NSString)
			self.phoneNumber=String(describing: decoder.decodeObject(of: NSString.self, forKey: "phoneNumber")! as NSString)
			self.password=String(describing: decoder.decodeObject(of: NSString.self, forKey: "password")! as NSString)
			self.status=User.Status(rawValue:String(describing: decoder.decodeObject(of: NSString.self, forKey: "status")! as NSString))! 
			self.notes=String(describing: decoder.decodeObject(of: NSString.self, forKey:"notes") as NSString?)
			self.supportsPasswordMemorization=decoder.decodeBool(forKey:"supportsPasswordMemorization") 
			self.supportsPasswordUpdate=decoder.decodeBool(forKey:"supportsPasswordUpdate") 
			self.supportsPasswordSyndication=decoder.decodeBool(forKey:"supportsPasswordSyndication") 
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self.spaceUID,forKey:"spaceUID")
		coder.encode(self.verificationMethod.rawValue ,forKey:"verificationMethod")
		coder.encode(self.localAssociationID,forKey:"localAssociationID")
		coder.encode(self.firstname,forKey:"firstname")
		coder.encode(self.lastname,forKey:"lastname")
		coder.encode(self.email,forKey:"email")
		coder.encode(self.phoneCountryCode,forKey:"phoneCountryCode")
		coder.encode(self.phoneNumber,forKey:"phoneNumber")
		coder.encode(self.password,forKey:"password")
		coder.encode(self.status.rawValue ,forKey:"status")
		if let notes = self.notes {
			coder.encode(notes,forKey:"notes")
		}
		coder.encode(self.supportsPasswordMemorization,forKey:"supportsPasswordMemorization")
		coder.encode(self.supportsPasswordUpdate,forKey:"supportsPasswordUpdate")
		coder.encode(self.supportsPasswordSyndication,forKey:"supportsPasswordSyndication")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

     required public init() {
        super.init()
    }

    override open class var collectionName:String{
        return "users"
    }

    override open var d_collectionName:String{
        return User.collectionName
    }
}