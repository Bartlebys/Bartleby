//
//  ManagedModel+Contracts.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/12/2016.
//
//

import Foundation

extension ManagedModel{

    // MARK: - Relationships Declaration

    /// An Object enters in a free relation Ship with another
    ///
    /// - Parameter object: the owned object
    open func declaresFreeRelationShip(to object:ManagedModel){
        self._addRelation(.free,to: object)
    }


    /// The owner declares it properties
    /// Both relation are setup owns, and owned
    ///
    /// - Parameter object: the owned object
    open func declaresOwnership(of object:ManagedModel){
        self._addRelation(.owns,to: object)
        object._addRelation(.ownedBy,to: self)
    }

    /// The owner declares it properties
    /// Both relation are setup owns, and owned
    ///
    /// - Parameter object: the owned object
    open func declaresCollectiveOwnership(of object:ManagedModel){
        self._addRelation(.ownsCollectively,to: object)
        object._addRelation(.ownedCollectivelyBy,to: self)
    }


    /// The owner declares it properties
    /// Both relation are setup owns, and owned
    ///
    /// - Parameter object: the owned object
    open func declaresFusionalRelationship(with object:ManagedModel){
        self._addRelation(.fusional, to: object)
        object._addRelation(.fusional, to: self)
    }


     // MARK: - Relationships getters


    /// Resolve the Related Objects
    ///
    /// - Returns: the collection of related object
    open func relations<T:ManagedModel>(_ relationship:Relationship)->[T]{
        var related=[T]()
        for relation in self._getContractedRelations(relationship){
            if let candidate = try? Bartleby.registredObjectByUID(relation.UID) as T{
                related.append(candidate)
            }
        }
        return related
    }


    /// Resolve the Related Objects
    ///
    /// - Returns: the collection of related object
    open func relations<T:ManagedModel>(_ relationships:Set<Relationship>)->[T]{
        var related=[T]()
        var relations=[Relation]()
        for relationShip in relationships{
            relations.append(contentsOf:self._getContractedRelations(relationShip))
        }
        for relation in relations{
             if let candidate = try? Bartleby.registredObjectByUID(relation.UID) as T{
                related.append(candidate)
             }
        }
        return related
    }

    /// Resolve the Related Object and returns the first one
    ///
    /// - Returns: the collection of related object
    open func firstRelation<T:ManagedModel>(_ relationship:Relationship)->T?{
        for relation in self._getContractedRelations(relationship){
            if let candidate = try? Bartleby.registredObjectByUID(relation.UID) as T{
               return candidate
            }
        }
        return nil
    }


    // MARK: - implementation


    /// Add a relation to another object
    ///
    /// - Parameter object: the object
    internal func _addRelation(_ contract:Relationship,to object:ManagedModel){
        let candidates=self._getContractedRelations(contract)
        if !candidates.contains(where:{$0.UID==object.UID}){
            let relation=Relation()
            relation.relationship=contract.rawValue
            relation.UID=object.UID
            self._relations.append(relation)
        }
    }


    /// Returns the contracted relations
    ///
    /// - Parameter contract: the nature of the contract
    /// - Returns: the relations
    internal func _getContractedRelations(_ contract:Relationship)->[Relation]{
        return self._relations.filter({$0.relationship==contract.rawValue})
    }




}
