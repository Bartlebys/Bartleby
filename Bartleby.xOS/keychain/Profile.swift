//
//  Profile.swift
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

public struct Profile:Mappable{

    public var url:URL=Bartleby.configuration.API_BASE_URL
    public var documentUID:String=Default.NO_UID
    public var documentSpaceUID:String=Default.NO_UID
    public var user:User?
    public var requiresPatch=false

    public init() {}

    public init?(map: Map) {}

    public mutating func mapping(map: Map) {
        self.url <- ( map["url"],URLTransform(shouldEncodeURLString:false))
        self.documentUID <- (map["documentUID"])
        self.documentSpaceUID <- (map["documentSpaceUID"])
        self.user <- ( map["user"] )
        self.requiresPatch <- ( map["requiresPatch"] )
    }
}
