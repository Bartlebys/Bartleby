//
//  Serializer.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 24/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.



import Foundation


// NSDATA is an Opaque binary TYPE
// A serializer should uses defines it own dialect.
// Instance of Type X -> NSData
// NSData -> Instance of Type X



public protocol Serializer {

    // MARK : - Static

    /**
     Deserializes a fully typed object

     - parameter data: the NSData

     - returns: the serizalizable Object
     */
    static func deserialize(data: NSData) -> Serializable

    static func deserializeFromDictionary(dictionary: [String:AnyObject])->Serializable

    /**
     Serialize an instance

     - parameter instance: the Serializable instance

     - returns: the NSData
     */
    static func serialize(instance: Serializable) -> NSData


    // MARK : - Instance

    /**
     Deserializes a fully typed object

     - parameter data: the NSData

     - returns: the serizalizable Object
     */
    func deserialize(data: NSData) -> Serializable

    func deserializeFromDictionary(dictionary: [String:AnyObject])->Serializable

    /**
     Serialize an instance

     - parameter instance: the Serializable instance

     - returns: the NSData
     */
    func serialize(instance: Serializable) -> NSData

    /// The file extension for file based serializers. eg: "json" for JSerializer
    var fileExtension: String { get }

}
