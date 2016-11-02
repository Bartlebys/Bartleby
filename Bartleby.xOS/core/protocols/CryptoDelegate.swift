//
//  CryptoDelegate.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 04/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

@objc public protocol CryptoDelegate {

    // TODO: @md #crypto Remove throw for encryption
    func encryptString(_ string: String)throws->String
    func decryptString(_ string: String)throws->String

    func encryptData(_ data: Data)throws ->Data
    func decryptData(_ data: Data)throws ->Data

    static func hashString(_ string: String) -> String

}
