//
//  BartlebyError.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 19/05/2016.
//
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

struct PositionnableError: Mappable, RawRepresentable {

    typealias rawValue=String

    var file: String?
    var function: String?
    var line: Int?
    var message: String?
    var code: Int?

    init(file: String, function: String, line: Int, message: String, code: Int) {
        self.file=file
        self.function=function
        self.line=line
    }

    public init?(rawValue: Self.RawValue) {

    }

    public var rawValue: Self.RawValue {
        get {
            return Mapper().toJSONString(self, prettyPrint:false)!
        }
    }

    public init?(_ map: Map) {
    }

    public mutating func mapping(map: Map) {
        self.file <- map["file"]
        self.function <- map["function"]
        self.line <- map["line"]
        self.message <- map["message"]
        self.code <- map["code"]
    }
}

enum BartlebyError: PositionnableError {
}
