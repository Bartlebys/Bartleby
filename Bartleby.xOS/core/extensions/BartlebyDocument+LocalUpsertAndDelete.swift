//
//  BartlebyDocument+LocalUpsertAndDelete.swift
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
    public func upsert(_ instance: Collectible){
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
    public func upsert(_ instances: [Collectible]){
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
    public func delete(_ instance: Collectible){
        do{
            try instance.erase(commit:false)
            self.hasChanged()
        }catch{
             glog("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_FAULT, decorative: false)
        }
    }

    /**
     Deletes a bunch of Collectible instance.

     - parameter instances: the instances
     */
    public func delete(_ instances: [Collectible]){
        for instance in instances {
            self.delete(instance)
        }
    }


    /**
     Deletes a Collectible instance by its UID

     - parameter instanceUID: the instance UID

     */
    public func deleteById(_ instanceUID: String){
        do{
            if let instance=Bartleby.registredManagedModelByUID(instanceUID){
                try instance.erase(commit:false)
            }
        }catch{
            glog("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_FAULT, decorative: false)
        }

    }

    /**
     Deletes a Collectible instance by its UID

     - parameter instancesUIDs: an array of instances' UID

     */
    public func deleteByIds(_ instancesUIDs: [String]){
        for instanceUID in instancesUIDs {
            self.deleteById(instanceUID)
        }
    }
    
}
