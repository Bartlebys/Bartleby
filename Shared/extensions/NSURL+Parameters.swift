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
    public func URLByAppendingQueryStringDictionary(dictionary:Dictionary<String,AnyObject>)->NSURL?{
        
        // Decompose the current url
        let components = NSURLComponents()
        components.scheme=self.scheme
        components.host=self.host
        components.path=self.path
        components.query=self.query
        
        var mutableQueryItems=Array<NSURLQueryItem>()
        if let queryItems=components.queryItems{
            for item in  queryItems {
                mutableQueryItems.append(item)
            }
        }
        
        // Add the dictionary value
        for (k,v) in dictionary{
            let queryItem=NSURLQueryItem(name: k, value:"\(v)")
            mutableQueryItems.append(queryItem)
        }
        components.queryItems=mutableQueryItems
        
        return components.URL
    }
}





