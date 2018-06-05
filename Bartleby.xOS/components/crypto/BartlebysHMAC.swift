//
//  HMAC.swift
//  BartlebyKit
//
// Ported To Swift3 & extended
// from https://gist.github.com/MihaelIsaev/f913d84b918d2b2c067d
//  Created by Benoit Pereira da silva on 02/11/2016.

import Foundation


public struct BartlebysHMAC {


    /// Return the digest
    ///
    /// - Parameters:
    ///   - string: the string to digest
    ///   - algo: the algorythm to use
    /// - Returns: the digest string
    static func digestString(_ string: String, algo: HMACAlgorithms) -> String {
        if let stringData = string.data(using: String.Encoding.utf8, allowLossyConversion: false){
            let digest = BartlebysHMAC._digest(stringData, algo: algo)
            return BartlebysHMAC._hexStringFromData(digest)
        }
        return ""
    }
    
    /// Return the digest
    ///
    /// - Parameters:
    ///   - string: the Data to digest
    ///   - algo: the algorythm to use
    /// - Returns: the digest string
    static func digestData(_ data: Data, algo: HMACAlgorithms) -> String {
        let digest = BartlebysHMAC._digest(data, algo: algo)
        return BartlebysHMAC._hexStringFromData(digest)
    }


    /// Returns the hash Data
    /// Note that hash data are not always UTF8 valid string we need to _hexStringFromData to return a valid String
    /// - Parameters:
    ///   - data: the data to digest
    ///   - algo: the algorythm to use
    /// - Returns: the digest data
    private static func _digest(_ data : Data, algo: HMACAlgorithms) -> Data {
        let digestLength = algo.digestLength()
        var hash = [UInt8](repeating: 0,count: digestLength)
        switch algo {
        case .MD5:
            data.withUnsafeBytes({ (bytes: UnsafePointer<UInt8>) ->Void in
                CC_MD5(bytes, UInt32(data.count), &hash)
            })
            break
        case .SHA1:
            data.withUnsafeBytes({ (bytes: UnsafePointer<UInt8>) ->Void in
                CC_SHA1(bytes, UInt32(data.count), &hash)
            })
            break
        case .SHA224:
            data.withUnsafeBytes({ (bytes: UnsafePointer<UInt8>) ->Void in
                CC_SHA224(bytes, UInt32(data.count), &hash)
            })
            break
        case .SHA256:
            data.withUnsafeBytes({ (bytes: UnsafePointer<UInt8>) ->Void in
                CC_SHA256(bytes, UInt32(data.count), &hash)
            })
            break
        case .SHA384:
            data.withUnsafeBytes({ (bytes: UnsafePointer<UInt8>) ->Void in
                CC_SHA384(bytes, UInt32(data.count), &hash)
            })
            break
        case .SHA512:
            data.withUnsafeBytes({ (bytes: UnsafePointer<UInt8>) ->Void in
                CC_SHA512(bytes, UInt32(data.count), &hash)
            })
            break
        }
        return Data(bytes: hash, count: digestLength)
    }



    /// Return a valid UTF8 string.
    ///
    /// - Parameter data: the Data
    /// - Returns: the String
    private static func _hexStringFromData(_ data: Data) -> String {
        var bytes = [UInt8](repeating: 0,count:data.count)
        data.copyBytes(to:&bytes, count: data.count)
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        return hexString
    }
    
}
