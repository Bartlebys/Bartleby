//
//  Serializer.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 24/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation

/// A Serializer is able to Serialize / Deserialize
/// from and to an Opaque binary TYPE
/// It deals with the dynamic casting.
/// Refer to `JSONSerializer` for an implementation
///
/// A serializer defines it own  dialect.
/// Instance of Type X -> Data
/// Data -> Instance of Type X
///
/// A Serializer enable to register
/// the deserialized Instances in their collection & document.
///
/// Note: To support safely UTF8 you can use base64Encoded Data
public protocol Serializer {

    // MARK: -

    // The containing document reference
    var document:BartlebyDocument { get }

    /// The file extension for file based serializers. eg: "json" for JSONSerializer
    var fileExtension: String { get }


    /// The initializer
    ///
    /// - Parameter document: the document that contains the serializer
    init(document:BartlebyDocument)

    // MARK: - Deserialization

    /// Deserializes a fully typed object
    ///
    /// - Parameters:
    ///   - data: the opaque data
    ///   - register: should we register to document and collection?
    /// - Returns: the deserialized object
    /// - Throws: Deserialization exceptions
    func deserialize<T:Collectible>(_ data: Data,register:Bool) throws -> T


    /// Deserializes from an UTF8 string
    /// - Parameters:
    ///   - string: the string
    ///   - register: should we register to document and collection?
    /// - Returns: the deserialized object
    /// - Throws: Variable exception (serializer based)
    func deserializeFromUTF8String<T:Collectible>(_ string:String,register:Bool)throws ->T


    // MARK: - Serialization


    ///  Serializes an instance
    ///
    /// - Parameter instance: the Serializable instance
    /// - Returns: the data
    func serialize(_ instance: Collectible) -> Data


    /// Serializes the current instance to an UTF8 String
    ///
    /// - Parameter instance: the serializable instance
    /// - Returns: the UTF8 string
    func serializeToUTF8String(_ instance: Collectible) -> String


}
