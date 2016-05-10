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

     - returns: an instance (or an ObjectError)
     */
    static public func deserialize(data: NSData) -> Serializable {
        do {
            if let JSONDictionary = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments) as? [String:AnyObject] {
                return JSerializer.deserializeFromDictionary(JSONDictionary)
            }
        } catch {
            let e=ObjectError()
            e.message="JSerializer has encountered ad JSON deserialization Error \(error) \n \(data) "
            return e
        }
        let e=ObjectError()
        e.message="JSerializer has encountered an unqualified JSON deserialization Error"
        return e
    }


    /**
     Deserializes from NSData

     - parameter dictionary: the dictionnary

     - returns: an instance (or an ObjectError)
     */
    static public func deserializeFromDictionary(dictionary: [String:AnyObject]) -> Serializable {
        if var typeName = dictionary[Default.TYPE_NAME_KEY] as? String {
            do {
                typeName = try Registry.resolveTypeName(from: typeName)
                    if let Reference: Collectible.Type = NSClassFromString(typeName) as? Collectible.Type {
                        if  var mappable = Reference.init() as? Mappable {
                            let map=Map(mappingType: .FromJSON, JSONDictionary : dictionary)
                            mappable.mapping(map)
                            if let serializable = mappable as? Serializable {
                                return serializable
                            }
                        }
                    }
            } catch BartlebyError.UniversalSerializationTypMissmatch {
                let e=ObjectError()
                e.message="JSerializer failure the type \(typeName) is not valid for Bartleby"
                return e
            } catch {
                let e=ObjectError()
                e.message="JSerializer Unkwnow exeception\(error) \(dictionary)"
                return e
            }

        }
        let e=ObjectError()
        e.message="JSerializer failure \(dictionary)"
        return e
    }

    /**
     Creates a separate instance in memory that is not registred.
     (!) advanced feature. The copied instance is reputed volatile and will not be managed by Bartleby's registries.

     - parameter instance: the original

     - returns: a volatile deep copy.
     */
    static public func volatileDeepCopy<T>(instance: T) -> T? {
        if let instance=instance as? JObject {
            let data: NSData=JSerializer.serialize(instance)
            return JSerializer.deserialize(data) as? T
        }
        return nil
    }

    public func deserializeFromDictionary(dictionary: [String:AnyObject]) -> Serializable {
       return JSerializer.deserializeFromDictionary(dictionary)
    }


    static public func serialize(instance: Serializable) -> NSData {
        return instance.serialize()
    }


    public func deserialize(data: NSData) -> Serializable {
        return JSerializer.deserialize(data)
    }

    public func serialize(instance: Serializable) -> NSData {
        return instance.serialize()
    }

    public var fileExtension: String {
        get {
            return "json"
        }
    }

}
