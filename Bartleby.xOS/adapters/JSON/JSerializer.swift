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

public class JSerializer: Serializer {

    public static var autoDecrypt=false


    /// The standard singleton shared instance
    public static let sharedInstance: JSerializer = {
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
    static public func deserialize(data: NSData) throws -> Serializable {
        return try JSerializer._deserializeFromData(data, autoDecrypt: JSerializer.autoDecrypt)
    }


    /**
     The concrete deserialization logic with auto decrypt logic.

     - parameter data:        the data
     - parameter autoDecrypt: should we try to autodecrypt ?

     - throws: SerializableError and CryptoError

     - returns: the serializable instance
     */
    static private func _deserializeFromData(data: NSData,autoDecrypt:Bool) throws -> Serializable{
        do {
            if let JSONDictionary = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments) as? [String:AnyObject] {
                return try JSerializer.deserializeFromDictionary(JSONDictionary)
            }
            throw SerializableError.EnableToTransformDataToDictionary
        }catch{
            if (autoDecrypt){
                let decrypted=try Bartleby.cryptoDelegate.decryptData(data)
                return try JSerializer._deserializeFromData(decrypted, autoDecrypt: false)
            }else{
                throw SerializableError.EnableToTransformDataToDictionary
            }
        }
    }


    /**
     Deserializes from NSData

     - parameter dictionary: the dictionnary

     - returns: an instance
     */
    static public func deserializeFromDictionary(dictionary: [String:AnyObject]) throws -> Serializable {
        if var typeName = dictionary[Default.TYPE_NAME_KEY] as? String {
            typeName = Registry.resolveTypeName(from: typeName)
            if let Reference = NSClassFromString(typeName) as? Serializable.Type {
                if  var mappable = Reference.init() as? Mappable {
                    let map=Map(mappingType: .FromJSON, JSONDictionary : dictionary)
                    mappable.mapping(map)
                    if let serializable = mappable as? Serializable {
                        return serializable
                    } else {
                        throw SerializableError.TypeMissmatch
                    }
                } else {
                    throw SerializableError.TypeMissmatch
                }
            } else {
                throw SerializableError.TypeMissmatch
            }
        } else {
            throw SerializableError.TypeNameUndefined
        }
    }



    /**
     Creates a separate instance in memory that is not registred.
     (!) advanced feature. The copied instance is reputed volatile and will not be managed by Bartleby's registries.

     - parameter instance: the original

     - returns: a volatile deep copy.
     */
    static public func volatileDeepCopy<T: Collectible>(instance: T) throws -> T? {
        let data: NSData=JSerializer.serialize(instance)
        return try JSerializer.deserialize(data) as? T
    }


    static public func serialize(instance: Serializable) -> NSData {
        return instance.serialize()
    }


    public static var fileExtension: String {
        get {
            return "json"
        }
    }

}
