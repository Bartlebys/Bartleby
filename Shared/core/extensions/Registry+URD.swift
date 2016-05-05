//
//  Registry+URD.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 05/05/2016.
//
//

import Foundation

public extension Registry {

    // MARK:- Local Instance(s) URD(s) +

    // MARK: Upsert

    public func upsert(instance: Collectible) -> Bool {
        if let collection=self._collectionByName(instance.d_collectionName) as? CollectibleCollection {
            collection.add(instance)
            return true
        }
        return false
    }

    public func upsert(instances: [Collectible]) -> Bool {
        var result=true
        for instance in instances {
            result=result&&self.upsert(instance)
        }
        return result
    }

    // MARK: read


    /**
     Returns the instance by its UID

     - parameter UID: needle

     - returns: the instance
     */
    static public func objectByUID<T: Collectible>(UID: String) -> T? {
        return  Registry.registredObjectByUID(UID) as T?
    }

    // MARK: delete

    public func delete(instance: Collectible) -> Bool {
        if let collection=self._collectionByName(instance.d_collectionName) as? CollectibleCollection {
            return collection.removeObject(instance)
        }
        return false
    }


    public func delete(instances: [Collectible]) -> Bool {
        var result=true
        for instance in instances {
            result=result&&self.delete(instance)
        }
        return result
    }


    public func deleteById(instanceUID: String, fromCollectionWithName: String) -> Bool {
        if let collection=self._collectionByName(fromCollectionWithName) as? CollectibleCollection {
            return collection.removeObjectWithID(instanceUID)
        }
        return false
    }

    public func deleteByIds(instancesUIDs: [String], fromCollectionWithName: String) -> Bool {
        var result=true
        for instanceUID in instancesUIDs {
            result=result&&self.deleteById(instanceUID, fromCollectionWithName: fromCollectionWithName)
        }
        return result
    }

}
