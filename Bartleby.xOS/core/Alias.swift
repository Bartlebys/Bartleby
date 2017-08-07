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


// MARK: - AliasResolver


/// Bartleby is a notorious AliasResolver.
public protocol AliasResolver{

     /// Resolve the alias
     ///
     /// - Parameter alias: the alias
     /// - Returns: the reference
     static func instance(from alias:Alias)->Aliasable?
}
