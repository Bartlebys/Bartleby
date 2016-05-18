//
//  BUrl.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 13/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
        allowed.addCharactersInString(unreserved)
        return stringByAddingPercentEncodingWithAllowedCharacters(allowed)
    }
}



extension NSURL {

    /**
     Returns a new URL object by appending dictionary value to query string

     - parameter dictionary: dictionary description

     - returns: a new NSURL object
     */
    public func URLByAppendingQueryStringDictionary(dictionary: Dictionary<String, String>)->NSURL? {

        // Decompose the current url
        let components = NSURLComponents()
        components.scheme=self.scheme
        components.host=self.host
        components.path=self.path
        components.query=self.query

//        // Old implementation compatible only with 10.10
//        var mutableQueryItems=Array<NSURLQueryItem>()
//        if let queryItems=components.queryItems{
//            for item in  queryItems {
//                mutableQueryItems.append(item)
//            }
//        }
//        
//        components.queryItems=mutableQueryItems

        var queryItems=[String]()
        if let query = self.query where !query.isEmpty {
            queryItems.append(query)
        }

        // Add the dictionary value
        for (k, v) in dictionary {
            if let encodedK = k.stringByAddingPercentEncodingForRFC3986(), let encodedV = v.stringByAddingPercentEncodingForRFC3986() {
                queryItems.append("\(encodedK)=\(encodedV)")
            }
        }
        components.query = queryItems.joinWithSeparator("&")

        return components.URL
    }
}
