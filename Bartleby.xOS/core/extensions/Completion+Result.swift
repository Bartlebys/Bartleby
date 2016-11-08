//
//  Completion+Result.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/05/2016.
//
//

import Foundation

// MARK: - Result Extensions

// We expose pairs of Setter and Getter to cast the Result.
// The result is serialized in the opaque NSdata data property.
public extension Completion {

    // MARK: Generic Serializable result

    /**
     Stores the serializabale result

     - parameter result: the serializable result
     */
    func setResult<T: Serializable>(_ result: T) {
        self.data=result.serialize()
    }

    /**
     Gets the deserialized result
     - returns: the deserialized result
     */
    func getResult<T: Serializable>() -> T? {
        if let data=self.data {
            let s = try? JSerializer.deserialize(data)
            return s as? T
        }
        return nil
    }


    /**
     Gets the deserialized result

     - parameter serializer: what serializer should we use?

     - returns: the deserialized result
     */
    func getResultFromSerializer<T: Serializable>(_ serializer: Serializer) -> T? {
        if let data=self.data {
            let s=try? JSerializer.deserialize(data)
            return s as? T
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


    // MARK: - External Reference result

    /// Store an external reference in the result
    ///
    /// - Parameter ref: the reference
    func setExternalReferenceResult<T: Collectible>(from ref:T) {
        let externalRef=ExternalReference(from:ref)
        self.data = externalRef.serialize()
    }


    /// Retrieve the stored reference
    ///
    /// - Returns: the external reference
    func getExternalReferenceResult() ->ExternalReference? {
        if let ref:ExternalReference=self.getResult(){
            return ref
        }else{
            return nil
        }

    }
}
