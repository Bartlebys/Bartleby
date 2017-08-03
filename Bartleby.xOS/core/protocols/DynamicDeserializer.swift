//
//  DynamicSerializer.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/08/2017.
//

import Foundation

public enum DynamicDeserializerError:Error{
    case classNotFound
}

// We use dynamic deserialization to handle triggers, operation provisionning and Server sent events.
// Everywhere else you should use the standard Serializer
public protocol DynamicDeserializer{

    /// Deserializes dynamically an entity based on its Class name.
    ///
    /// - Parameters:
    ///   - className: the className
    ///   - data: the encoded data
    ///   - document: the document to register In the instance (if set to nil the instance will not be registred
    /// - Returns: the dynamic instance that you cast..?
    func deserialize(className:String,data:Data,document:BartlebyDocument?)throws->Any

}
