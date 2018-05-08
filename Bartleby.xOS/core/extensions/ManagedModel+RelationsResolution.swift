//
//  ManagedModel+RelationsResolution.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 16/12/2016.
//
//

import Foundation

extension ManagedModel: RelationsResolution {
    /// Resolve the Related Objects
    ///
    /// - Parameters:
    ///   - relationship: the searched relationship
    /// - Returns: return the related Objects
    open func relations<T: Relational>(_ relationship: Relationship) -> [T] {
        var related = [T]()
        for object in getContractedRelations(relationship) {
            if let candidate = try? Bartleby.registredObjectByUID(object) as ManagedModel {
                if let casted = candidate as? T {
                    related.append(casted)
                }
            }
        }
        return related
    }

    /// Resolve the filtered Related Objects
    ///
    /// - Parameters:
    ///   - relationship: the searched relationship
    ///   - included: the filtering closure
    /// - Returns: return the related Objects
    open func filteredRelations<T: Relational>(_ relationship: Relationship, included: (T) -> Bool) -> [T] {
        var related = [T]()
        for object in getContractedRelations(relationship) {
            if let candidate = try? Bartleby.registredObjectByUID(object) as ManagedModel {
                if let casted = candidate as? T {
                    if included(casted) == true {
                        related.append(casted)
                    }
                }
            }
        }
        return related
    }

    /// Resolve the filtered Related Objects
    ///
    /// - Parameters:
    ///   - relationship: the searched relationship
    ///   - included: the filtering closure
    /// - Returns: return the related Objects as values and the UID as keys
    open func hashedFilteredRelations<T: Relational>(_ relationship: Relationship, included: (T) -> Bool) -> [UID: T] {
        var related = [String: T]()
        for object in getContractedRelations(relationship) {
            if let candidate = try? Bartleby.registredObjectByUID(object) as ManagedModel {
                if let casted = candidate as? T {
                    if included(casted) == true {
                        related[casted.UID] = casted
                    }
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
    open func relationsInSet<T: Relational>(_ relationships: Set<Relationship>) -> [T] {
        var related = [T]()
        var objectsUID = [String]()
        for relationShip in relationships {
            objectsUID.append(contentsOf: getContractedRelations(relationShip))
        }
        for objectUID in objectsUID {
            if let candidate = try? Bartleby.registredObjectByUID(objectUID) as ManagedModel {
                if let casted = candidate as? T {
                    related.append(casted)
                }
            }
        }
        return related
    }

    /// Resolve the filtered Related Objects
    ///
    /// - Parameters:
    ///   - relationship: the searched relationships
    ///   - included: the filtering closure
    /// - Returns: return the related Objects
    open func filteredRelationsInSet<T: Relational>(_ relationships: Set<Relationship>, included: (T) -> Bool) -> [T] {
        var related = [T]()
        var objectsUID = [String]()
        for relationShip in relationships {
            objectsUID.append(contentsOf: getContractedRelations(relationShip))
        }
        for objectUID in objectsUID {
            if let candidate = try? Bartleby.registredObjectByUID(objectUID) as ManagedModel {
                if let casted = candidate as? T {
                    if included(casted) == true {
                        related.append(casted)
                    }
                }
            }
        }
        return related
    }

    /// Resolve the Related Object and returns the first one
    ///
    /// - Parameters:
    ///   - relationship: the searched relationships
    open func firstRelation<T: Relational>(_ relationship: Relationship) -> T? {
        // Internal relations.
        let objectsUID = getContractedRelations(relationship)
        if objectsUID.count > 0 {
            for objectUID in objectsUID {
                if let candidate = try? Bartleby.registredObjectByUID(objectUID) as ManagedModel {
                    if let casted = candidate as? T {
                        return casted
                    }
                }
            }
        }
        return nil
    }

    /// Resolve the Related Object and returns the first one
    ///
    /// - Parameters:
    ///   - relationship: the searched relationships
    ///   - included: the filtering closure
    // - Returns: return the related Object
    open func filteredFirstRelation<T: Relational>(_ relationship: Relationship, included: (T) -> Bool) -> T? {
        // Internal relations.
        let objectsUID = getContractedRelations(relationship)
        if objectsUID.count > 0 {
            for objectUID in objectsUID {
                if let candidate = try? Bartleby.registredObjectByUID(objectUID) as ManagedModel {
                    if let castedCandidate = candidate as? T {
                        if included(castedCandidate) == true {
                            return castedCandidate
                        }
                    }
                }
            }
        }
        return nil
    }
}
