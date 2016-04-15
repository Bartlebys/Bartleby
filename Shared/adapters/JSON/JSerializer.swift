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


public class JSerializer:Serializer{
    
    static public func deserialize(data:NSData) ->Serializable {
        do {
            if let JSONDictionary = try NSJSONSerialization.JSONObjectWithData(data,options:NSJSONReadingOptions.AllowFragments) as? [String:AnyObject] {
                return JSerializer.deserializeFromDictionary(JSONDictionary)
            }
        }catch{
            let e=ObjectError()
            e.message="JSerializer has encountered ad JSON deserialization Error \(error) \n \(data) "
            return e
        }
        let e=ObjectError()
        e.message="JSerializer has encountered an unqualified JSON deserialization Error"
        return e
    }
    
    static public func deserializeFromDictionary(dictionary:[String:AnyObject])->Serializable{
        if let referenceName:String = dictionary[Default.REFERENCE_NAME_KEY] as? String {
            
            // referenceName=referenceName.stringByReplacingOccurrencesOfString("NSKVONotifying_",withString:"")
            if let Reference:Collectible.Type = NSClassFromString(referenceName) as? Collectible.Type {  
                if  var mappable = Reference.init() as? Mappable {
                    let map=Map(mappingType: .FromJSON, JSONDictionary: dictionary)
                    mappable.mapping(map)
                    if let serializable = mappable as? Serializable{
                        return serializable
                    }
                }
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
    static public func volatileDeepCopy<T>(instance:T)->T?{
        if let instance=instance as? JObject{
            let data:NSData=JSerializer.serialize(instance)
            return JSerializer.deserialize(data) as? T
        }
        return nil
    }
    
    
    
    public func deserializeFromDictionary(dictionary:[String:AnyObject])->Serializable{
       return JSerializer.deserializeFromDictionary(dictionary)
    }
    
    
    static public func serialize(instance:Serializable) -> NSData{
        return instance.serialize()
    }
    
    
    public func deserialize(data:NSData) ->Serializable {
        return JSerializer.deserialize(data)
    }
    
    public func serialize(instance:Serializable) -> NSData{
        return instance.serialize()
    }
    
    public var fileExtension:String{
        get{
            return "json"
        }
    }
    
    
    

}