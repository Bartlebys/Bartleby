//
//  JSONSerializer.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 24/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation

open class JSONSerializer: Serializer {


    // The containing document reference
    public var document:BartlebyDocument

    /// The file extension for file based serializers.
    open var fileExtension: String { return "json" }

    // The initializer
    public required init(document:BartlebyDocument){
        self.document=document
    }


    // MARK: - Deserialization

    /// Deserializes a fully typed object
    ///
    /// - Parameters:
    ///   - data: the opaque data
    ///   - register: should we register to document and collection?
    /// - Returns: the deserialized object
    /// - Throws: Deserialization exceptions
    open func deserialize(_ data: Data,register:Bool) throws -> Serializable {
        return try self._deserializeFromData(data,register:register)
    }


    ///  The concrete deserialization logic with auto decrypt logic.
    /// - Parameters:
    ///   - data: the data
    ///   - register: should we register to document and collection?
    /// - Returns: the Serializable instance
    /// - Throws: SerializableError and CryptoError
    fileprivate func _deserializeFromData(_ data: Data,register:Bool) throws -> Serializable{
        if let JSONDictionary = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as? [String:AnyObject] {
            return try self.deserializeFromDictionary(JSONDictionary, register: register)
        }
        throw SerializableError.unableToTransformDataToDictionary
    }

    /// Deserializes from an UTF8 string
    /// - Parameters:
    ///   - string: the string
    ///   - register: should we register to document and collection?
    /// - Returns: the deserialized object
    /// - Throws: Variable exception (serializer based)
    open  func deserializeFromUTF8String(_ string: String,register:Bool) throws -> Serializable {
        if let data=string.data(using: .utf8){
            return try self._deserializeFromData(data,register:register)
        }
        throw SerializableError.invalidUTF8String
    }


    /// Deserializes from a dictionary
    /// - Parameters:
    ///   - dictionary: the dictionary
    ///   - register: should we register to document and collection?
    /// - Returns: the deserialized object
    /// - Throws: Variable exception (serializer based)
    open func deserializeFromDictionary(_ dictionary: [String:Any],register:Bool) throws -> Serializable {
        if let typeName = dictionary[Default.TYPE_NAME_KEY] as? String {
            if let Reference = NSClassFromString(typeName) as? NSObject.Type {
                if  let instance = Reference.init() as? ManagedModel {
                    // Remove the UID_KEY if set to nil or NO_UID
                    if dictionary[Default.UID_KEY] == nil || dictionary[Default.UID_KEY] as? String == Default.NO_UID{
                        // We provide a mutable copy only if necessary (for performance purposes)
                        var mutableDictionary=dictionary
                        mutableDictionary.removeValue(forKey: Default.UID_KEY)
                        //#TODO
                        // Create the Map
                        //let map=Map(mappingType: .fromJSON, JSON : mutableDictionary)
                        // Proceed to Mapping
                        //instance.mapping(map: map)
                    }else{
                        //#TODO
                        // Create the Map
                        //let map=Map(mappingType: .fromJSON, JSON : dictionary)
                        // Proceed to Mapping
                        //instance.mapping(map: map)
                    }
                    // Set up the runtime references.
                        if register{
                            if (instance is BartlebyCollection) || (instance is BartlebyOperation){
                                // Add the document reference
                                instance.referentDocument=self.document
                            }else{
                                // Add the collection reference
                                // Calls the Bartleby.register(self)
                                instance.collection=self.document.collectionByName(instance.d_collectionName)
                            }
                        }
                        return instance

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
