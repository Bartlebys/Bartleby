//
//  Asset+ImageSupport.swift
//  YouDub
//
//  Created by Benoit Pereira da silva on 15/08/2017.
//  Copyright © 2017 Lylo Media Group SA. All rights reserved.
//

import Foundation
#if os(OSX)
    import AppKit
#elseif os(iOS)
    import UIKit
#elseif os(watchOS)
#elseif os(tvOS)
#endif



enum XImageError:Error {
    case bitmapRepresentationHasFailed
    case dataRepresentationHasFailed
    case dataDecodingHasFailed
}

public extension XImage{

    static let DEFAULT_COMPRESSION_FACTOR:Double = 0.7

    //#TODO iOS Support

    public static func from(_ data:Data) throws ->XImage?{
        guard let image = XImage(data:data) else{
            throw XImageError.dataDecodingHasFailed
        }
        return image
    }

    public func JPEGdata(compressionFactor:Double=XImage.DEFAULT_COMPRESSION_FACTOR)throws ->Data{
        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(self.size.width),
            pixelsHigh: Int(self.size.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: NSColorSpaceName.deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
            ) else {
                throw XImageError.bitmapRepresentationHasFailed
        }
        let cf = (compressionFactor <= 1.0 && compressionFactor >= 0 ) ? compressionFactor : XImage.DEFAULT_COMPRESSION_FACTOR
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        self.draw(at: NSZeroPoint, from: NSZeroRect, operation: .sourceOver, fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        guard let data = rep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [NSBitmapImageRep.PropertyKey.compressionFactor: cf]) else {
            throw XImageError.dataRepresentationHasFailed
        }
        return data
    }


    public var JPEGBase64String:String? {
        if let data = try? JPEGdata(){
            return data.base64EncodedString(options: [])
        }
        return nil
    }

    public static func fromJPEGBase64String(string:String)->XImage?{
        if let data = Data(base64Encoded: string){
            return XImage(data: data)
        }
        return nil
    }


}
