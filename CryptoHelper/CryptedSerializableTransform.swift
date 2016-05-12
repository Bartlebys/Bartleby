//
//  CryptedJObjectTransform.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 21/04/2016.
//
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

public class CryptedSerializableTransform<T: Serializable>: TransformType {
    public init() {

    }

    public typealias Object = T
    public typealias JSON = String

    private let _CRYPTED_OBJECT_KEY = "o"

    public func transformFromJSON(value: AnyObject?) -> Object? {

        if let JSONSTRING=value as? String {
            do {
                if let dataString = JSONSTRING.dataUsingEncoding(Default.TEXT_ENCODING) {
                    if let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(dataString, options:NSJSONReadingOptions.AllowFragments) as? [String:AnyObject] {
                        if let value = jsonDictionary[self._CRYPTED_OBJECT_KEY] {
                            if let base64EncodedString = value as? String {
                                if let encryptedData = NSData(base64EncodedString: base64EncodedString, options: .IgnoreUnknownCharacters) {
                                    let deCryptedData = try Bartleby.cryptoDelegate.decryptData(encryptedData)
                                    let o = try? JSerializer.deserialize(deCryptedData)
                                    return  o as? Object
                                }
                            }
                        }
                    }
                }
            } catch {
                bprint("\(error)", file: #file, function: #function, line: #line)
            }
        }
        return nil
    }

    public func transformToJSON(value: Object?) -> JSON? {
        if let object=value {
            do {
                let data=JSerializer.serialize(object)
                let cryptedData = try Bartleby.cryptoDelegate.encryptData(data)
                let base64EncodedString = cryptedData.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
                let JSONSTRING="{\"\(self._CRYPTED_OBJECT_KEY)\":\"\(base64EncodedString)\"}"
                return JSONSTRING
            } catch {
                bprint("\(error)", file: #file, function: #function, line: #line)
            }
        }
        return nil
    }
}
