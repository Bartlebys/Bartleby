//
//  Reference.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/08/2017.
//

import Foundation

/// The alias struct
public struct Alias:Codable{

    let UID:String

    public func serialize()->Data{
        return try! JSON.encoder.encode(self)
    }

    public static func deserialize(from data:Data) throws ->Alias{
        return try JSON.decoder.decode(Alias.self, from: data)
    }

}

// MARK: - Aliasable

public protocol Aliasable{

    /// Creates a `Codable` alias that encapsulates the serialized UID
    ///
    /// - Returns: the serialized entity
    func alias()->Alias
}


// MARK: - ManagedModel + Aliasable

extension ManagedModel:Aliasable{

    /// Creates a `Codable` entity that encapsulates the serialized UID
    ///
    /// - Returns: the serialized entity
    open func alias()->Alias{
        return Alias(UID:self.UID)
    }

}


// MARK: - AliasResolution


/// Bartleby is a notorious AliasResolution.
public protocol AliasResolution{

     /// Resolve the alias
     ///
     /// - Parameter alias: the alias
     /// - Returns: the reference
     static func instance(from alias:Alias)->Aliasable?
}
