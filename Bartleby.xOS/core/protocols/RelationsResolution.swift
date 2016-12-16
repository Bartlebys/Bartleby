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
    /// - Returns: the collection of related object
    func relations<T:Relational>(_ relationship:Relationship)->[T]

    /// Resolve the Related Objects
    ///
    /// - Returns: the collection of related object
    func relations<T:Relational>(_ relationships:Set<Relationship>)->[T]

    /// Resolve the Related Object and returns the first one
    ///
    /// - Returns: the collection of related object
    func firstRelation<T:Relational>(_ relationship:Relationship)->T?
    
}
