//
//  String+HMAC.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 02/11/2016.
//
//

import Foundation

public extension String {

    var md5: String {
        return BartlebysHMAC.digestString(self, algo: HMACAlgorithms.MD5)
    }

    var sha1: String {
        return BartlebysHMAC.digestString(self, algo: HMACAlgorithms.SHA1)
    }

    var sha224: String {
        return BartlebysHMAC.digestString(self, algo: HMACAlgorithms.SHA224)
    }

    var sha256: String {
        return BartlebysHMAC.digestString(self, algo: HMACAlgorithms.SHA256)
    }

    var sha384: String {
        return BartlebysHMAC.digestString(self, algo: HMACAlgorithms.SHA384)
    }

    var sha512: String {
        return BartlebysHMAC.digestString(self, algo: HMACAlgorithms.SHA512)
    }

}
