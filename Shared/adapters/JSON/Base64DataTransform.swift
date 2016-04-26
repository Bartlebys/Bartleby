//
//  Base64DataTransform.swift
//  bsync
//
//  Created by Martin Delille on 25/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

public class Base64DataTransform: TransformType {
    public typealias Object = NSData
    public typealias JSON = String
    
    public init() {
        
    }
    
    public func transformFromJSON(value: AnyObject?) -> Object?{
        if let string=value as? String{
            return NSData(base64EncodedString: string, options: [.IgnoreUnknownCharacters])
        }
        return nil
    }
    
    public func transformToJSON(value: Object?) -> JSON?{
        if let d=value as NSData? {
            return d.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
        }
        return nil
    }
}