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
// If the owner is deleted its "ownees" are deleted.
// if any owner is deleted all the ownees are destroyed.
// N -> N


// "coOwns": shared ownerships
// "coOwnedBy": reciprocity of coOwns
// In case of deletion of one of it owner that the ownee will survive if at least one of its co owner exists.
// N -> N

// fusional: both object owns the other if one is deleted the other is also deleted ( both are set to fusional)
// N <-> N


extension ManagedModel:Relational{


    // MARK: - Relationships Declaration

    /// An Object enters in a free relation Ship with another
    ///
    /// - Parameters:
    ///   - object:  object: the owned object
    ///   - external: if set to true we will create an external association
    open func declaresFreeRelationShip(to object:Relational,external:Bool=false){
        self.addRelation(.free,to: object,external:external)
    }


    /// The owner declares it properties
    /// Both relation are setup owns, and owned
    ///
    /// - Parameters:
    ///   - object:  object: the owned object
    ///   - external: if set to true we will create an external association
    open func declaresOwnership(of object:Relational,external:Bool=false){
        self.addRelation(.owns,to: object,external:external)
        object.addRelation(.ownedBy,to: self,external:external)
    }

    /// The owner declares it properties
    /// Both relation are setup coOwns, and coOwnedBy
    ///
    /// - Parameters:
    ///   - object:  object: the owned object
    ///   - external: if set to true we will create an external association
    open func declaresCollectiveOwnership(of object:Relational,external:Bool=false){
        self.addRelation(.coOwns,to: object,external:external)
        object.addRelation(.coOwnedBy,to: self,external:external)
    }


    /// The owner declares it properties
    /// Both fusional relation are setup
    ///
    /// - Parameters:
    ///   - object:  object: the owned object
    ///   - external: if set to true we will create an external association
    open func declaresFusionalRelationship(with object:Relational,external:Bool=false){
        self.addRelation(.fusional, to: object,external:external)
        object.addRelation(.fusional, to: self,external:external)
    }


    /// Add a relation to another object
    /// - Parameters:
    ///   - contract: define the relationship
    ///   - object:  the related object
    ///   - external: if set to true we will create an external association
    open func addRelation(_ relationship:Relation.Relationship,to object:Relational,external:Bool=false){
        let candidates=self.getContractedRelations(relationship,includeAssociations:external)
        if !candidates.contains(where:{$0.UID==object.UID}){
            if external{
                if let document = self.referentDocument{
                    let association = document.newObject() as Association
                    association.quietChanges {
                        association.subjectUID = self.UID
                        let relation=Relation()
                        relation.UID = object.UID
                        if let c = object as? UniversalType{
                            relation.typeName = type(of: c).typeName()
                        }
                        relation.relationship = relationship
                        association.associated.append(relation)
                    }
                }
            }else{
                let relation=Relation()
                relation.relationship=relationship
                relation.UID=object.UID
                if let c = object as? UniversalType{
                    relation.typeName = type(of: c).typeName()
                }
                self.relations.append(relation)
            }
        }
    }

    /// Remove a relation to another object
    ///
    /// - Parameter object: the object
    open func removeRelation(_ relationship:Relation.Relationship,to object:Relational,external:Bool=false){
        if external{
            if let associations:[Association]=self.referentDocument?.associations.filter({ (association) -> Bool in
                if association.subjectUID != self.UID {
                    return false
                }
                if association.associated.contains(where: { (relation) -> Bool in
                    return relation.relationship == relationship
                }){
                    return true
                }else{
                    return false
                }
            }){
                for association in associations {
                    var toBeDeleted=[Int]()
                    for i in 0 ..< association.associated.count{
                        let relation=association.associated[i]
                        if (relation.relationship == relationship && relation.UID == object.UID){
                            toBeDeleted.append(i)
                        }
                    }
                    for idx in toBeDeleted{
                        association.associated.remove(at: idx)
                    }
                    // If there are no more relations delete the association
                    if association.associated.count==0{
                        self.referentDocument?.associations.removeObject(association)
                    }
                }
            }
        }else{
            var toBeDeleted=[Int]()
            var idx=0
            for relation in self.relations{
                if relation.relationship==relationship && relation.UID==object.UID{
                    toBeDeleted.append(idx)
                }
                idx += 1
            }
            for deletionIndex in toBeDeleted.reversed(){
                self.relations.remove(at: deletionIndex)
            }
        }
    }


    ///  Returns the contracted relations
    ///
    /// - Parameters:
    ///   - relationship:  the nature of the contract
    ///   - includeAssociations: if set to true aggregates externally Associated Relations
    /// - Returns: the relations
    open func getContractedRelations(_ relationship:Relation.Relationship,includeAssociations:Bool=false)->[Relation]{
        if includeAssociations{
            // TODO  registry Optimization (the current implementation is temporary)
            var relations = self.relations.filter({$0.relationship==relationship})
            if let associations:[Association]=self.referentDocument?.associations.filter({ (association) -> Bool in
                if association.subjectUID != self.UID {
                    return false
                }
                if association.associated.contains(where: { (relation) -> Bool in
                    return relation.relationship == relationship
                }){
                    return true
                }else{
                    return false
                }
            }){
                for association in associations {
                    relations.append(contentsOf:  association.associated)
                }
            }
            return relations
        }else{
            return self.relations.filter({$0.relationship==relationship})
        }
    }

}
