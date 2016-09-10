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


(BsyncCredentials) open class BsyncCredentials: JObject {

    override open class func typeName() -> String {
        return "BsyncCredentials"
    }


    // CRYPTED
    open var user: User?
    open var password: String?
    open var salt: String?

    public required init() {
        super.init()
    }

    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init()
        self.mapping(map)
    }

    override open func mapping(_ map: Map) {
        super.mapping(map)
        self.disableSupervision()
        user <- (map["user"], CryptedSerializableTransform())
        password <- (map ["password"], CryptedStringTransform())
        salt <- (map ["salt"], CryptedStringTransform())
        self.enableSupervision()
    }


    // MARK: NSecureCoding

    override open func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(user, forKey: "user")
        coder.encode(password, forKey: "password")
        coder.encode(salt, forKey: "salt")
    }

    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.disableSupervision()
        self.user=User(coder: decoder)
        self.password=String(describing: decoder.decodeObject(of: NSString.self, forKey:"password") as NSString?)
        self.salt=String(describing: decoder.decodeObject(of: NSString.self, forKey:"salt") as NSString?)
        self.enableSupervision()
    }


    override open class func supportsSecureCoding() -> Bool {
        return true
    }


    // MARK: Identifiable

    override open class var collectionName: String {
        return "BsyncCredentials"
    }

    override open var d_collectionName: String {
        return BsyncCredentials.collectionName
    }




}
