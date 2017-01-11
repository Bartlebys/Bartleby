//
//  Identification.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 30/12/2016.
//
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

public struct Identification:Mappable {

    public var email:String=""
    public var phoneCountryCode:String=""
    public var phoneNumber:String=""
    public var password:String=""
    public var externalID:String=Default.NO_UID

    public init() {}

    public init?(map: Map) {}

    public mutating func mapping(map: Map) {
        self.email <- ( map["email"] )
        self.phoneCountryCode <- ( map["phoneCountryCode"] )
        self.phoneNumber <- ( map["phoneNumber"] )
        self.password <- ( map["password"] )
        self.externalID <- (map["externalID"])
    }
}
