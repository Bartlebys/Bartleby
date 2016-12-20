//
//  Relational.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 16/12/2016.
//
//

public protocol Relational:Identifiable{

    // MARK: - Relationships Declaration

    /// An Object enters in a free relation Ship with another
    ///
    /// - Parameters:
    ///   - object:  object: the owned object
    ///   - external: if set to true we will create an external association
    func declaresFreeRelationShip(to object:Relational,external:Bool)


    /// The owner declares it properties
    /// Both relation are setup owns, and owned
    ///
    /// - Parameters:
    ///   - object:  object: the owned object
    ///   - external: if set to true we will create an external association
    func declaresOwnership(of object:Relational,external:Bool)

    /// The owner declares it properties
    /// Both relation are setup coOwns, and coOwnedBy
    ///
    /// - Parameters:
    ///   - object:  object: the owned object
    ///   - external: if set to true we will create an external association
    func declaresCollectiveOwnership(of object:Relational,external:Bool)

    /// The owner declares it properties
    /// Both fusional relation are setup
    ///
    /// - Parameters:
    ///   - object:  object: the owned object
    ///   - external: if set to true we will create an external association
    func declaresFusionalRelationship(with object:Relational,external:Bool)


    /// Add a relation to another object
    /// - Parameters:
    ///   - contract: define the relationship
    ///   - object:  the related object
    ///   - external: if set to true we will create an external association
    func addRelation(_ relationship:Relationship,to object:Relational,external:Bool)


    /// Remove a relation to another object
    ///
    /// - Parameters:
    ///   - relationship: define the relationship
    ///   - object:  object: the owned object
    ///   - external: if set to true we will create an external association
    func removeRelation(_ relationship:Relationship,to object:Relational,external:Bool)

    ///  Returns the contracted relations
    ///
    /// - Parameters:
    ///   - relationship:  the nature of the contract
    ///   - includeAssociations: if set to true aggregates externally Associated Relations 
    /// - Returns: the relations
    func getContractedRelations(_ relationship:Relationship,includeAssociations:Bool)->[Relation]



}

