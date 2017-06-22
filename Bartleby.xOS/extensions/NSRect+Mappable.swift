//
//  NSRect+Mappable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 22/06/2017.
//
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

extension NSRect:Mappable{

    public init?(map: Map) {
        self.init()
    }

    public mutating func mapping(map: Map) {
        self.origin.x <- ( map["origin.x"] )
        self.origin.y <- ( map["origin.y"] )
        self.size.width <- ( map["size.width"] )
        self.size.height <- ( map["size.height"] )
    }
    
}
