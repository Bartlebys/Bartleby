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

@objc public class CryptedJObjectTransform:NSObject,TransformType{
    
    public typealias Object = JObject
    public typealias JSON = String
    
    private let _CRYPTED_OBJECT_KEY = "cryptedJObject"
    
    public func transformFromJSON(value: AnyObject?) -> Object?{
      
        if let JSONSTRING=value as? String{
            do {
                if let dataString = JSONSTRING.dataUsingEncoding(NSUTF8StringEncoding){
                    if let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(dataString,options:NSJSONReadingOptions.AllowFragments) as? [String:AnyObject] {
                        if let base64EncodedData = jsonDictionary[self._CRYPTED_OBJECT_KEY] as? NSData{
                            let deCryptedData = try Bartleby.cryptoDelegate.decryptData(base64EncodedData)
                            return JSerializer.deserialize(deCryptedData) as? Object
                        }
                    }
                }
            } catch  {
                bprint("\(error)", file: #file, function: #function, line: #line)
            }
        }
        return nil
    }
    
    public func transformToJSON(value: Object?) -> JSON?{
        if let object=value {
            do {
                let data=JSerializer.serialize(object)
                let cryptedData = try Bartleby.cryptoDelegate.encryptData(data)
                let base64EncodedData = cryptedData.base64EncodedDataWithOptions(.EncodingEndLineWithCarriageReturn)
                let JSONSTRING="{\"\(self._CRYPTED_OBJECT_KEY)\"=\"\(base64EncodedData)\"}"
                return JSONSTRING
            } catch  {
                bprint("\(error)", file: #file, function: #function, line: #line)
            }
        }
        return nil
        
    }
}

