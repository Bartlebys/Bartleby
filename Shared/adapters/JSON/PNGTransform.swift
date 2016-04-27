//
//  PNGTransform.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 27/04/2016.
//
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

/*

public class PNGTransform: TransformType {
    
    public typealias Object = BXImage
    public typealias JSON = String
    
    public init() {
        
    }
    
    public func transformFromJSON(value: AnyObject?) -> Object?{
        if let string=value as? String{
            let data=NSData(base64EncodedString: string, options: [.IgnoreUnknownCharacters])
            
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
 */