//
//  ManagedModel+RelationsResolution.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 16/12/2016.
//
//

import Foundation


extension ManagedModel:RelationsResolution{


    /// Resolve the Related Objects
    ///
    /// - Parameters:
    ///   - relationship: the searched relationship
    ///   - includeAssociations: if set to true aggregates externally Associated Relations (computationnaly intensive)
    /// - Returns: return the related Objects
    open func relations<T:Relational>(_ relationship:Relationship,includeAssociations:Bool=false)->[T]{
        var related=[T]()
        for relation in self.getContractedRelations(relationship,includeAssociations: includeAssociations){
            if let candidate = try? Bartleby.registredObjectByUID(relation.UID) as ManagedModel{
                if let casted = candidate as? T{
                    related.append(casted)
                }
            }
        }
        return related
    }


    /// Resolve the Related Objects
    ///
    /// - Parameters:
    ///   - relationship: the searched relationships
    ///   - includeAssociations: if set to true aggregates externally Associated Relations (computationnaly intensive)
    /// - Returns: return the related Objects
    open func relationsInSet<T:Relational>(_ relationships:Set<Relationship>,includeAssociations:Bool=false)->[T]{
        var related=[T]()
        var relations=[Relation]()
        for relationShip in relationships{
            relations.append(contentsOf:self.getContractedRelations(relationShip,includeAssociations:includeAssociations))
        }
        for relation in relations{
            if let candidate = try? Bartleby.registredObjectByUID(relation.UID) as ManagedModel{
                if let casted = candidate as? T{
                    related.append(casted)
                }
            }
        }
        return related
    }


    /// Resolve the Related Object and returns the first one
    ///
    /// - Parameters:
    ///   - relationship: the searched relationships
    ///   - includeAssociations: if set to true aggregates externally Associated Relations (computationnaly intensive)
    open func firstRelation<T:Relational>(_ relationship:Relationship,includeAssociations:Bool=false)->T?{
        // Internal relations.
        let internalRelations=self._relations.filter({$0.relationship==relationship.rawValue})
        if internalRelations.count>0{
            for relation in internalRelations{
                if let candidate = try? Bartleby.registredObjectByUID(relation.UID) as ManagedModel{
                    if let casted = candidate as? T{
                        return casted
                    }
                }
            }
        }else{
            // Try external relations
            if let associated:[Association]=self.referentDocument?.associations.filter({ (association) -> Bool in
                return (association.subjectUID == self.UID && association.contract.relationship == relationship.rawValue)
            }){
                for association in associated {
                    if let candidate = try? Bartleby.registredObjectByUID(association.contract.UID) as ManagedModel{
                        if let casted = candidate as? T{
                            return casted
                        }
                    }
                }
            }
        }
        return nil
    }

}
