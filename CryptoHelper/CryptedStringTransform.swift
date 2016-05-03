//
//  CryptedStringTransform.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 05/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

public class CryptedStringTransform: TransformType {
    public init() {

    }

    public typealias Object = String
    public typealias JSON = String

    public func transformFromJSON(value: AnyObject?) -> Object? {
        if let s=value as? String {
            do {
                return try Bartleby.cryptoDelegate.decryptString(s)
            } catch {
                bprint("\(error)", file: #file, function: #function, line: #line)
            }
        }
        return nil
    }

    public func transformToJSON(value: Object?) -> JSON? {
        if let s=value {
            do {
                return try Bartleby.cryptoDelegate.encryptString(s)
            } catch {
                bprint("\(error)", file: #file, function: #function, line: #line)
            }
        }
        return nil

    }
}
