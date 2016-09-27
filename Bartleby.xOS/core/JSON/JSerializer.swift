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

    open static var autoDecrypt=false


    /// The standard singleton shared instance
    open static let sharedInstance: JSerializer = {
        let instance = JSerializer()
        return instance
    }()


    public init() {
    }

    /**
     Deserializes from NSData

     - parameter data: the binary data

     - returns: the deserialized instance
     */
    static open func deserialize(_ data: Data) throws -> Serializable {
        return try JSerializer._deserializeFromData(data, autoDecrypt: JSerializer.autoDecrypt)
    }


    /**
     The concrete deserialization logic with auto decrypt logic.

     - parameter data:        the data
     - parameter autoDecrypt: should we try to autodecrypt ?

     - throws: SerializableError and CryptoError

     - returns: the serializable instance
     */
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


    /**
     Deserializes from NSData

     - parameter dictionary: the dictionnary

     - returns: an instance
     */
    static open func deserializeFromDictionary(_ dictionary: [String:Any]) throws -> Serializable {
        if var typeName = dictionary[Default.TYPE_NAME_KEY] as? String {
            typeName = Registry.resolveTypeName(from: typeName)
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



    /**
     Creates a separate instance in memory that is not registred.
     (!) advanced feature. The copied instance is reputed volatile and will not be managed by Bartleby's registries.

     - parameter instance: the original

     - returns: a volatile deep copy.
     */
    static open func volatileDeepCopy<T: Collectible>(_ instance: T) throws -> T? {
        let data: Data=JSerializer.serialize(instance)
        return try JSerializer.deserialize(data) as? T
    }


    static open func serialize(_ instance: Serializable) -> Data {
        return instance.serialize() as Data
    }


    open static var fileExtension: String {
        get {
            return "json"
        }
    }

}
