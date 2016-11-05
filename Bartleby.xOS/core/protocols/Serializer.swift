//
//  Serializer.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 24/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation


/// DATA is an Opaque binary TYPE
/// A serializer should uses defines it own dialect.
/// Instance of Type X -> Data
/// Data -> Instance of Type X
/// To support UTF8 you can use base64Encoded Data
public protocol Serializer {

    // MARK: - Deserialization

    /// Deserializes a fully typed object
    ///
    /// - Parameter data:  data
    /// - Returns: the serizalizable Object
    /// - Throws: ...
    static func deserialize(_ data: Data) throws -> Serializable


    /// Deserializes from an UTF8 string
    ///
    /// - Parameter dictionary: the dictionary
    /// - Returns: the serializable instance
    /// - Throws: Variable exception (serializer based)
    static func deserializeFromUTF8String(_ string:String)throws ->Serializable


    /// Deserializes from a dictionary
    ///
    /// - Parameter dictionary: the dictionary
    /// - Returns: the serializable instance
    /// - Throws: Variable exception (serializer based)
    static func deserializeFromDictionary(_ dictionary: [String:Any])throws ->Serializable

    // MARK: - Serialization

    ///  Serializes an instance
    ///
    /// - Parameter instance: the Serializable instance
    /// - Returns: the data
    static func serialize(_ instance: Serializable) -> Data


    /// Serializes the current instance to an UTF8 String
    ///
    /// - Parameter instance: the serializable instance
    /// - Returns: the UTF8 string
    static func serializeToUTF8String(_ instance: Serializable) -> String


    /// The file extension for file based serializers. eg: "json" for JSerializer
    static var fileExtension: String { get }

}
