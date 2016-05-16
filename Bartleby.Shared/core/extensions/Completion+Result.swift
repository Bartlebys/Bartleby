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
    func setResult<T: Serializable>(result: T) {
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
    func getResultFromSerializer<T: Serializable>(serializer: Serializer) -> T? {
        if let data=self.data {
            let s=try? JSerializer.deserialize(data)
            return s as? T
        }
        return nil
    }

    // MARK: - String result


    func setStringResult(s: String) {
        self.data = s.dataUsingEncoding(Default.STRING_ENCODING)?.base64EncodedDataWithOptions(.EncodingEndLineWithCarriageReturn)
    }

    func getStringResult() -> String? {
        if let b64data = self.data {
            if let plainData = NSData(base64EncodedData: b64data, options: .IgnoreUnknownCharacters) {
                return String(data: plainData, encoding: Default.STRING_ENCODING)
            }
        }
        return nil
    }

    // MARK: - Array of String result

    func setStringArrayResult(stringArray: [String]) {
        do {
            self.data = try NSJSONSerialization.dataWithJSONObject(stringArray, options: .PrettyPrinted)
        } catch {
            self.data = nil
        }
    }

    func getStringArrayResult() -> [String]? {
        if let data = self.data {
            do {
                if let stringArray = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String] {
                    return stringArray
                }
            } catch {

            }
        }
        return  nil
    }

}
