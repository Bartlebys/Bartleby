//
//  BsyncCredentials.swift
//  Bsync
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for Benoit Pereira da Silva https://pereira-da-silva.com/contact
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  Bartleby's https://bartlebys.org   All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
	import Alamofire
	import ObjectMapper
	import BartlebyKit
#endif

// MARK: Credentials to be used in bsync
@objc(BsyncCredentials) open class BsyncCredentials : BartlebyObject{

    // Universal type support
    override open class func typeName() -> String {
        return "BsyncCredentials"
    }

	//The crypted user
	dynamic open var user:User?

	//The password
	dynamic open var password:String?

	//The salt used in the crypto chain
	dynamic open var salt:String?

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["user","password","salt"])
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
            case "user":
                if let casted=value as? User{
                    self.user=casted
                }
            case "password":
                if let casted=value as? String{
                    self.password=casted
                }
            case "salt":
                if let casted=value as? String{
                    self.salt=casted
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
            case "user":
               return self.user
            case "password":
               return self.password
            case "salt":
               return self.salt
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
        self.silentGroupedChanges {
			self.user <- ( map["user"], CryptedSerializableTransform() )
			self.password <- ( map["password"], CryptedStringTransform() )
			self.salt <- ( map["salt"], CryptedStringTransform() )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self.user=decoder.decodeObject(of:User.self, forKey: "user") 
			self.password=String(describing: decoder.decodeObject(of: NSString.self, forKey:"password") as NSString?)
			self.salt=String(describing: decoder.decodeObject(of: NSString.self, forKey:"salt") as NSString?)
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		if let user = self.user {
			coder.encode(user,forKey:"user")
		}
		if let password = self.password {
			coder.encode(password,forKey:"password")
		}
		if let salt = self.salt {
			coder.encode(salt,forKey:"salt")
		}
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

     required public init() {
        super.init()
    }

    override open class var collectionName:String{
        return "bsyncCredentials"
    }

    override open var d_collectionName:String{
        return BsyncCredentials.collectionName
    }
}


// MARK: Shadow

open class BsyncCredentialsShadow :BsyncCredentials,Shadow{

    static func from(_ entity:BsyncCredentials)->BsyncCredentialsShadow{
        let shadow=BsyncCredentialsShadow()
            shadow.silentGroupedChanges {
            for k in entity.exposedKeys{
                try? shadow.setExposedValue(entity.getExposedValueForKey(k), forKey: k)
            }
            try? shadow.setShadowUID(UID: entity.UID)
        }
        return shadow
    }

    // MARK: Universal type support

    override open class func typeName() -> String {
        return "BsyncCredentialsShadow"
    }

    // MARK: Collectible

    override open class var collectionName:String{
        return "bsyncCredentialsShadow"
    }

    override open var d_collectionName:String{
        return BsyncCredentialsShadow.collectionName
    }
}