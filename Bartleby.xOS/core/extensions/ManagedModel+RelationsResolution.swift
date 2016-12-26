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
    /// - Returns: return the related Objects
    open func relations<T:Relational>(_ relationship:Relationship)->[T]{
        var related=[T]()
        for object in self.getContractedRelations(relationship){
            if let candidate = try? Bartleby.registredObjectByUID(object) as ManagedModel{
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
    /// - Returns: return the related Objects
    open func relationsInSet<T:Relational>(_ relationships:Set<Relationship>)->[T]{
        var related=[T]()
        var objectsUID=[String]()
        for relationShip in relationships{
            objectsUID.append(contentsOf:self.getContractedRelations(relationShip))
        }
        for objectUID in objectsUID{
            if let candidate = try? Bartleby.registredObjectByUID(objectUID) as ManagedModel{
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
    open func firstRelation<T:Relational>(_ relationship:Relationship)->T?{
        // Internal relations.
        let objectsUID=self.getContractedRelations(relationship)
        if objectsUID.count>0{
            for objectUID in objectsUID{
                if let candidate = try? Bartleby.registredObjectByUID(objectUID) as ManagedModel{
                    if let casted = candidate as? T{
                        return casted
                    }
                }
            }
        }
        return nil
    }

}
