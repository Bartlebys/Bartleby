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
	#endif

// MARK: Bartleby's Core: a user in a specified data Space
@objc open class User : ManagedModel{

    // Universal type support
    override open class func typeName() -> String {
        return "User"
    }

	//The spaceUID. A user with the same credentials can exists within multiple Data space.
	@objc dynamic open var spaceUID:String = Bartleby.createUID() {
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
	@objc dynamic open var localAssociationID:String = Default.NO_UID {
	    didSet { 
	       if !self.wantsQuietChanges && localAssociationID != oldValue {
	            self.provisionChanges(forKey: "localAssociationID",oldValue: oldValue,newValue: localAssociationID) 
	       } 
	    }
	}

	@objc dynamic open var firstname:String = Bartleby.randomStringWithLength(5) {
	    didSet { 
	       if !self.wantsQuietChanges && firstname != oldValue {
	            self.provisionChanges(forKey: "firstname",oldValue: oldValue,newValue: firstname) 
	       } 
	    }
	}

	@objc dynamic open var lastname:String = Bartleby.randomStringWithLength(5) {
	    didSet { 
	       if !self.wantsQuietChanges && lastname != oldValue {
	            self.provisionChanges(forKey: "lastname",oldValue: oldValue,newValue: lastname) 
	       } 
	    }
	}

	//The user's email. 
	@objc dynamic open var email:String = "" {
	    didSet { 
	       if !self.wantsQuietChanges && email != oldValue {
	            self.provisionChanges(forKey: "email",oldValue: oldValue,newValue: email) 
	       } 
	    }
	}

	//The user's pseudo
	@objc dynamic open var pseudo:String = "" {
	    didSet { 
	       if !self.wantsQuietChanges && pseudo != oldValue {
	            self.provisionChanges(forKey: "pseudo",oldValue: oldValue,newValue: pseudo) 
	       } 
	    }
	}

	//The user's phone country code
	@objc dynamic open var phoneCountryCode:String = "" {
	    didSet { 
	       if !self.wantsQuietChanges && phoneCountryCode != oldValue {
	            self.provisionChanges(forKey: "phoneCountryCode",oldValue: oldValue,newValue: phoneCountryCode) 
	       } 
	    }
	}

	//The user's phone number
	@objc dynamic open var phoneNumber:String = "" {
	    didSet { 
	       if !self.wantsQuietChanges && phoneNumber != oldValue {
	            self.provisionChanges(forKey: "phoneNumber",oldValue: oldValue,newValue: phoneNumber) 
	       } 
	    }
	}

	//The user password (erased by the server on READ operations so that string needs imperatively to be Optional)
	@objc dynamic open var password:String? {
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
	@objc dynamic open var notes:String? {
	    didSet { 
	       if !self.wantsQuietChanges && notes != oldValue {
	            self.provisionChanges(forKey: "notes",oldValue: oldValue,newValue: notes) 
	       } 
	    }
	}

	//set to true on the first successfull login in the session (this property is not serialized)
	@objc dynamic open var loginHasSucceed:Bool = false

	//An isolated User is not associated to any Collaborative server
	@objc dynamic open var isIsolated:Bool = false  {
	    didSet { 
	       if !self.wantsQuietChanges && isIsolated != oldValue {
	            self.provisionChanges(forKey: "isIsolated",oldValue: oldValue,newValue: isIsolated)  
	       } 
	    }
	}

	//Can a user memorize her/his password
	@objc dynamic open var supportsPasswordMemorization:Bool = Bartleby.configuration.SUPPORTS_PASSWORD_MEMORIZATION_BY_DEFAULT  {
	    didSet { 
	       if !self.wantsQuietChanges && supportsPasswordMemorization != oldValue {
	            self.provisionChanges(forKey: "supportsPasswordMemorization",oldValue: oldValue,newValue: supportsPasswordMemorization)  
	       } 
	    }
	}

	//Can a user update her/his  own password
	@objc dynamic open var supportsPasswordUpdate:Bool = Bartleby.configuration.SUPPORTS_PASSWORD_UPDATE_BY_DEFAULT  {
	    didSet { 
	       if !self.wantsQuietChanges && supportsPasswordUpdate != oldValue {
	            self.provisionChanges(forKey: "supportsPasswordUpdate",oldValue: oldValue,newValue: supportsPasswordUpdate)  
	       } 
	    }
	}

	//If a local user has the same credentials can her/his password be syndicated
	@objc dynamic open var supportsPasswordSyndication:Bool = Bartleby.configuration.SUPPORTS_PASSWORD_SYNDICATION_BY_DEFAULT  {
	    didSet { 
	       if !self.wantsQuietChanges && supportsPasswordSyndication != oldValue {
	            self.provisionChanges(forKey: "supportsPasswordSyndication",oldValue: oldValue,newValue: supportsPasswordSyndication)  
	       } 
	    }
	}

	//A JFIF base 64 encoded picture of the user
	@objc dynamic open var base64Image:String? {
	    didSet { 
	       if !self.wantsQuietChanges && base64Image != oldValue {
	            self.provisionChanges(forKey: "base64Image",oldValue: oldValue,newValue: base64Image) 
	       } 
	    }
	}


    // MARK: - Codable


    fileprivate enum CodingKeys: String,CodingKey{
		case spaceUID
		case verificationMethod
		case localAssociationID
		case firstname
		case lastname
		case email
		case pseudo
		case phoneCountryCode
		case phoneNumber
		case password
		case status
		case notes
		case loginHasSucceed
		case isIsolated
		case supportsPasswordMemorization
		case supportsPasswordUpdate
		case supportsPasswordSyndication
		case base64Image
    }

    required public init(from decoder: Decoder) throws{
		try super.init(from: decoder)
        try self.quietThrowingChanges {
			let values = try decoder.container(keyedBy: CodingKeys.self)
			self.spaceUID = try values.decode(String.self,forKey:.spaceUID)
			self.verificationMethod = User.VerificationMethod(rawValue: try values.decode(String.self,forKey:.verificationMethod)) ?? .byPhoneNumber
			self.localAssociationID = try values.decode(String.self,forKey:.localAssociationID)
			self.firstname = try values.decode(String.self,forKey:.firstname)
			self.lastname = try values.decode(String.self,forKey:.lastname)
			self.email = try values.decode(String.self,forKey:.email)
			self.pseudo = try values.decode(String.self,forKey:.pseudo)
			self.phoneCountryCode = try values.decode(String.self,forKey:.phoneCountryCode)
			self.phoneNumber = try values.decode(String.self,forKey:.phoneNumber)
			self.password = try self.decodeCryptedStringIfPresent(codingKey: .password, from: values)
			self.status = User.Status(rawValue: try values.decode(String.self,forKey:.status)) ?? .new
			self.notes = try values.decodeIfPresent(String.self,forKey:.notes)
			self.isIsolated = try values.decode(Bool.self,forKey:.isIsolated)
			self.supportsPasswordMemorization = try values.decode(Bool.self,forKey:.supportsPasswordMemorization)
			self.supportsPasswordUpdate = try values.decode(Bool.self,forKey:.supportsPasswordUpdate)
			self.supportsPasswordSyndication = try values.decode(Bool.self,forKey:.supportsPasswordSyndication)
			self.base64Image = try values.decodeIfPresent(String.self,forKey:.base64Image)
        }
    }

    override open func encode(to encoder: Encoder) throws {
		try super.encode(to:encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.spaceUID,forKey:.spaceUID)
		try container.encode(self.verificationMethod.rawValue ,forKey:.verificationMethod)
		try container.encode(self.localAssociationID,forKey:.localAssociationID)
		try container.encode(self.firstname,forKey:.firstname)
		try container.encode(self.lastname,forKey:.lastname)
		try container.encode(self.email,forKey:.email)
		try container.encode(self.pseudo,forKey:.pseudo)
		try container.encode(self.phoneCountryCode,forKey:.phoneCountryCode)
		try container.encode(self.phoneNumber,forKey:.phoneNumber)
		try self.encodeCryptedStringIfPresent(value: self.password, codingKey: .password, container: &container)
		try container.encode(self.status.rawValue ,forKey:.status)
		try container.encodeIfPresent(self.notes,forKey:.notes)
		try container.encode(self.isIsolated,forKey:.isIsolated)
		try container.encode(self.supportsPasswordMemorization,forKey:.supportsPasswordMemorization)
		try container.encode(self.supportsPasswordUpdate,forKey:.supportsPasswordUpdate)
		try container.encode(self.supportsPasswordSyndication,forKey:.supportsPasswordSyndication)
		try container.encodeIfPresent(self.base64Image,forKey:.base64Image)
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override  open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["spaceUID","verificationMethod","localAssociationID","firstname","lastname","email","pseudo","phoneCountryCode","phoneNumber","password","status","notes","loginHasSucceed","isIsolated","supportsPasswordMemorization","supportsPasswordUpdate","supportsPasswordSyndication","base64Image"])
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
            case "pseudo":
                if let casted=value as? String{
                    self.pseudo=casted
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
            case "isIsolated":
                if let casted=value as? Bool{
                    self.isIsolated=casted
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
            case "base64Image":
                if let casted=value as? String{
                    self.base64Image=casted
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
            case "pseudo":
               return self.pseudo
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
            case "isIsolated":
               return self.isIsolated
            case "supportsPasswordMemorization":
               return self.supportsPasswordMemorization
            case "supportsPasswordUpdate":
               return self.supportsPasswordUpdate
            case "supportsPasswordSyndication":
               return self.supportsPasswordSyndication
            case "base64Image":
               return self.base64Image
            default:
                return try super.getExposedValueForKey(key)
        }
    }
    // MARK: - Initializable
    required public init() {
        super.init()
    }

    // MARK: - UniversalType
    override  open class var collectionName:String{
        return "users"
    }

    override  open var d_collectionName:String{
        return User.collectionName
    }
}