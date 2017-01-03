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

    var email:String=""
    var phoneNumber:String=""
    var password:String=""
    var externalID:String=Default.NO_UID

    public init() {}

    public init?(map: Map) {}

    public mutating func mapping(map: Map) {
        self.email <- ( map["email"] )
        self.phoneNumber <- ( map["phoneNumber"] )
        self.password <- ( map["password"] )
        self.externalID <- (map["externalID"])
    }
}
