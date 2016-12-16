//
//  Relational.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 16/12/2016.
//
//

public protocol Relational:Identifiable{

    // Used to store inter objects relationships
    var relations:[Relation] { get set }

    // MARK: - Relationships Declaration

    /// An Object enters in a free relation Ship with another
    ///
    /// - Parameter object: the owned object
    func declaresFreeRelationShip(to object:Relational)

    /// The owner declares it properties
    /// Both relation are setup owns, and owned
    ///
    /// - Parameter object: the owned object

    func declaresOwnership(of object:Relational)

    /// The owner declares it properties
    /// Both relation are setup owns, and owned
    ///
    /// - Parameter object: the owned object
    func declaresCollectiveOwnership(of object:Relational)


    /// The owner declares it properties
    /// Both relation are setup owns, and owned
    ///
    /// - Parameter object: the owned object
    func declaresFusionalRelationship(with object:Relational)

    // MARK: - Relationships Management

    /// Add a relation to another object
    ///
    /// - Parameter object: the object
    func addRelation(_ contract:Relationship,to object:Relational)


    /// Add a relation to another object
    ///
    /// - Parameter object: the object
    func removeRelation(_ contract:Relationship,to object:Relational)

    /// Returns the contracted relations
    ///
    /// - Parameter contract: the nature of the contract
    /// - Returns: the relations
    func getContractedRelations(_ contract:Relationship)->[Relation]

}

