//
//  BartlebyObject+Contracts.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/12/2016.
//
//

import Foundation

/*

    free:  In case of deletion of one of the related terms the other is preserved
    owned: In case of deletion of the owner the owned is automatically deleted. (the contract is exclusive)
    owns:  reciprocity of owned
    co_owns: shared ownerships
    co_owned: reciprocity of co_owns
    fusional: both object owns the other if one is deleted the other is also deleted

*/

extension BartlebyObject{

    // MARK: - Relationships Declaration

    /// An Object enters in a free relation Ship with another
    ///
    /// - Parameter object: the owned object
    open func declaresFreeRelationShip(to object:BartlebyObject){
        self._addRelation(to: object, .free)
    }


    /// The owner declares it properties
    /// Both relation are setup owns, and owned
    ///
    /// - Parameter object: the owned object
    open func declaresOwnership(of object:BartlebyObject){
        self._addRelation(to: object, .owns)
        object._addRelation(to: self, .owned)
    }

    /// The owner declares it properties
    /// Both relation are setup owns, and owned
    ///
    /// - Parameter object: the owned object
    open func declaresCollectiveOwnership(of object:BartlebyObject){
        self._addRelation(to: object, .co_owns)
        object._addRelation(to: self, .co_owned)
    }


    /// The owner declares it properties
    /// Both relation are setup owns, and owned
    ///
    /// - Parameter object: the owned object
    open func declaresFusionalRelationship(with object:BartlebyObject){
        self._addRelation(to: object, .fusional)
        object._addRelation(to: self, .fusional)
    }


     // MARK: - Relationships getters


    /// Resolve the Related Objects
    ///
    /// - Returns: the collection of related object
    open func related<T:BartlebyObject>(_ relationship:Relationship)->[T]{
        var related=[T]()
        for UID in self._getContractedRelations(relationship){
            if let candidate = try? Bartleby.registredObjectByUID(UID) as T{
                related.append(candidate)
            }
        }
        return related
    }


    /// Resolve the Related Objects
    ///
    /// - Returns: the collection of related object
    open func related<T:BartlebyObject>(_ relationships:Set<Relationship>)->[T]{
        var related=[T]()
        var relatedUIDs=[String]()
        for relationShip in relationships{
            relatedUIDs.append(contentsOf:self._getContractedRelations(relationShip))
        }
        for UID in relatedUIDs{
             if let candidate = try? Bartleby.registredObjectByUID(UID) as T{
                related.append(candidate)
             }
        }
        return related
    }


    // MARK: - implementation


    /// Add a relation to another object
    ///
    /// - Parameter object: the object
    internal func _addRelation(to object:BartlebyObject,_ contract:Relationship){
        var contractedRelations=self._getContractedRelations(contract)
        if !contractedRelations.contains(object.UID){
           contractedRelations.append(object.UID)
        }
    }


    /// Returns the contracted relations
    ///
    /// - Parameter contract: the nature of the contract
    /// - Returns: the relations
    internal func _getContractedRelations(_ contract:Relationship)->[String]{
        if self._relations[contract.rawValue]==nil{
            self._relations[contract.rawValue]=[String]()
        }
        return self._relations[contract.rawValue] as! [String]
    }




}
