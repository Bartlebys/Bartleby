//
//  HTTPRequest+URLRequest.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 27/10/2016.
//
//

import Foundation

extension HTTPRequest{



    /// Initialize an HTTPRequest from an URLRequest
    ///
    /// - parameter urlRequest: the url Request
    ///
    /// - returns: an HTTPRequest
    public convenience init(urlRequest:URLRequest){
        self.init()
        self.url=urlRequest.url
        self.httpMethod=urlRequest.httpMethod ?? Default.NO_METHOD
        self.headers=urlRequest.allHTTPHeaderFields
        self.httpBody=urlRequest.httpBody
        self.timeout=urlRequest.timeoutInterval
    }

    /// Returns and URLrequest from an HTTPRequest
    ///
    /// - returns: the URL request
    public func urlRequest()->URLRequest?{
        if let url=self.url{
            var r=URLRequest(url: url)
            r.httpMethod=self.httpMethod
            if let h=self.headers{
                for (k,v) in h {
                    r.addValue(v, forHTTPHeaderField: k)
                }
            }
            r.httpBody=self.httpBody
            r.timeoutInterval=self.timeout
            return r
        }
        return nil
    }

}
