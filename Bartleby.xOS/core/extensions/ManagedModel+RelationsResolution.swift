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
    /// - Returns: the collection of related object
    open func relations<T:Relational>(_ relationship:Relationship)->[T]{
        var related=[T]()
        for relation in self.getContractedRelations(relationship){
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
    /// - Returns: the collection of related object
    open func relations<T:Relational>(_ relationships:Set<Relationship>)->[T]{
        var related=[T]()
        var relations=[Relation]()
        for relationShip in relationships{
            relations.append(contentsOf:self.getContractedRelations(relationShip))
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
    /// - Returns: the collection of related object
    open func firstRelation<T:Relational>(_ relationship:Relationship)->T?{
        for relation in self.getContractedRelations(relationship){
            if let candidate = try? Bartleby.registredObjectByUID(relation.UID) as ManagedModel{
                if let casted = candidate as? T{
                    return casted
                }
            }
        }
        return nil
    }

}
