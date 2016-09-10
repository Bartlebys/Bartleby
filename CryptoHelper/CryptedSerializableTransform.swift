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

open class CryptedSerializableTransform<T: Serializable>: TransformType {
    public init() {

    }

    public typealias Object = T
    public typealias JSON = String

    fileprivate let _CRYPTED_OBJECT_KEY = "o"

    open func transformFromJSON(_ value: AnyObject?) -> Object? {

        if let JSONSTRING=value as? String {
            do {
                if let dataString = JSONSTRING.data(using: Default.STRING_ENCODING) {
                    if let jsonDictionary = try JSONSerialization.jsonObject(with: dataString, options:JSONSerialization.ReadingOptions.allowFragments) as? [String:AnyObject] {
                        if let value = jsonDictionary[self._CRYPTED_OBJECT_KEY] {
                            if let base64EncodedString = value as? String {
                                if let encryptedData = Data(base64Encoded: base64EncodedString, options: .ignoreUnknownCharacters) {
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

    open func transformToJSON(_ value: Object?) -> JSON? {
        if let object=value {
            do {
                let data=JSerializer.serialize(object)
                let cryptedData = try Bartleby.cryptoDelegate.encryptData(data)
                let base64EncodedString = cryptedData.base64EncodedString(options: .endLineWithCarriageReturn)
                let JSONSTRING="{\"\(self._CRYPTED_OBJECT_KEY)\":\"\(base64EncodedString)\"}"
                return JSONSTRING
            } catch {
                bprint("\(error)", file: #file, function: #function, line: #line)
            }
        }
        return nil
    }
}
