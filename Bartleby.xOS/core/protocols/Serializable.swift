//
//  Serializable.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 08/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.



import Foundation



public enum SerializableError: ErrorType {
    case TypeMissmatch
    case TypeNameUndefined
    case UnknownTypeName(typeName:String)
    case EnableToTransformDataToDictionary
}


/**
 *   Any object that is serializable can be serialized deserialized
 */
public protocol Serializable:Initializable{

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
    func updateData(data: NSData,provisionChanges:Bool) throws -> Serializable

}
