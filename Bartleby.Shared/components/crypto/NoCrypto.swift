//
//  NoCrypto.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 04/01/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

public class NoCrypto: NSObject, CryptoDelegate {


    public override init() {
        super.init()
    }


    public func encryptString(string: String)throws->String {
        return string
    }



    public func decryptString(string: String)throws->String {
        return string
    }


    public func encryptData(data: NSData)throws ->NSData {
        return data
    }


    public func decryptData(data: NSData)throws ->NSData {
        return data
    }



    public static func hash(string: String) -> String {
        return string
    }


}
