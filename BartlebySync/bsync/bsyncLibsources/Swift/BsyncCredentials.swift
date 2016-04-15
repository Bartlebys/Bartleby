//
//  BsyncCredentials.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da silva on 05/02/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
    import BartlebyKit
#endif



@objc(BsyncCredentials) public class BsyncCredentials : NSObject,Mappable,NSSecureCoding{
    
    
    /// Debug facility
    public static let DEBUG_DISABLE_ENCRYPTION=false // Should always be set to false in production (!)
    
    
    // CRYPTED
    public var spaceUID:String?
    public var email:String?
    public var password:String?
    public var phoneNumber:String?
    public var salt:String?
    
    public required override init(){
        super.init()
    }
    
    // MARK: Mappable
    

    
    required public init?(_ map: Map) {
        super.init()
        self.mapping(map)
    }
    
    public func mapping(map: Map) {
        if BsyncCredentials.DEBUG_DISABLE_ENCRYPTION {
            spaceUID <- map["spaceUID"]
            email <- map["email"]
            phoneNumber <- map["phoneNumber"]
            password <- map ["password"]
            salt <- map ["salt"]
        }else{
            spaceUID <- (map["spaceUID"],CryptedStringTransform())
            email <- (map["email"],CryptedStringTransform())
            phoneNumber <- (map["phoneNumber"],CryptedStringTransform())
            password <- (map ["password"],CryptedStringTransform())
            salt <- (map ["salt"],CryptedStringTransform())
        }
    }
    
    
    // MARK: NSecureCoding
    
    public func encodeWithCoder(coder: NSCoder){
        coder.encodeObject(spaceUID, forKey: "spaceUID")
        coder.encodeObject(email, forKey: "email")
        coder.encodeObject(phoneNumber, forKey: "phoneNumber")
        coder.encodeObject(password, forKey: "password")
        coder.encodeObject(salt, forKey: "salt")
    }
    
    public required init?(coder decoder: NSCoder){
        self.spaceUID=String(decoder.decodeObjectOfClass(NSString.self, forKey:"spaceUID") as NSString?)
        self.email=String(decoder.decodeObjectOfClass(NSString.self, forKey:"email") as NSString?)
        self.phoneNumber=String(decoder.decodeObjectOfClass(NSString.self, forKey:"phoneNumber") as NSString?)
        self.password=String(decoder.decodeObjectOfClass(NSString.self, forKey:"password") as NSString?)
        self.salt=String(decoder.decodeObjectOfClass(NSString.self, forKey:"salt") as NSString?)
    }
    
    public static func supportsSecureCoding() -> Bool{
        return true
    }
    
}
