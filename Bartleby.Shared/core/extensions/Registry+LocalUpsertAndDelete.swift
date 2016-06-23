//
//  Registry+URD.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 05/05/2016.
//
//

import Foundation

// MARK:- Local Instance(s) UD(s)


public extension Registry {

    // MARK: Upsert

    /**
     Inserts or updates a Collectible instance.
     Upsert : insert + update

     - parameter instance: the instance

     - returns: success or failure flag
     */
    public func upsert(instance: Collectible) -> Bool {
        if let collection=self._collectionByName(instance.d_collectionName) as? CollectibleCollection {
            collection.upsert(instance, commit:false)
        }
        return false
    }

    /**
     Create or update a collection of Collectible instances.
     Upsert : insert + update

     - parameter instances: the instances

     - returns: success or failure flag
     */
    public func upsert(instances: [Collectible]) -> Bool {
        var result=true
        for instance in instances {
            result=result&&self.upsert(instance)
        }
        return result
    }

    // MARK: read



    // MARK: delete

    /**
     Deletes the Collectible instance.

     - parameter instance: the instance

     - returns: success or failure flag
     */
    public func delete(instance: Collectible) -> Bool {
        if let collection=self._collectionByName(instance.d_collectionName) as? CollectibleCollection {
            return collection.removeObject(instance, commit:false)
        }
        return false
    }

    /**
     Deletes a bunch of Collectible instance.

     - parameter instances: the instances

     - returns: success or failure flag
     */
    public func delete(instances: [Collectible]) -> Bool {
        var result=true
        for instance in instances {
            result=result&&self.delete(instance)
        }
        return result
    }


    /**
     Deletes a Collectible instance by its UID

     - parameter instanceUID: the instance UID
     - parameter fromCollectionWithName : the collection name

     - returns: success or failure flag
     */
    public func deleteById(instanceUID: String, fromCollectionWithName: String) -> Bool {
        if let collection=self._collectionByName(fromCollectionWithName) as? CollectibleCollection {
            return collection.removeObjectWithID(instanceUID, commit:false)
        }
        return false
    }

    /**
     Deletes a Collectible instance by its UID

     - parameter instancesUIDs: an array of instances' UID
     - parameter fromCollectionWithName : the collection name

     - returns: success or failure flag
     */
    public func deleteByIds(instancesUIDs: [String], fromCollectionWithName: String) -> Bool {
        var result=true
        for instanceUID in instancesUIDs {
            result=result&&self.deleteById(instanceUID, fromCollectionWithName: fromCollectionWithName)
        }
        return result
    }

}
