//
//  Serializable.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 08/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.



import Foundation


/**
 *   Any object that is serializable can be serialized deserialized
 */
public protocol Serializable {

    //The class should be securely intializable with a simple init
    init()

    /**
     Serialize the current object with its type

     - returns: a NSData
     */
    func serialize() -> NSData


    /**
     Update an existant instance
     This approach is used by proxies.

     - parameter data: the NSData

     - returns: the patched Object
     */
    func updateData(data: NSData) throws -> Serializable

}



public protocol DictionaryRepresentation {
    /**
     Should return a dictionary composed of native members that can be serialized (!)

     - returns: the dictionary
     */
    func dictionaryRepresentation()->[String:AnyObject]

}




public enum SerializableError: ErrorType {
    case TypeMissmatch
    case TypeNameUndefined
    case UnknownTypeName(typeName:String)
    case EnableToTransformDataToDictionary
}
