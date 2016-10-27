//
//  HTTPContext+Conveniences.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 27/10/2016.
//
//

import Foundation

extension HTTPContext{

    public convenience init(code: Int!, caller: String!, relatedURL: URL?, httpStatusCode: Int, responseString:String="") {
        self.init()
        self.code=code
        self.caller=caller
        self.relatedURL=relatedURL
        self.httpStatusCode=httpStatusCode
        self.responseString=responseString
    }


}
