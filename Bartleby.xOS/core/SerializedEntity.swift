//
//  SerializedEntity.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 04/08/2017.
//

import Foundation


/// A data container that can facilitate dynamic deserialization
public struct SerializedEntity:Codable {

    public var data:Data
    public var typeName:String

}

// MARK: - ToSerializedEntity

public protocol ToSerializedEntity{
    /// Creates a `Codable` entity that encapsulates the serialized self and its typeName
    /// This entity is suitable for DynamicDeserialization
    ///
    /// - Returns: the serialized entity
    func toSerializedEntity()->SerializedEntity

}


// MARK: - Managed and UnManaged models adopts ToSerializedEntity

extension ManagedModel:ToSerializedEntity{

    
    /// Creates a `Codable` entity that encapsulates the serialized self and its typeName
    /// This entity is suitable for DynamicDeserialization
    ///
    /// - Returns: the serialized entity
    open func toSerializedEntity()->SerializedEntity{
        let data = self.serialize()
        let typeName = type(of: self).typeName()
        return SerializedEntity(data:data,typeName:typeName)
    }

}


extension UnManagedModel:ToSerializedEntity{

    /// Creates a `Codable` entity that encapsulates the serialized self and its typeName
    /// This entity is suitable for DynamicDeserialization
    ///
    /// - Returns: the serialized entity
    open func toSerializedEntity()->SerializedEntity{
        let data = self.serialize()
        let typeName = type(of: self).typeName()
        return SerializedEntity(data:data,typeName:typeName)
    }

}
