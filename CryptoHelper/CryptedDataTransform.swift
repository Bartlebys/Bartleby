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

open class CryptedDataTransform: TransformType {

    public typealias Object = Data
    public typealias JSON = String


    open func transformFromJSON(_ value: AnyObject?) -> Object? {
        if let s=value as? String {
            if let data=s.data(using: Default.STRING_ENCODING, allowLossyConversion:false) {
                return try? Bartleby.cryptoDelegate.decryptData(data)
            }
        }
        return nil
    }

    open func transformToJSON(_ value: Object?) -> JSON? {
        if let d=value as Data? {
            return d.base64EncodedString(options: .endLineWithCarriageReturn)
        }
        return nil
    }
}
