//
//  ManagedModel+Contracts.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/12/2016.
//
//

import Foundation


extension ManagedModel:Relational{

    // MARK: - Relationships Declaration

    /// An Object enters in a free relation Ship with another
    ///
    /// - Parameter object: the owned object
    open func declaresFreeRelationShip(to object:Relational){
        self.addRelation(.free,to: object)
    }


    /// The owner declares it properties
    /// Both relation are setup owns, and owned
    ///
    /// - Parameter object: the owned object
    open func declaresOwnership(of object:Relational){
        self.addRelation(.owns,to: object)
        object.addRelation(.ownedBy,to: self)
    }

    /// The owner declares it properties
    /// Both relation are setup owns, and owned
    ///
    /// - Parameter object: the owned object
    open func declaresCollectiveOwnership(of object:Relational){
        self.addRelation(.ownsCollectively,to: object)
        object.addRelation(.ownedCollectivelyBy,to: self)
    }


    /// The owner declares it properties
    /// Both relation are setup owns, and owned
    ///
    /// - Parameter object: the owned object
    open func declaresFusionalRelationship(with object:Relational){
        self.addRelation(.fusional, to: object)
        object.addRelation(.fusional, to: self)
    }


    /// Add a relation to another object
    ///
    /// - Parameter object: the object
    open func removeRelation(_ contract:Relationship,to object:Relational){
        var toBeDeleted=[Int]()
        var idx=0
        for relation in self._relations{
            if relation.relationship==contract.rawValue{
                toBeDeleted.append(idx)
            }
            idx += 1
        }
        for deletionIndex in toBeDeleted.reversed(){
            self._relations.remove(at: deletionIndex)
        }
    }


    /// Returns the contracted relations
    ///
    /// - Parameter contract: the nature of the contract
    /// - Returns: the relations
    open func getContractedRelations(_ contract:Relationship)->[Relation]{
        return self._relations.filter({$0.relationship==contract.rawValue})
    }


    /// Add a relation to another object
    ///
    /// - Parameter object: the object
    open func addRelation(_ contract:Relationship,to object:Relational){
        let candidates=self.getContractedRelations(contract)
        if !candidates.contains(where:{$0.UID==object.UID}){
            let relation=Relation()
            relation.relationship=contract.rawValue
            relation.UID=object.UID
            self._relations.append(relation)
        }
    }
}
