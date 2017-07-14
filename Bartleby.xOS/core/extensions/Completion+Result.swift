//
//  Completion+Result.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/05/2016.
//
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

// MARK: - Result Extensions

// We expose pairs of Setter and Getter to cast the Result.
// The result is serialized in the opaque NSdata data property.
public extension Completion {

    // MARK:-  Generic Serializable result

    
    ///  Stores the serializabale result
    ///
    /// - Parameter result: the serializable result
    func setResult<T: Mappable>(_ result: T) {
        if let json=result.toJSONString(){
            if let encoded=json.data(using: String.Encoding.utf8){
                self.data=encoded
            }
        }
    }



    ///  Gets the deserialized result
    ///  If the result is an external reference the reference is resolved automatically
    /// - Returns: the deserialized result
    func getResult<T: Mappable>() -> T? {
        if let data=self.data {
            if let json = String.init(data: data, encoding: String.Encoding.utf8){
                if let ref:T = Mapper<T>().map(JSONString:json){
                    return ref
                }
            }
        }
        return nil
    }


    // MARK: - External Reference result

    /// Store an external reference in the result
    ///
    /// - Parameter ref: the reference
    func setExternalReferenceResult<T: Collectible>(from ref:T) {
        let externalRef=StringValue()
        externalRef.value=ref.UID
        if let json=externalRef.toJSONString(){
            self.data = json.data(using: String.Encoding.utf8)
        }
    }


    /// Retrieve the stored reference
    ///
    /// - Returns: the external reference UID
    func getResultExternalReference() ->String? {
        if let data = self.data{
            if let json=String(data: data, encoding: String.Encoding.utf8){
                if let ref:StringValue = Mapper<StringValue>().map(JSONString:json){
                    return ref.value
                }
            }
        }
        return nil
    }


    // MARK: - String result


    func setStringResult(_ s: String) {
        self.data = s.data(using: Default.STRING_ENCODING)?.base64EncodedData(options: .endLineWithCarriageReturn)
    }

    func getStringResult() -> String? {
        if let b64data = self.data {
            if let plainData = Data(base64Encoded: b64data, options: .ignoreUnknownCharacters) {
                return String(data: plainData, encoding: Default.STRING_ENCODING)
            }
        }
        return nil
    }

    // MARK: - Array of String result
    
    func setStringArrayResult(_ stringArray: [String]) {
        do {
            self.data = try JSONSerialization.data(withJSONObject: stringArray, options: .prettyPrinted)
        } catch {
            self.data = nil
        }
    }
    
    func getStringArrayResult() -> [String]? {
        if let data = self.data {
            do {
                if let stringArray = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String] {
                    return stringArray
                }
            } catch {
                
            }
        }
        return  nil
    }
    
    // MARK: - Dictionary result
    
    func setDictionaryResult(_ dict: [String: String]) {
        do {
            self.data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        } catch {
            self.data = nil
        }
    }
    
    func getDictionaryResult() -> [String: String]? {
        if let data = self.data {
            do {
                if let dict = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String: String] {
                    return dict
                }
            } catch {
                
            }
        }
        return  nil
    }
}
