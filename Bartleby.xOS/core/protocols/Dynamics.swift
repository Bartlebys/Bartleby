//
//  DynamicSerializer.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/08/2017.
//

import Foundation

public enum DynamicsError:Error{
    case typeNotFound
    case jsonDeserializationFailure
}

// We use dynamic deserialization to handle triggers, operation provisionning and Server sent events.
// Everywhere else you should use the standard Serializer
public protocol Dynamics{



    /// Deserializes dynamically an entity based on its Class name.
    ///
    /// - Parameters:
    ///   - typeName: the typeName
    ///   - data: the encoded data
    ///   - document: the document to register In the instance (if set to nil the instance will not be registred
    /// - Returns: the dynamic instance that you cast..?
    func deserialize(typeName:String,data:Data,document:BartlebyDocument?)throws->Any

    /// This is a Dyamic Factory
    ///
    /// - Parameter typeName: the class name
    /// - Returns: the new instance
    func newInstanceOf(_ typeName:String)throws->Any


    // MARK : - Patch (migration support)


    /// You can patch some data providing default values.
    ///
    /// - Parameters:
    ///   - typeName: the concerned typeName
    ///   - data: the Data to patch
    ///   - dictionary: the dictionary
    /// - Returns: the patched data
    func patchProperties(_ typeName:String,data:Data,dictionary:[String:Any])throws->Data

}
