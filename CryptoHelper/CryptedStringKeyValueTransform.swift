//
//  CryptedStringKeyValueTransform.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 08/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

public class CryptedStringKeyValueTransform: TransformType {

    public typealias Object = Dictionary<String, String>
    public typealias JSON = String


    public func transformFromJSON(value: AnyObject?) -> Object? {

        if let s = value as? String {
            if let jsonData=s.dataUsingEncoding(NSUTF8StringEncoding) {
                do {
                    if let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? Dictionary<String, String> {
                        var dictionary = Dictionary<String, String>()
                        for (key, value) in jsonDictionary {
                            dictionary[try Bartleby.cryptoDelegate.decryptString(key)]=try Bartleby.cryptoDelegate.decryptString(value)
                        }
                        return dictionary
                    }
                } catch {
                    bprint("\(error)", file: #file, function: #function, line: #line)
                }

            }
        }
        return nil
    }

    public func transformToJSON(value: Object?) -> JSON? {
        if let dictionary = value {
            var cryptedDictionary = Dictionary<String, String>()
            do {
                for (key, value) in dictionary {
                    cryptedDictionary[try Bartleby.cryptoDelegate.encryptString(key)]=try Bartleby.cryptoDelegate.encryptString(value)
                }
                let jsonData = try NSJSONSerialization.dataWithJSONObject(cryptedDictionary, options: NSJSONWritingOptions.PrettyPrinted)
                return String(data: jsonData, encoding: NSUTF8StringEncoding)
            } catch {
                bprint("\(error)", file: #file, function: #function, line: #line)
            }
        }
        return nil
    }

}
