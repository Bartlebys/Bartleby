//
//  Data+HMAC.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 02/11/2016.
//
//

import Foundation

public extension Data {
    var md5: String {
        return HMAC.digestData(self, algo: HMACAlgorithms.MD5)
    }

    var sha1: String {
        return HMAC.digestData(self, algo: HMACAlgorithms.SHA1)
    }

    var sha224: String {
        return HMAC.digestData(self, algo: HMACAlgorithms.SHA224)
    }

    var sha256: String {
        return HMAC.digestData(self, algo: HMACAlgorithms.SHA256)
    }

    var sha384: String {
        return HMAC.digestData(self, algo: HMACAlgorithms.SHA384)
    }

    var sha512: String {
        return HMAC.digestData(self, algo: HMACAlgorithms.SHA512)
    }
}
