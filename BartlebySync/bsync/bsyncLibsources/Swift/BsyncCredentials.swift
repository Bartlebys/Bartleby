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
    public static let DEBUG_DISABLE_ENCRYPTION=true // Should always be set to false in production (!)
    
    
    // CRYPTED
    public var user:User?
    public var password:String?
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
            user <- map["user"]
            password <- map ["password"]
            salt <- map ["salt"]
        }else{
            user <- (map["user"],CryptedSerializableTransform())
            password <- (map ["password"],CryptedStringTransform())
            salt <- (map ["salt"],CryptedStringTransform())
        }
    }
    
    
    // MARK: NSecureCoding
    
    public func encodeWithCoder(coder: NSCoder){
        coder.encodeObject(user, forKey: "user")
        coder.encodeObject(password, forKey: "password")
        coder.encodeObject(salt, forKey: "salt")
    }
    
    public required init?(coder decoder: NSCoder){
        self.user=User(coder: decoder)
        self.password=String(decoder.decodeObjectOfClass(NSString.self, forKey:"password") as NSString?)
        self.salt=String(decoder.decodeObjectOfClass(NSString.self, forKey:"salt") as NSString?)
    }
    
    public static func supportsSecureCoding() -> Bool{
        return true
    }
    
}
