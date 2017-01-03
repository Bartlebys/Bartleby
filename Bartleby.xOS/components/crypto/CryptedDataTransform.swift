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


    open func transformFromJSON(_ value: Any?) -> Data? {
        if let s=value as? String {
            let s=try? Bartleby.cryptoDelegate.encryptString(s,useKey:Bartleby.configuration.KEY)
            return s?.data(using: .utf8, allowLossyConversion: false)
        }
        return nil
    }

    open func transformToJSON(_ value: Object?) -> JSON? {
        if let data=value {
            if let s=String.init(data: data, encoding: .utf8){
                return try? Bartleby.cryptoDelegate.decryptString(s,useKey:Bartleby.configuration.KEY)
            }
        }
        return nil
    }
}
