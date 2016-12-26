//
//  RelationsResolution.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 16/12/2016.
//
//

import Foundation

public protocol RelationsResolution{

    // MARK: - Relationships getters
    /// Resolve the Related Objects
    ///
    /// - Parameters:
    ///   - relationship: the searched relationship
    /// - Returns: return the related Objects
    func relations<T:Relational>(_ relationship:Relationship)->[T]


    /// Resolve the Related Objects
    ///
    /// - Parameters:
    ///   - relationship: the searched relationships
    /// - Returns: return the related Objects
    func relationsInSet<T:Relational>(_ relationships:Set<Relationship>)->[T]


    /// Resolve the Related Object and returns the first one
    ///
    /// - Parameters:
    ///   - relationship: the searched relationships
    func firstRelation<T:Relational>(_ relationship:Relationship)->T?


}
