//
//  CryptedDataTransform.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 05/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

public class CryptedDataTransform: TransformType {

    public typealias Object = NSData
    public typealias JSON = String


    public func transformFromJSON(value: AnyObject?) -> Object? {
        if let s=value as? String {
            if let data=s.dataUsingEncoding(Default.TEXT_ENCODING, allowLossyConversion:false) {
                return try? Bartleby.cryptoDelegate.decryptData(data)
            }
        }
        return nil
    }

    public func transformToJSON(value: Object?) -> JSON? {
        if let d=value as NSData? {
            return d.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
        }
        return nil
    }
}
