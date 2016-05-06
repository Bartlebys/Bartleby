//
//  JConsignableHTTPContext.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 08/12/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation
#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

@objc (JHTTPResponse) public class JHTTPResponse: JObject, HTTPResponse {

    // A developer set code to provide filtering
    public var code: UInt=UInt.max

    // A descriptive string for developper to identify the calling context
    public var caller: String=Default.NO_NAME

    // The related url
    public var relatedURL: NSURL!

    // The http status code
    public var httpStatusCode: Int!

    // The response
    public var response: AnyObject?

    public var result: AnyObject?

    public init(code: UInt!, caller: String!, relatedURL: NSURL!, httpStatusCode: Int!, response: AnyObject?, result: AnyObject?="") {
        self.code=code
        self.caller=caller
        self.relatedURL=relatedURL
        self.httpStatusCode=httpStatusCode
        self.response=response
        self.result=result
        super.init()
    }

    required public convenience  init() {
        self.init(code: 0, caller: "", relatedURL: NSURL(), httpStatusCode: Int.max, response: nil, result:"")
    }

    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
        mapping(map)
    }


    override public func mapping(map: Map) {
        code <- map["code"]
        caller <- map["caller"]
        relatedURL <- map["relatedURL"]
        httpStatusCode <- map["httpStatusCode"]
        response <- map["response"]
        result <- map["result"]
    }


    //TODO: @bpds NSSecureCoding
    required public init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
