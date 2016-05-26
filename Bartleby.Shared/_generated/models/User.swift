//
//  User.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for benoit@pereira-da-silva.com
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  Chaosmos | https://chaosmos.fr  All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
import Alamofire
import ObjectMapper
#endif

// MARK: Bartleby's Core: a user in a specified data Space
@objc(User) public class User : JObject{

    // Universal type support
    override public class func typeName() -> String {
        return "User"
    }

	//The spaceUID. A user with the same credentials can exists within multiple Data space.
	public var spaceUID:String = "\(Bartleby.createUID())"{	 
	    willSet { 
	       if spaceUID != newValue {
	            self.provisionChanges() 
	       } 
	    }
	}

	//the verification method
	public enum VerificationMethod:String{
		case None = "None"
		case ByPhoneNumber = "ByPhoneNumber"
		case ByEmail = "ByEmail"
	}
	public var verificationMethod:VerificationMethod = .ByPhoneNumber  {	 
	    willSet { 
	       if verificationMethod != newValue {
	            self.provisionChanges() 
	       } 
	    }
	}

	public var firstname:String = "\(Bartleby.randomStringWithLength(5))"{	 
	    willSet { 
	       if firstname != newValue {
	            self.provisionChanges() 
	       } 
	    }
	}

	public var lastname:String = "\(Bartleby.randomStringWithLength(5))"{	 
	    willSet { 
	       if lastname != newValue {
	            self.provisionChanges() 
	       } 
	    }
	}

	//The user's email. Can be the secondary Identification source 
	public var email:String? {	 
	    willSet { 
	       if email != newValue {
	            self.provisionChanges() 
	       } 
	    }
	}

	//The user's phone number. Can be the secondary Identification source 
	public var phoneNumber:String? {	 
	    willSet { 
	       if phoneNumber != newValue {
	            self.provisionChanges() 
	       } 
	    }
	}

	//The hashed version of the user password
	public var password:String = "\(Bartleby.randomStringWithLength(8,signs:Bartleby.configuration.PASSWORD_CHAR_CART))"{	 
	    willSet { 
	       if password != newValue {
	            self.provisionChanges() 
	       } 
	    }
	}

	//An activation code
	public var activationCode:String = "\(Bartleby.randomStringWithLength(8,signs:Bartleby.configuration.PASSWORD_CHAR_CART))"{	 
	    willSet { 
	       if activationCode != newValue {
	            self.provisionChanges() 
	       } 
	    }
	}

	//User Status
	public enum Status:String{
		case New = "new"
		case Actived = "actived"
		case Suspended = "suspended"
	}
	public var status:Status = .New  {	 
	    willSet { 
	       if status != newValue {
	            self.provisionChanges() 
	       } 
	    }
	}

	//The user Tags. External reference to Tags instances
	public var tags:[ExternalReference] = [ExternalReference]()  {	 
	    willSet { 
	       if tags != newValue {
	            self.provisionChanges() 
	       } 
	    }
	}

	//The user Groups. External reference to Group instances
	public var groups:[ExternalReference] = [ExternalReference]()  {	 
	    willSet { 
	       if groups != newValue {
	            self.provisionChanges() 
	       } 
	    }
	}

	//Notes
	public var notes:String? {	 
	    willSet { 
	       if notes != newValue {
	            self.provisionChanges() 
	       } 
	    }
	}



    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
        self.lockAutoCommitObserver()
		self.spaceUID <- ( map["spaceUID"] )
		self.verificationMethod <- ( map["verificationMethod"] )
		self.firstname <- ( map["firstname"] )
		self.lastname <- ( map["lastname"] )
		self.email <- ( map["email"] )
		self.phoneNumber <- ( map["phoneNumber"] )
		self.password <- ( map["password"] )
		self.activationCode <- ( map["activationCode"] )
		self.status <- ( map["status"] )
		self.tags <- ( map["tags"] )
		self.groups <- ( map["groups"] )
		self.notes <- ( map["notes"] )
        self.unlockAutoCommitObserver()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.lockAutoCommitObserver()
		self.spaceUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "spaceUID")! as NSString)
		self.verificationMethod=User.VerificationMethod(rawValue:String(decoder.decodeObjectOfClass(NSString.self, forKey: "verificationMethod")! as NSString))! 
		self.firstname=String(decoder.decodeObjectOfClass(NSString.self, forKey: "firstname")! as NSString)
		self.lastname=String(decoder.decodeObjectOfClass(NSString.self, forKey: "lastname")! as NSString)
		self.email=String(decoder.decodeObjectOfClass(NSString.self, forKey:"email") as NSString?)
		self.phoneNumber=String(decoder.decodeObjectOfClass(NSString.self, forKey:"phoneNumber") as NSString?)
		self.password=String(decoder.decodeObjectOfClass(NSString.self, forKey: "password")! as NSString)
		self.activationCode=String(decoder.decodeObjectOfClass(NSString.self, forKey: "activationCode")! as NSString)
		self.status=User.Status(rawValue:String(decoder.decodeObjectOfClass(NSString.self, forKey: "status")! as NSString))! 
		self.tags=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),ExternalReference.classForCoder()]), forKey: "tags")! as! [ExternalReference]
		self.groups=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),ExternalReference.classForCoder()]), forKey: "groups")! as! [ExternalReference]
		self.notes=String(decoder.decodeObjectOfClass(NSString.self, forKey:"notes") as NSString?)
        self.unlockAutoCommitObserver()
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		coder.encodeObject(self.spaceUID,forKey:"spaceUID")
		coder.encodeObject(self.verificationMethod.rawValue ,forKey:"verificationMethod")
		coder.encodeObject(self.firstname,forKey:"firstname")
		coder.encodeObject(self.lastname,forKey:"lastname")
		if let email = self.email {
			coder.encodeObject(email,forKey:"email")
		}
		if let phoneNumber = self.phoneNumber {
			coder.encodeObject(phoneNumber,forKey:"phoneNumber")
		}
		coder.encodeObject(self.password,forKey:"password")
		coder.encodeObject(self.activationCode,forKey:"activationCode")
		coder.encodeObject(self.status.rawValue ,forKey:"status")
		coder.encodeObject(self.tags,forKey:"tags")
		coder.encodeObject(self.groups,forKey:"groups")
		if let notes = self.notes {
			coder.encodeObject(notes,forKey:"notes")
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
        return "users"
    }

    override public var d_collectionName:String{
        return User.collectionName
    }


}

