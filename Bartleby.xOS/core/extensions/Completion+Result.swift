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

    // MARK:-  Generic Serializable result

    
    ///  Stores the serializabale result
    ///
    /// - Parameter result: the serializable result
    func setResult<T: Codable>(_ result: T) {
        self.data = try? JSONEncoder().encode(result)
    }



    ///  Gets the deserialized result
    ///  If the result is an external reference the reference is resolved automatically
    /// - Returns: the deserialized result
    func getResult<T: Codable>() -> T? {
        if let data=self.data {
            return try? JSONDecoder().decode(T.self, from: data)
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
        self.data = try? JSONEncoder().encode(externalRef)
    }


    /// Retrieve the stored reference
    ///
    /// - Returns: the external reference UID
    func getResultExternalReference() ->String? {
        if let data = self.data{
            let stringValue =  try? JSONDecoder().decode(StringValue.self, from: data)
            return stringValue?.value
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
