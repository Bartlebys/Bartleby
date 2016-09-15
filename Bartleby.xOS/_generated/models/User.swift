//
//  User.swift
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

// MARK: Bartleby's Core: a user in a specified data Space
@objc(User) open class User : JObject{

    // Universal type support
    override open class func typeName() -> String {
        return "User"
    }

	//An external unique identifier
	dynamic open var externalID:String? {	 
	    didSet { 
	       if externalID != oldValue {
	            self.provisionChanges(forKey: "externalID",oldValue: oldValue,newValue: externalID) 
	       } 
	    }
	}

	//The spaceUID. A user with the same credentials can exists within multiple Data space.
	dynamic open var spaceUID:String = "\(Bartleby.createUID())"{	 
	    didSet { 
	       if spaceUID != oldValue {
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
	       if verificationMethod != oldValue {
	            self.provisionChanges(forKey: "verificationMethod",oldValue: oldValue.rawValue,newValue: verificationMethod.rawValue)  
	       } 
	    }
	}

	dynamic open var firstname:String = "\(Bartleby.randomStringWithLength(5))"{	 
	    didSet { 
	       if firstname != oldValue {
	            self.provisionChanges(forKey: "firstname",oldValue: oldValue,newValue: firstname) 
	       } 
	    }
	}

	dynamic open var lastname:String = "\(Bartleby.randomStringWithLength(5))"{	 
	    didSet { 
	       if lastname != oldValue {
	            self.provisionChanges(forKey: "lastname",oldValue: oldValue,newValue: lastname) 
	       } 
	    }
	}

	//The user's email. Can be the secondary Identification source 
	dynamic open var email:String? {	 
	    didSet { 
	       if email != oldValue {
	            self.provisionChanges(forKey: "email",oldValue: oldValue,newValue: email) 
	       } 
	    }
	}

	//The user's phone number. Can be the secondary Identification source 
	dynamic open var phoneNumber:String? {	 
	    didSet { 
	       if phoneNumber != oldValue {
	            self.provisionChanges(forKey: "phoneNumber",oldValue: oldValue,newValue: phoneNumber) 
	       } 
	    }
	}

	//The hashed version of the user password
	dynamic open var password:String = "\(Bartleby.randomStringWithLength(8,signs:Bartleby.configuration.PASSWORD_CHAR_CART))"{	 
	    didSet { 
	       if password != oldValue {
	            self.provisionChanges(forKey: "password",oldValue: oldValue,newValue: password) 
	       } 
	    }
	}

	//An activation code
	dynamic open var activationCode:String = "\(Bartleby.randomStringWithLength(8,signs:Bartleby.configuration.PASSWORD_CHAR_CART))"{	 
	    didSet { 
	       if activationCode != oldValue {
	            self.provisionChanges(forKey: "activationCode",oldValue: oldValue,newValue: activationCode) 
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
	       if status != oldValue {
	            self.provisionChanges(forKey: "status",oldValue: oldValue.rawValue,newValue: status.rawValue)  
	       } 
	    }
	}

	//The user Tags. External reference to Tags instances
	dynamic open var tags:[ExternalReference] = [ExternalReference]()  {	 
	    didSet { 
	       if tags != oldValue {
	            self.provisionChanges(forKey: "tags",oldValue: oldValue,newValue: tags)  
	       } 
	    }
	}

	//Notes
	dynamic open var notes:String? {	 
	    didSet { 
	       if notes != oldValue {
	            self.provisionChanges(forKey: "notes",oldValue: oldValue,newValue: notes) 
	       } 
	    }
	}

	//set to true on the first successfull login in the session (this property is not serialized)
	dynamic open var loginHasSucceed:Bool = false


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override open func mapping(_ map: Map) {
        super.mapping(map)
        self.silentGroupedChanges {
			self.externalID <- ( map["externalID"] )
			self.spaceUID <- ( map["spaceUID"] )
			self.verificationMethod <- ( map["verificationMethod"] )
			self.firstname <- ( map["firstname"] )
			self.lastname <- ( map["lastname"] )
			self.email <- ( map["email"] )
			self.phoneNumber <- ( map["phoneNumber"] )
			self.password <- ( map["password"], CryptedStringTransform() )
			self.activationCode <- ( map["activationCode"] )
			self.status <- ( map["status"] )
			self.tags <- ( map["tags"] )
			self.notes <- ( map["notes"] )
        }
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self.externalID=String(describing: decoder.decodeObject(of: NSString.self, forKey:"externalID") as NSString?)
			self.spaceUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "spaceUID")! as NSString)
			self.verificationMethod=User.VerificationMethod(rawValue:String(describing: decoder.decodeObject(of: NSString.self, forKey: "verificationMethod")! as NSString))! 
			self.firstname=String(describing: decoder.decodeObject(of: NSString.self, forKey: "firstname")! as NSString)
			self.lastname=String(describing: decoder.decodeObject(of: NSString.self, forKey: "lastname")! as NSString)
			self.email=String(describing: decoder.decodeObject(of: NSString.self, forKey:"email") as NSString?)
			self.phoneNumber=String(describing: decoder.decodeObject(of: NSString.self, forKey:"phoneNumber") as NSString?)
			self.password=String(describing: decoder.decodeObject(of: NSString.self, forKey: "password")! as NSString)
			self.activationCode=String(describing: decoder.decodeObject(of: NSString.self, forKey: "activationCode")! as NSString)
			self.status=User.Status(rawValue:String(describing: decoder.decodeObject(of: NSString.self, forKey: "status")! as NSString))! 
			self.tags=decoder.decodeObject(of: [NSArray.classForCoder(),ExternalReference.classForCoder()], forKey: "tags")! as! [ExternalReference]
			self.notes=String(describing: decoder.decodeObject(of: NSString.self, forKey:"notes") as NSString?)
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		if let externalID = self.externalID {
			coder.encode(externalID,forKey:"externalID")
		}
		coder.encode(self.spaceUID,forKey:"spaceUID")
		coder.encode(self.verificationMethod.rawValue ,forKey:"verificationMethod")
		coder.encode(self.firstname,forKey:"firstname")
		coder.encode(self.lastname,forKey:"lastname")
		if let email = self.email {
			coder.encode(email,forKey:"email")
		}
		if let phoneNumber = self.phoneNumber {
			coder.encode(phoneNumber,forKey:"phoneNumber")
		}
		coder.encode(self.password,forKey:"password")
		coder.encode(self.activationCode,forKey:"activationCode")
		coder.encode(self.status.rawValue ,forKey:"status")
		coder.encode(self.tags,forKey:"tags")
		if let notes = self.notes {
			coder.encode(notes,forKey:"notes")
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
        return "users"
    }

    override open var d_collectionName:String{
        return User.collectionName
    }


}

