//
//  HTTPContext+Conveniences.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 27/10/2016.
//
//

import Foundation

extension HTTPContext{

    public convenience init(code: Int!, caller: String!, relatedURL: URL?, httpStatusCode: Int, response: Any?, result: Any?) {
        self.init()
        self.code=code
        self.caller=caller
        self.relatedURL=relatedURL
        self.httpStatusCode=httpStatusCode
        self.response=response
        self.result=result

    }

    /*
    required public convenience  init() {
        self.init(code: 0, caller: "", relatedURL: nil, httpStatusCode: Int.max, response: nil, result:"")
    }
 */


}
