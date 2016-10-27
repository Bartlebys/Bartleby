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


// TODO: @md #test write the Unit test for OSX and IOS + integrate in all the targets
open class ImageTransform: TransformType {
    #if os(OSX)
    public typealias Object = NSImage
    #elseif os(iOS)
    public typealias Object = UIImage
    #elseif os(watchOS)
    #elseif os(tvOS)
    #endif
    public typealias JSON = String

    public init() {}

    #if os(OSX)
    open func transformFromJSON(_ value: Any?) -> NSImage? {
    if let string=value as? String {
        if let data=Data(base64Encoded: string, options: [.ignoreUnknownCharacters]) {
            return NSImage(data:data)
        }
    }
    return nil
    }
    #elseif os(iOS)
    open func transformFromJSON(_ value: Any?) -> UIImage? {
        if let string=value as? String {
            if let data=Data(base64Encoded: string, options: [.ignoreUnknownCharacters]) {
                return UIImage(data:data)
            }
        }
        return nil
    }
    #elseif os(watchOS)
    #elseif os(tvOS)
    #endif

    open func transformToJSON(_ value: Object?) -> JSON? {
        if let image=value {
            #if os(OSX)
                // We use a tiff representation
                let data=image.tiffRepresentation
                if let d=data {
                    return d.base64EncodedString(options: .endLineWithCarriageReturn)
                }
            #elseif os(iOS)
                if let image=value {
                    let data = UIImagePNGRepresentation(image)
                    if let d=data {
                        return d.base64EncodedString(options:.endLineWithCarriageReturn)
                    }
                }
            #elseif os(watchOS)
            #elseif os(tvOS)
            #endif
        }
        return nil
    }
}
