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

open class CryptedStringKeyValueTransform: TransformType {

    public typealias Object = Dictionary<String, String>
    public typealias JSON = String


    open func transformFromJSON(_ value: Any?) -> Dictionary<String, String>? {

        if let s = value as? String {
            if let jsonData=s.data(using: Default.STRING_ENCODING) {
                do {
                    if let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? Dictionary<String, String> {
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

    open func transformToJSON(_ value: Object?) -> JSON? {
        if let dictionary = value {
            var cryptedDictionary = Dictionary<String, String>()
            do {
                for (key, value) in dictionary {
                    cryptedDictionary[try Bartleby.cryptoDelegate.encryptString(key)]=try Bartleby.cryptoDelegate.encryptString(value)
                }
                let jsonData = try JSONSerialization.data(withJSONObject: cryptedDictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
                return String(data: jsonData, encoding: Default.STRING_ENCODING)
            } catch {
                bprint("\(error)", file: #file, function: #function, line: #line)
            }
        }
        return nil
    }

}
