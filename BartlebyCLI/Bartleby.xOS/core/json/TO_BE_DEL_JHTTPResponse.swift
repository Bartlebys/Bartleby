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

@objc(_HTTPContext) open class _HTTPContext: BartlebyObject, CollectibleHTTPContext {


    // Universal type support
    override open class func typeName() -> String {
        return "HTTPContext"
    }


    // A developer set code to provide filtering
    open var code: UInt=UInt.max

    // A descriptive string for developper to identify the calling context
    open var caller: String=Default.NO_NAME

    // The related url
    open var relatedURL: URL?

    // The http status code
    open var httpStatusCode: Int?

    // The response
    open var response: Any?

    open var result: Any?

    public init(code: UInt!, caller: String!, relatedURL: URL?, httpStatusCode: Int, response: Any?, result: Any?) {
        self.code=code
        self.caller=caller
        self.relatedURL=relatedURL
        self.httpStatusCode=httpStatusCode
        self.response=response
        self.result=result
        super.init()
    }

    required public convenience  init() {
        self.init(code: 0, caller: "", relatedURL: nil, httpStatusCode: Int.max, response: nil, result:"")
    }

    // MARK: Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }


    override open func mapping(map: Map) {
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
