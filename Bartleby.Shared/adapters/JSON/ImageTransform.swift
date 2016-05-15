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

#if os(OSX)
    import AppKit
#elseif os(iOS)
    import UIKit
#elseif os(watchOS)
#elseif os(tvOS)
#endif


// TODO: @md write the Unit test for OSX and IOS + integrate in all the targets
public class ImageTransform: TransformType {

    public typealias Object = BXImage
    public typealias JSON = String

    public init() {

    }

    public func transformFromJSON(value: AnyObject?) -> Object? {
        if let string=value as? String {
            if let data=NSData(base64EncodedString: string, options: [.IgnoreUnknownCharacters]) {
                return BXImage.init(data: data)
            }
        }
        return nil
    }

    public func transformToJSON(value: Object?) -> JSON? {
        if let image=value {
            #if os(OSX)
                // We use a tiff representation
                let data=image.TIFFRepresentation
                if let d=data {
                    return d.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
                }
            #elseif os(iOS)
                if let image=value {
                    let data = UIImagePNGRepresentation(image)
                    if let d=data {
                        return d.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
                    }
                }
            #elseif os(watchOS)
            #elseif os(tvOS)
            #endif
        }
         return nil
    }
}
