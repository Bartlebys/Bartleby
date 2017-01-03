//
//  CryptoHelper.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 12/11/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

/*
    This is a simple wrapper built on the top of CommonCrypto.
    You must `#import <CommonCrypto/CommonCrypto.h>` in a Bridging headera to use it.

    Note on Strings: 
    
    **IMPORTANT!**
    Don't use EncryptData, DecryptData on Utf8 strings.

    Always Use symetric calls :

    - 'encryptString' / 'decryptString' if you need for example to copy and paste the sample
    - 'encryptStringToData' / 'decryptStringFromData' for example for faster serialization


 */
open class CryptoHelper: NSObject, CryptoDelegate {

    /// The salt is used in conjunction with the key (for initialization vector...)
    let salt: String

    // The key
    let key: String

    // Options
    var options: CCOptions=UInt32(kCCOptionPKCS7Padding)

    var _keySize=kCCKeySizeAES128


    /// The designated initializer
    ///
    /// - Parameters:
    ///   - key: the key to use
    ///   - salt: the salf
    public init(key: String, salt: String="ea1f-56cb-41cf-59bf-6b09-87e8-2aca-5dfz",keySize:KeySize = .s128bits) {
        self.key=key
        self.salt=salt
        switch keySize {
        case .s128bits:
            self._keySize=kCCKeySizeAES128
        case .s192bits:
            self._keySize=kCCKeySizeAES192
        case .s256bits:
            self._keySize=kCCKeySizeAES256
        }
    }

    // We use a hash of the _salt+key as initialization vector
    lazy var initializationVector: Data?=CryptoHelper.hashString(self.salt + self.key).data(using: Default.STRING_ENCODING, allowLossyConversion:false)


    /// The CryptoErrors
    ///
    /// - keyIsInvalid: the key is invalid
    /// - errorWithStatusCode: an error relaying CCCryptorStatus error
    /// - codingError: a  coding error
    /// - decryptBase64Failure: a base 64 decoding error
    enum CryptoError: Error {
        case keyIsInvalid
        case errorWithStatusCode(cryptStatus:Int)
        case codingError(message:String)
        case decryptBase64Failure
    }



    /// A debug facility
    open func dumpDebug() {
        print("hash of key is \(CryptoHelper.hashString(key))")
        print("hash of salt is \(CryptoHelper.hashString(salt))")
    }


    // MARK: - Encryption + Base64 encoding / decoding

    /**
     Encrypt a string to a base 64 string containing the corresponding crypted buffer

     - parameter string: A string

     - throws: Crypt operation error

     - returns: A base 64 string representing a crypted buffer (eg. suitable for copy and paste)
     */
    open func encryptString(_ string: String,useKey:String=Default.NO_KEY) throws ->String {
        if let data=string.data(using: String.Encoding.utf8, allowLossyConversion:false) {
            let crypted=try encryptData(data)
            // (!) IMPORTANT
            // the crypted data may produces invalid UTF8 data producing nil Strings
            // We need to base64 encode any NSData.
            let b64Data=crypted.base64EncodedData(options: .endLineWithCarriageReturn)
            if let cryptedString=String(data: b64Data, encoding:String.Encoding.utf8) {
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
    open func decryptString(_ string: String,useKey:String=Default.NO_KEY) throws ->String {
        if let data=string.data(using: String.Encoding.utf8, allowLossyConversion:false) {
            if let b64Data=Data(base64Encoded: data, options: [.ignoreUnknownCharacters]) {
                let decrypted=try decryptData(b64Data)
                if let decryptedString=String(data: decrypted, encoding:String.Encoding.utf8) {
                    return decryptedString
                }else{
                     throw CryptoError.codingError(message: "utf8 decoding error (decrypted string)")
                }
            }
            throw CryptoError.decryptBase64Failure
        }
        throw CryptoError.codingError(message: "utf8 decoding error")
    }


    // MARK: - Raw Data encryption

    /**
     Encrypt a data buffer

     - parameter data: The buffer to encrypt

     - throws: A crypto operation error

     - returns: An encrypted buffer
     */
    open func encryptData(_ data: Data,useKey:String=Default.NO_KEY) throws ->Data {
        return try self._proceedTo(CCOperation(kCCEncrypt), on: data)
    }

    /**
     Decrypt a data buffer

     - parameter data: A crypted buffer

     - throws: A crypto operation error

     - returns: A decrypted buffer
     */
    open func decryptData(_ data: Data,useKey:String=Default.NO_KEY) throws ->Data {
        return try self._proceedTo(CCOperation(kCCDecrypt), on:data)
    }


    // MARK: - String encryption without reencoding

    // (the crypted data is not a valid String but this approach is faster)

    public func encryptStringToData(_ string:String,useKey:String=Default.NO_KEY)throws->Data{
        if let data=string.data(using: .utf8){
            return try encryptData(data,useKey: useKey)
        }else{
            throw CryptoError.codingError(message: "UTF8 encoding issue")
        }
    }

    
    public func decryptStringFromData(_ data:Data,useKey:String=Default.NO_KEY)throws->String{
        let decrypted = try decryptData(data,useKey:useKey)
        if let string = String(data: decrypted, encoding:.utf8){
            return string
        }else{
            throw CryptoError.codingError(message: "UTF8 decoding issue")
        }
    }

    // MARK: - Hash

    open static func hashString(_ string: String) -> String {
        return string.md5
    }



    // MARK: - Crypt operation


    fileprivate func _proceedTo(_ operation: CCOperation, on data: Data,useKey:String=Default.NO_KEY) throws ->Data {
        if let d=self.key.data(using: Default.STRING_ENCODING, allowLossyConversion:false) {
            let data = try self._cryptOperation(data, keyData: d, operation: operation)
            return data
        } else {
            throw CryptoError.keyIsInvalid
        }
    }

    /// The implementation of the CRYPTO Op
    ///
    /// - Parameters:
    ///   - data: the data
    ///   - keyData: the key transformed to Data
    ///   - operation: the operation
    /// - Returns: the encrypted or decrypted data.
    /// - Throws: CryptoError
    fileprivate func _cryptOperation(_ data: Data, keyData: Data, operation: CCOperation) throws -> Data {
        let keyBytes = (keyData as NSData).bytes.bindMemory(to: UInt8.self, capacity: keyData.count)
        let dataLength = Int(data.count)
        let dataBytes  = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        let outData: NSMutableData! = NSMutableData(length: Int(dataLength) + kCCBlockSizeAES128)
        let cryptPointer = UnsafeMutableRawPointer(outData.mutableBytes)
        let cryptLength  = size_t(outData.length)
        let keyLength              = size_t(_keySize)
        let algoritm: CCAlgorithm = UInt32(kCCAlgorithmAES)
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


}

