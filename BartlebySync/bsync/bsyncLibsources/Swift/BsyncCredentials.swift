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


@objc(BsyncCredentials) public class BsyncCredentials: JObject {

    override public class func typeName() -> String {
        return "BsyncCredentials"
    }


    // CRYPTED
    public var user: User?
    public var password: String?
    public var salt: String?

    public required init() {
        super.init()
    }

    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init()
        self.mapping(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
        self.lockAutoCommitObserver()
        user <- (map["user"], CryptedSerializableTransform())
        password <- (map ["password"], CryptedStringTransform())
        salt <- (map ["salt"], CryptedStringTransform())
        self.unlockAutoCommitObserver()
    }


    // MARK: NSecureCoding

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        coder.encodeObject(user, forKey: "user")
        coder.encodeObject(password, forKey: "password")
        coder.encodeObject(salt, forKey: "salt")
    }

    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.lockAutoCommitObserver()
        self.user=User(coder: decoder)
        self.password=String(decoder.decodeObjectOfClass(NSString.self, forKey:"password") as NSString?)
        self.salt=String(decoder.decodeObjectOfClass(NSString.self, forKey:"salt") as NSString?)
        self.unlockAutoCommitObserver()
    }


    override public class func supportsSecureCoding() -> Bool {
        return true
    }


    // MARK: Identifiable

    override public class var collectionName: String {
        return "BsyncCredentials"
    }

    override public var d_collectionName: String {
        return BsyncCredentials.collectionName
    }




}
