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


    // The containing document reference
    public var document:BartlebyDocument

    /// The file extension for file based serializers.
    open var fileExtension: String { return "json" }

    // The initializer
    public required init(document:BartlebyDocument){
        self.document=document
    }

    open var autoDecrypt=false

    // MARK: - Deserialization

    /// Deserializes a fully typed object
    /// And registers the instance into its collection and Document
    ///
    /// - Parameter data:  data
    /// - Returns: the serizalizable Object
    /// - Throws: ...
    open func deserialize(_ data: Data) throws -> Serializable {
        return try self._deserializeFromData(data, autoDecrypt: self.autoDecrypt)
    }


    ///  The concrete deserialization logic with auto decrypt logic.
    /// - Parameters:
    ///   - data: the data
    ///   - autoDecrypt: should we try to autodecrypt ?
    /// - Returns: the Serializable instance
    /// - Throws: SerializableError and CryptoError
    fileprivate func _deserializeFromData(_ data: Data,autoDecrypt:Bool) throws -> Serializable{
        do {
            if let JSONDictionary = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as? [String:AnyObject] {
                return try self.deserializeFromDictionary(JSONDictionary)
            }
            throw SerializableError.unableToTransformDataToDictionary
        }catch{
            if (autoDecrypt){
                let decrypted=try Bartleby.cryptoDelegate.decryptData(data,useKey:Bartleby.configuration.KEY)
                return try self._deserializeFromData(decrypted, autoDecrypt: false)
            }else{
                throw SerializableError.unableToTransformDataToDictionary
            }
        }
    }

    /// Deserializes from an UTF8 string
    /// And registers the instance into its collection and Document
    /// - Parameter dictionary: the dictionary
    /// - Returns: the serializable instance
    /// - Throws: SerializableError and CryptoError
    open  func deserializeFromUTF8String(_ string: String) throws -> Serializable {
        if let data=string.data(using: .utf8){
            return try self._deserializeFromData(data, autoDecrypt: self.autoDecrypt)
        }
        throw SerializableError.invalidUTF8String
    }


    /// Deserializes from a dictionary (the implementation of the Mapping)
    /// And registers the instance into its collection and Document
    ///
    /// - Parameter dictionary: the dictionary
    /// - Returns: the serializable instance
    /// - Throws:  SerializableError and CryptoError JSON errors
    open func deserializeFromDictionary(_ dictionary: [String:Any]) throws -> Serializable {
        if let typeName = dictionary[Default.TYPE_NAME_KEY] as? String {
            if let Reference = NSClassFromString(typeName) as? Serializable.Type {
                if  var mappable = Reference.init() as? Mappable {
                    // Remove the UID_KEY if set to nil or NO_UID
                    if dictionary[Default.UID_KEY] == nil || dictionary[Default.UID_KEY] as? String == Default.NO_UID{
                        // We provide a mutable copy only if necessary (for performance purposes)
                        var mutableDictionary=dictionary
                        mutableDictionary.removeValue(forKey: Default.UID_KEY)
                        // Create the Map
                        let map=Map(mappingType: .fromJSON, JSON : mutableDictionary)
                        // Proceed to Mapping
                        mappable.mapping(map: map)
                    }else{
                        // Create the Map
                        let map=Map(mappingType: .fromJSON, JSON : dictionary)
                        // Proceed to Mapping
                        mappable.mapping(map: map)
                    }
                    // Set up the runtime references.
                    if var collectible = mappable as? Collectible {
                        if (collectible is BartlebyCollection) || (collectible is BartlebyOperation){
                             // Add the document reference
                            collectible.referentDocument=self.document
                        }else{
                            // Add the collection reference
                            collectible.collection=self.document.collectionByName(collectible.d_collectionName)
                        }
                        return collectible
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
    open func serialize(_ instance: Serializable) -> Data {
        return instance.serialize() as Data
    }


    /// Serializes the current instance to an UTF8 String
    ///
    /// - Parameter instance: the serializable instance
    /// - Returns: the UTF8 string
    open func serializeToUTF8String(_ instance: Serializable) -> String{
        return instance.serializeToUFf8String()
    }

}
