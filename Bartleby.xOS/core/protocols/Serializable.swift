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
    case unableToTransformDataToDictionary
    case invalidUTF8String
}


/**
 *   Any object that is serializable can be serialized deserialized
 */
public protocol Serializable:Initializable,Encodable,Decodable{

    /// Serialize the current object with its type
    ///
    /// - Returns: data
    func serialize() -> Data


    /// Serialize the current object to an UTF8 string
    ///
    /// - Returns: return an UTF8 string
    func serializeToUFf8String()->String
}

