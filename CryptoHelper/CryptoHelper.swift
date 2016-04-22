//
//  CryptoHelper.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 12/11/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

@objc public class CryptoHelper:NSObject,CryptoDelegate{
    // (!Should always be set to false (debug only)
    private static let DISABLE_CRYPTO = true

    let salt:String
    
    let key:String
    
    var options:CCOptions=UInt32(kCCOptionPKCS7Padding)
    
    public init(key:String,salt:String="ea1f-56cb-41cf-59bf-6b09-87e8-2aca-5dfz"){
        self.key=key
        self.salt=salt
    }
    
    // We use a hash of the _salt+key as initialization vector
    lazy var initializationVector: NSData?=CryptoHelper.hash(self.salt.stringByAppendingString(self.key)).dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion:false)
    
    
    // MARK: - Cryptography
    
    enum CryptoError: ErrorType {
        case KeyIsInvalid
        case ErrorWithStatusCode(cryptStatus:Int)
        case CodingError(message:String)
    }
    

    public func dumpDebug(){
        print("hash of key is \(CryptoHelper.hash(key))")
        print("hash of salt is \(CryptoHelper.hash(salt))")
    }
    
    /**
     Encrypt a string to a base 64 string containing the corresponding crypted buffer
     
     - parameter string: A string
     
     - throws: Crypt operation error
    
     - returns: A base 64 string representing a crypted buffer
     */
    public func encryptString(string:String) throws ->String{
        if let data=string.dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion:false){
            let crypted=try encryptData(data)
            return crypted.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
        } else {
            throw CryptoError.CodingError(message: "String to data conversion error")
        }
    }
    
    /**
     Decrypt a base 64 string containing a crypted buffer
     
     - parameter string: A base 64 string
     
     - throws: It can throw if the input string doesn't contains base 64 data, or if the decrypt
     buffer doesn't contains valid utf8 data, or if there is a crypto operation error
     
     - returns: A string
     */
    public func decryptString(string:String) throws ->String{
       if let data=NSData(base64EncodedString: string, options: [.IgnoreUnknownCharacters]) {
            let decrypted=try decryptData(data)
            if let decryptedString=String(data: decrypted,encoding:NSUTF8StringEncoding){
                return decryptedString
            } else {
                throw CryptoError.CodingError(message: "UTF8 string encoding error")
            }
            
            
        }
        throw CryptoError.CodingError(message: "Base 64 decoding has failed")
    }
    
    /**
     Encrypt a data buffer
     
     - parameter data: The buffer to encrypt
     
     - throws: A crypto operation error
     
     - returns: An encrypted buffer
     */
    public func encryptData(data:NSData) throws ->NSData{
        if CryptoHelper.DISABLE_CRYPTO {
            return data
        }
      let crypted=try self._encryptOperation(CCOperation(kCCEncrypt),on: data)
        return crypted
    }
    
    /**
     Decrypt a data buffer
     
     - parameter data: A crypted buffer
     
     - throws: A crypto operation error
     
     - returns: A decrypted buffer
     */
    public func decryptData(data:NSData) throws ->NSData{
        if CryptoHelper.DISABLE_CRYPTO {
            return data
        }
        return try self._encryptOperation(CCOperation(kCCDecrypt),on:data)
    }
    
    
    // MARK: Crypt operation
    
    private func _encryptOperation(operation:CCOperation ,on data:NSData) throws ->NSData{
        if let d=self.key.dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion:false){
            let data = try self._cryptOperation(data,keyData: d,operation: operation)
            return data
        }else{
            throw CryptoError.KeyIsInvalid
        }
    }
    
    private func _cryptOperation(data:NSData, keyData:NSData,operation:CCOperation) throws -> NSData {
        
        let keyBytes = UnsafePointer<UInt8>(keyData.bytes)
        let dataLength = Int(data.length)
        let dataBytes  = UnsafePointer<UInt8>(data.bytes)
        let outData: NSMutableData! = NSMutableData(length: Int(dataLength) + kCCBlockSizeAES128)
        let cryptPointer = UnsafeMutablePointer<UInt8>(outData.mutableBytes)
        let cryptLength  = size_t(outData.length)
        let keyLength              = size_t(kCCKeySizeAES128)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let ivBuffer = UnsafePointer<Void>(initializationVector!.bytes)
        var numBytesProcessed :size_t = 0
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
            return outData
        } else {
            throw CryptoError.ErrorWithStatusCode(cryptStatus: Int(cryptStatus))
        }
    }
    
    
    public static func hash(string: String) -> String {
        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        }
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        return digestHex
    }
}


