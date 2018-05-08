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

extension ManagedModel {

    // MARK: - Relationships Declaration

    /// An Object enters in a free relation Ship with another
    ///
    /// - Parameters:
    ///   - object:  object: the owned object
    open func declaresFreeRelationShip(to object: Relational) {
        addRelation(.free, to: object)
    }

    /// The owner declares its property
    /// Both relation are setup owns, and owned
    ///
    /// - Parameters:
    ///   - object:  object: the owned object
    open func declaresOwnership(of object: Relational) {
        addRelation(.owns, to: object)
        object.addRelation(.ownedBy, to: self)
    }

    /// Add a relation to another object
    /// - Parameters:
    ///   - contract: define the relationship
    ///   - object:  the related object
    open func addRelation(_ relationship: Relationship, to object: Relational) {
        switch relationship {
        case Relationship.free:
            if !freeRelations.contains(object.UID) {
                freeRelations.append(object.UID)
            }
            break
        case Relationship.owns:
            if !owns.contains(object.UID) {
                owns.append(object.UID)
            }
            break
        case Relationship.ownedBy:
            if !ownedBy.contains(object.UID) {
                ownedBy.append(object.UID)
            }
            break
        }
    }

    /// The owner renounces to its property
    ///
    /// - Parameter object: the object
    open func removeOwnerShip(of object: Relational) {
        removeRelation(Relationship.owns, to: object)
    }

    /// Renounces to free relationship
    ///
    /// - Parameter object: the object
    open func removeFreeRelationShip(to object: Relational) {
        removeRelation(Relationship.free, to: object)
    }

    /// Remove a relation to another object
    ///
    /// - Parameter object: the object
    open func removeRelation(_ relationship: Relationship, to object: Relational) {
        switch relationship {
        case Relationship.free:
            if let idx = self.freeRelations.index(of: object.UID) {
                freeRelations.remove(at: idx)
            }
            break
        case Relationship.owns:
            if let idx = self.owns.index(of: object.UID) {
                owns.remove(at: idx)
                object.removeRelation(Relationship.ownedBy, to: self)
            }
            break
        case Relationship.ownedBy:
            if let idx = self.ownedBy.index(of: object.UID) {
                ownedBy.remove(at: idx)
            }
            break
        }
    }

    ///  Returns the contracted relations
    ///
    /// - Parameters:
    ///   - relationship:  the nature of the contract
    /// - Returns: the relations
    open func getContractedRelations(_ relationship: Relationship) -> [UID] {
        switch relationship {
        case Relationship.free:
            return freeRelations
        case Relationship.owns:
            return owns
        case Relationship.ownedBy:
            return ownedBy
        }
    }
}
