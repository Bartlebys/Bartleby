//
//  Serializable.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 08/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.



import Foundation



public enum SerializableError: Error {
    case typeMissmatch
    case typeNameUndefined
    case unknownTypeName(typeName:String)
    case enableToTransformDataToDictionary
}


/**
 *   Any object that is serializable can be serialized deserialized
 */
public protocol Serializable:Initializable{

    /**
     Serialize the current object with its type

     - returns: a NSData
     */
    func serialize() -> Data


    /**
     Update an existant instance
     This approach is used by proxies.

     - parameter data: the NSData

     - returns: the patched Object
     */
    func updateData(_ data: Data,provisionChanges:Bool) throws -> Serializable

}
