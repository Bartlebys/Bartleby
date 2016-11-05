//
//  String+HMAC.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 02/11/2016.
//
//

import Foundation

extension String {

    var md5: String {
        return HMAC.digestString(self, algo: HMACAlgorythms.MD5)
    }

    var sha1: String {
        return HMAC.digestString(self, algo: HMACAlgorythms.SHA1)
    }

    var sha224: String {
        return HMAC.digestString(self, algo: HMACAlgorythms.SHA224)
    }

    var sha256: String {
        return HMAC.digestString(self, algo: HMACAlgorythms.SHA256)
    }

    var sha384: String {
        return HMAC.digestString(self, algo: HMACAlgorythms.SHA384)
    }

    var sha512: String {
        return HMAC.digestString(self, algo: HMACAlgorythms.SHA512)
    }

}
