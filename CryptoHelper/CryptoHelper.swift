//
//  CryptoHelper.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 12/11/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

@objc open class CryptoHelper: NSObject, CryptoDelegate {

    let salt: String

    let key: String

    var options: CCOptions=UInt32(kCCOptionPKCS7Padding)



    public init(key: String, salt: String="ea1f-56cb-41cf-59bf-6b09-87e8-2aca-5dfz") {
        self.key=key
        self.salt=salt
    }

    // We use a hash of the _salt+key as initialization vector
    lazy var initializationVector: Data?=CryptoHelper.hash(self.salt + self.key).data(using: Default.STRING_ENCODING, allowLossyConversion:false)


    // MARK: - Cryptography

    enum CryptoError: Error {
        case keyIsInvalid
        case errorWithStatusCode(cryptStatus:Int)
        case codingError(message:String)
        case decryptBase64Failure
    }


    open func dumpDebug() {
        print("hash of key is \(CryptoHelper.hash(key))")
        print("hash of salt is \(CryptoHelper.hash(salt))")
    }

    /**
     Encrypt a string to a base 64 string containing the corresponding crypted buffer

     - parameter string: A string

     - throws: Crypt operation error

     - returns: A base 64 string representing a crypted buffer
     */
    open func encryptString(_ string: String) throws ->String {
        if let data=string.data(using: String.Encoding.utf8, allowLossyConversion:false) {
            let crypted=try encryptData(data)
            if let cryptedString=String(data: crypted, encoding:String.Encoding.utf8) {
                return cryptedString
            } else {
                throw CryptoError.codingError(message: "Invalid crypted data (not UTF8)")
            }
        }
        throw CryptoError.codingError(message: "Error converting UTF8 string to data")
    }

    /**
     Decrypt a base 64 string containing a crypted buffer

     - parameter string: A base 64 string

     - throws: It can throw if the input string doesn't contains base 64 data, or if the decrypt
     buffer doesn't contains valid utf8 data, or if there is a crypto operation error

     - returns: A string
     */
    open func decryptString(_ string: String) throws ->String {
        if let data=string.data(using: String.Encoding.utf8, allowLossyConversion:false) {
            let decrypted=try decryptData(data)
            if let decryptedString=String(data: decrypted, encoding:String.Encoding.utf8) {
                return decryptedString
            }
        }
        throw CryptoError.decryptBase64Failure

    }

    /**
     Encrypt a data buffer

     - parameter data: The buffer to encrypt

     - throws: A crypto operation error

     - returns: An encrypted buffer
     */
    open func encryptData(_ data: Data) throws ->Data {
        let crypted=try self._encryptOperation(CCOperation(kCCEncrypt), on: data)
        // (!) IMPORTANT
        // the crypted data may produces invalid UTF8 data producing nil Strings
        // We need to base64 encode any NSData.
        let b64Data=crypted.base64EncodedData(options: .endLineWithCarriageReturn)
        return b64Data
    }

    /**
     Decrypt a data buffer

     - parameter data: A crypted buffer

     - throws: A crypto operation error

     - returns: A decrypted buffer
     */
    open func decryptData(_ data: Data) throws ->Data {
        if let b64Data=Data(base64Encoded: data, options: [.ignoreUnknownCharacters]) {
            return try self._encryptOperation(CCOperation(kCCDecrypt), on:b64Data)
        }
        throw CryptoError.decryptBase64Failure
    }


    // MARK: Crypt operation

    fileprivate func _encryptOperation(_ operation: CCOperation, on data: Data) throws ->Data {
        if let d=self.key.data(using: Default.STRING_ENCODING, allowLossyConversion:false) {
            let data = try self._cryptOperation(data, keyData: d, operation: operation)
            return data
        } else {
            throw CryptoError.keyIsInvalid
        }
    }

    fileprivate func _cryptOperation(_ data: Data, keyData: Data, operation: CCOperation) throws -> Data {

        let keyBytes = (keyData as NSData).bytes.bindMemory(to: UInt8.self, capacity: keyData.count)
        let dataLength = Int(data.count)
        let dataBytes  = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        let outData: NSMutableData! = NSMutableData(length: Int(dataLength) + kCCBlockSizeAES128)
        let cryptPointer = UnsafeMutableRawPointer(outData.mutableBytes)
        let cryptLength  = size_t(outData.length)
        let keyLength              = size_t(kCCKeySizeAES128)
        let algoritm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let ivBuffer = (initializationVector! as NSData).bytes.bindMemory(to: Void.self, capacity: initializationVector!.count)
        var numBytesProcessed: size_t = 0
        let cryptStatus = CCCrypt(operation,
            algoritm,
            options,
            keyBytes,
            keyLength,
            ivBuffer,
            dataBytes,
            dataLength,
            cryptPointer,
            cryptLength,
            &numBytesProcessed)
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            outData.length = Int(numBytesProcessed)
            return outData as Data
        } else {
            throw CryptoError.errorWithStatusCode(cryptStatus: Int(cryptStatus))
        }
    }


    open static func hash(_ string: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        if let data = string.data(using: Default.STRING_ENCODING) {
            CC_MD5((data as NSData).bytes, CC_LONG(data.count), &digest)
        }
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        return digestHex
    }
}
