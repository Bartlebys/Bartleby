//
//  CryptoDelegate.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 04/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

@objc public protocol CryptoDelegate {

    func encryptString(string: String)throws->String
    func decryptString(string: String)throws->String

    func encryptData(data: NSData)throws ->NSData
    func decryptData(data: NSData)throws ->NSData

    static func hash(string: String) -> String

}
