//
//  NoCrypto.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 04/01/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

open class NoCrypto: NSObject, CryptoDelegate {


    public override init() {
        super.init()
    }


    open func encryptString(_ string: String)throws->String {
        return string
    }


    open func decryptString(_ string: String)throws->String {
        return string
    }

    open func encryptData(_ data: Data)throws ->Data {
        return data
    }

    open func decryptData(_ data: Data)throws ->Data {
        return data
    }

    open static func hash(_ string: String) -> String {
        return string
    }


}
