//
//  SerializedRelationalObject.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 04/08/2017.
//

import Foundation


/// A data container that allows to serialize / deserialize Codable model
/// If the model is Relational its `owns`property should be preserved
public struct SerializedRelationalObject:Codable {

    public var data:Data
    public var owns:[String]

    /// Returns the managed Model from a serialized Entity
    ///
    /// - Parameter SerializedRelationalObject: the entity
    /// - Returns: the instance with its restored ownerships
    public func instanciate<ModelType:RelationalCodable>()throws->ModelType{
        let instance: ModelType = try JSON.decoder.decode(ModelType.self, from: self.data)
        for owneeUID in self.owns{
            if let ownee = Bartleby.registredManagedModelByUID(owneeUID){
                instance.declaresOwnership(of: ownee)
            }else{
                throw SerializedEntityError.relationNotFound(UID: owneeUID)
            }
        }
        return instance
    }
}

public typealias RelationalCodable = Codable & Relational

enum SerializedEntityError:Error{
    case relationNotFound(UID:String)
}

// MARK: - Protocols

public protocol ToSerializedRelationalObject{

    /// Creates a `Codable` entity that encapsulates the serialized self and its typeName
    /// This entity is suitable for DynamicDeserialization
    ///
    /// - Returns: the serialized entity
    func toSerializedRelationalObject()->SerializedRelationalObject
}



// MARK: - Managed models adopt ToSerializedRelationalObject

extension ManagedModel:ToSerializedRelationalObject{

    /// Creates a `Codable` entity that encapsulates the serialized self and its typeName
    /// This entity is suitable for DynamicDeserialization
    ///
    /// - Returns: the serialized entity
    open func toSerializedRelationalObject()->SerializedRelationalObject{
        let data = self.serialize()
        return SerializedRelationalObject(data:data,owns:self.owns)
    }
}


