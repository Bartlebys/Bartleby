//
//  Registry+URD.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 05/05/2016.
//
//

import Foundation

// MARK:- Local Instance(s) UD(s)

// All the upsert and delete are done on GlobalQueue.Main.get()
// like the data integration in BartlebyDocument+Trigger (_integrateContiguousData)
public extension BartlebyDocument {

    // MARK: Upsert

    /**
     Inserts or updates a Collectible instance.
     Upsert : insert + update

     - parameter instance: the instance
     */
    public func upsert(instance: Collectible){
        if let collection=self.collectionByName(instance.d_collectionName) as? CollectibleCollection {
            collection.upsert(instance, commit:false)
        }
        self.hasChanged()
    }

    /**
     Create or update a collection of Collectible instances.
     Upsert : insert + update

     - parameter instances: the instances
     */
    public func upsert(instances: [Collectible]){
        for instance in instances {
            self.upsert(instance)
        }
        self.hasChanged()
    }

    // MARK: read



    // MARK: delete

    /**
     Deletes the Collectible instance.

     - parameter instance: the instance

     */
    public func delete(instance: Collectible){
        if let collection=self.collectionByName(instance.d_collectionName) as? CollectibleCollection {
            collection.removeObject(instance, commit:false)
        }
        self.hasChanged()

    }

    /**
     Deletes a bunch of Collectible instance.

     - parameter instances: the instances
     */
    public func delete(instances: [Collectible]){
        for instance in instances {
            self.delete(instance)
        }
        self.hasChanged()
    }


    /**
     Deletes a Collectible instance by its UID

     - parameter instanceUID: the instance UID
     - parameter fromCollectionWithName : the collection name

     */
    public func deleteById(instanceUID: String, fromCollectionWithName: String) {

        if let collection=self.collectionByName(fromCollectionWithName) as? CollectibleCollection {
            collection.removeObjectWithID(instanceUID, commit:false)
        }
        self.hasChanged()
    }

    /**
     Deletes a Collectible instance by its UID

     - parameter instancesUIDs: an array of instances' UID
     - parameter fromCollectionWithName : the collection name

     */
    public func deleteByIds(instancesUIDs: [String], fromCollectionWithName: String){
        for instanceUID in instancesUIDs {
            self.deleteById(instanceUID, fromCollectionWithName: fromCollectionWithName)
        }
        self.hasChanged()
    }
    
}