//
//  BUrl.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 13/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation


extension NSURL {

    /**
     Returns a new URL object by appending dictionary value to query string

     - parameter dictionary: dictionary description

     - returns: a new NSURL object
     */
    public func URLByAppendingQueryStringDictionary(dictionary: Dictionary<String, AnyObject>)->NSURL? {

        // Decompose the current url
        let components = NSURLComponents()
        components.scheme=self.scheme
        components.host=self.host
        components.path=self.path
        components.query=self.query


        var queryItems=[String]()
        if let query = self.query where !query.isEmpty {
            queryItems.append(query)
        }

        // Add the dictionary value
        for (k, v) in dictionary {
            queryItems.append("\(k)=\(v)")
        }
        components.query = queryItems.joinWithSeparator("&")

        return components.URL
    }
}
