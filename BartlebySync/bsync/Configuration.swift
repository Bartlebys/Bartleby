//
//  Configuration.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 05/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

#if USE_EMBEDDED_MODULES

import Foundation

class Configuration {

    static var KEY: String {
        get {
            return "bsync-is-a-nice-tool-please-keep-its-key-private-2016-01-05-bpds"
        }
    }

    static var SALT: String {
        get {
            return CryptoHelper.hashString(Configuration.KEY+"in-the-soup")
        }
    }

}

#endif
