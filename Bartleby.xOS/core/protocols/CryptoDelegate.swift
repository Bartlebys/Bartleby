//
//  CryptoDelegate.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 04/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

/*

 Note on Strings:

 **IMPORTANT!**
 Don't use EncryptData, DecryptData on Utf8 strings.

 Always Use symetric calls :

 - 'encryptString' / 'decryptString' if you need for example to copy and paste the sample
 - 'encryptStringToData' / 'decryptStringFromData' for example for faster serialization

 */
public protocol CryptoDelegate {
    // Those function are work by pairs.
    // Do not combinate.

    // MARK: - Encryption + Base64 encoding / decoding

    func encryptString(_ string: String, useKey: String) throws -> String
    func decryptString(_ string: String, useKey: String) throws -> String

    // MARK: - Raw Data encryption

    func encryptData(_ data: Data, useKey: String) throws -> Data
    func decryptData(_ data: Data, useKey: String) throws -> Data

    // MARK: - String encryption without reencoding (the crypted data is not a valid String but this approach is faster)

    func encryptStringToData(_ string: String, useKey: String) throws -> Data
    func decryptStringFromData(_ data: Data, useKey: String) throws -> String

    // MARK: -

    static func hashString(_ string: String) -> String
}
