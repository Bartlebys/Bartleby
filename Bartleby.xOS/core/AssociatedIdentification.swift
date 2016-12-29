//
//  AssociatedIdentification.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
    import Locksmith
#endif

public struct AssociatedIdentification:Mappable{

    public var url:URL=Bartleby.configuration.API_BASE_URL
    public var documentUID:String=Default.NO_UID
    public var userUID:String=Default.NO_UID

    public init?(map: Map) {}

    public mutating func mapping(map: Map) {
        self.url <- ( map["email"] )
        self.documentUID <- (map["documentUID"])
        self.userUID <- ( map["phone"] )
    }
}
