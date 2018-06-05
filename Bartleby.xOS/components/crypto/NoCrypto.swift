//
//  NoCrypto.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 04/01/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation


// A Neutral CryptoDelegate
open class NoCrypto: NSObject, CryptoDelegate {


    // Those function are work by pairs.
    // Do not combinate.


    public override init() {
        super.init()
    }

    // MARK: - Encryption + Base64 encoding / decoding

    open func encryptString(_ string: String,useKey:String)throws->String {
        return string
    }

    open func decryptString(_ string: String,useKey:String)throws->String {
        return string
    }


    // MARK: - Raw Data encryption

    open func encryptData(_ data: Data,useKey:String)throws ->Data {
        return data
    }

    open func decryptData(_ data: Data,useKey:String)throws ->Data {
        return data
    }

    // MARK: - String encryption without reencoding (the crypted data is not a valid String but this approach is faster)

    open func encryptStringToData(_ string:String,useKey:String)throws->Data{
        if let d = string.data(using: .utf8){
            return d
        }else{
            throw CryptoHelper.CryptoError.codingError(message: "UTF8 decoding issue")
        }
    }

    open func decryptStringFromData(_ data:Data,useKey:String)throws->String{
        if let s = String(data: data, encoding: .utf8){
            return s
        }else{
             throw CryptoHelper.CryptoError.codingError(message: "UTF8 encoding issue")
        }
    }

    // MARK: -

    public static func hashString(_ string: String) -> String {
        return string
    }

}
