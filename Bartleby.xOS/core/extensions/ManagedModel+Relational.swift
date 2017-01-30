//
//  ManagedModel+Contracts.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/12/2016.
//
//

import Foundation


// MARK: - Without reciprocity

// "free"
// In case of deletion of one of the related terms the other is preserved
// (there is not necessarly reciprocity of the relation)
// E.G: tags can freely associated
// N -> N


// MARK: - With reciprocity

// "owns"
// "ownedBy": reciprocity of "owns"
// In case of deletion of the owner the owned is automatically deleted.
// If all the owners are deleted their "ownees" are deleted.
// N -> N


extension ManagedModel{
 

    // MARK: - Relationships Declaration

    /// An Object enters in a free relation Ship with another
    ///
    /// - Parameters:
    ///   - object:  object: the owned object
    open func declaresFreeRelationShip(to object:Relational){
        self.addRelation(.free,to: object)
    }


    /// The owner declares it properties
    /// Both relation are setup owns, and owned
    ///
    /// - Parameters:
    ///   - object:  object: the owned object
    open func declaresOwnership(of object:Relational){
        self.addRelation(.owns,to: object)
        object.addRelation(.ownedBy,to: self)
    }



    /// Add a relation to another object
    /// - Parameters:
    ///   - contract: define the relationship
    ///   - object:  the related object
    open func addRelation(_ relationship:Relationship,to object:Relational){
        switch relationship {
        case Relationship.free:
            if !self.freeRelations.contains(object.UID){
                self.freeRelations.append(object.UID)
            }
            break
        case Relationship.owns:
            if !self.owns.contains(object.UID){
                self.owns.append(object.UID)
            }
            break
        case Relationship.ownedBy:
            if !self.ownedBy.contains(object.UID){
                self.ownedBy.append(object.UID)
            }
            break
        }
    }

    /// Remove a relation to another object
    ///
    /// - Parameter object: the object
    open func removeRelation(_ relationship:Relationship,to object:Relational){
        switch relationship {
        case Relationship.free:
            if let idx=self.freeRelations.index(of:object.UID){
                self.freeRelations.remove(at: idx)
            }
            break
        case Relationship.owns:
            if let idx=self.owns.index(of:object.UID){
                self.owns.remove(at: idx)
                object.removeRelation(Relationship.ownedBy, to: self)
            }
            break
        case Relationship.ownedBy:
            if let idx=self.ownedBy.index(of:object.UID){
                self.ownedBy.remove(at: idx)
            }
            break
        }
    }


    ///  Returns the contracted relations
    ///
    /// - Parameters:
    ///   - relationship:  the nature of the contract
    /// - Returns: the relations
    open func getContractedRelations(_ relationship:Relationship)->[String]{
        switch relationship {
        case Relationship.free:
            return self.freeRelations
        case Relationship.owns:
            return self.owns
        case Relationship.ownedBy:
            return self.ownedBy
        }
    }
    
}
