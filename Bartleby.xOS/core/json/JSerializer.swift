//
//  JSerializer.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 24/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation
#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

open class JSerializer: Serializer {

    /// The standard singleton shared instance
    open static let sharedInstance: JSerializer = {
        let instance = JSerializer()
        return instance
    }()

    public init() {}

    open static var autoDecrypt=false

    // MARK: - Deserialization

    /// Deserializes a fully typed object
    ///
    /// - Parameter data:  data
    /// - Returns: the serizalizable Object
    /// - Throws: ...
    static open func deserialize(_ data: Data) throws -> Serializable {
        return try JSerializer._deserializeFromData(data, autoDecrypt: JSerializer.autoDecrypt)
    }


    ///  The concrete deserialization logic with auto decrypt logic.
    ///
    /// - Parameters:
    ///   - data: the data
    ///   - autoDecrypt: should we try to autodecrypt ?
    /// - Returns: the Serializable instance
    /// - Throws: SerializableError and CryptoError
    static fileprivate func _deserializeFromData(_ data: Data,autoDecrypt:Bool) throws -> Serializable{
        do {
            if let JSONDictionary = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as? [String:AnyObject] {
                return try JSerializer.deserializeFromDictionary(JSONDictionary)
            }
            throw SerializableError.enableToTransformDataToDictionary
        }catch{
            if (autoDecrypt){
                let decrypted=try Bartleby.cryptoDelegate.decryptData(data)
                return try JSerializer._deserializeFromData(decrypted, autoDecrypt: false)
            }else{
                throw SerializableError.enableToTransformDataToDictionary
            }
        }
    }

    /// Deserializes from an UTF8 string
    ///
    /// - Parameter dictionary: the dictionary
    /// - Returns: the serializable instance
    /// - Throws: SerializableError and CryptoError
    open static func deserializeFromUTF8String(_ string: String) throws -> Serializable {
        if let data=string.data(using: .utf8){
            return try self._deserializeFromData(data, autoDecrypt: JSerializer.autoDecrypt)
        }
        throw SerializableError.invalidUTF8String
    }


    /// Deserializes from a dictionary
    ///
    /// - Parameter dictionary: the dictionary
    /// - Returns: the serializable instance
    /// - Throws:  SerializableError and CryptoError JSON errors
    static open func deserializeFromDictionary(_ dictionary: [String:Any]) throws -> Serializable {
        if let typeName = dictionary[Default.TYPE_NAME_KEY] as? String {
            if let Reference = NSClassFromString(typeName) as? Serializable.Type {
                if  var mappable = Reference.init() as? Mappable {
                    let map=Map(mappingType: .fromJSON, JSON : dictionary)
                    mappable.mapping(map: map)
                    if let serializable = mappable as? Serializable {
                        return serializable
                    } else {
                        throw SerializableError.typeMissmatch
                    }
                } else {
                    throw SerializableError.typeMissmatch
                }
            } else {
                throw SerializableError.typeMissmatch
            }
        } else {
            throw SerializableError.typeNameUndefined
        }
    }

    // MARK: - Serialization

    ///  Serializes an instance
    ///
    /// - Parameter instance: the Serializable instance
    /// - Returns: the data
    static open func serialize(_ instance: Serializable) -> Data {
        return instance.serialize() as Data
    }


    /// Serializes the current instance to an UTF8 String
    ///
    /// - Parameter instance: the serializable instance
    /// - Returns: the UTF8 string
    public static func serializeToUTF8String(_ instance: Serializable) -> String{
        return instance.serializeToUFf8String()
    }


    /// The file extension for file based serializers.
    open static var fileExtension: String { return "json" }

}
