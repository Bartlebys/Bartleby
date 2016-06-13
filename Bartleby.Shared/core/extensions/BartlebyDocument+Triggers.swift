//
//  BartlebyDocument+Triggers.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 05/05/2016.
//
//

import Foundation


extension BartlebyDocument {


    // MARK: - LifeCycle


    /*

     # Triggers Life Cycle

     OutGoing triggers are provisionned before transmission in document.triggers
     On successful transmission they are deleted (like operations)

     # The standard CRUD

     Most of the standard CRUD stack can be used only by SuperAdmins.
     The endpoints are blocked by server side ACL.

     ## Main API

     - TriggersByIds
     - TriggersAfterIndex
     - TriggersForIndexes


     # SSE Encoding

     To insure good performance we encode the triggers for SSE usage.
     ```
     id: 1464885108
     event: relay
     data: {"i":7,"s":"<sender UID>","a":"ReadUsers","u":"<user UID>, <user UID>"}

     ```

     # Trigger.upserted or Trigger.deleted are also encoded

     ```

     On trigger incorporate a full bunch of consistent actions.
     You can encode a complete graph transformation within one trigger.

     # Why do we use Upsert?

     Because triggered information are transformed to get operations.
     A new instance or an updated instance can be grabbed the same way.


     # Trigger.index

     The index is injected server side using a semaphore on insertion to guarantee its consistency.
     self.registryMetadata.triggersIndexes permitts to detect the data holes

     Consecutive Received triggers are immediately executed and deleted (local execution is resilient to fault, faults are ignored)
     If there are holes we try to fill the gap.

     */

    // MARK: - API

    public func getTriggerAfter(lastIndex: Int) {
        // Grab all the triggers > lastIndex
        // TriggersAfterIndex
        // AND Call triggersHasBeenReceived(...)



    }

    public func getTriggersForIndexes(set: Set<Int>) {
        // Grab the triggers for a given range.
        // TriggersForIndexes
        // And Call triggersHasBeenReceived(...)
    }


    /**
     Computes self.registryMetadata.triggersIndexesHoles
     */
    private func _analyzeConsistencyOfTriggerIndexes() {
        // Check self.registryMetadata.triggersIndexes
        // If there are holes call getTriggersForIndexes()
        // PREVENT UNLIMITED CALLS.

        let fromIndex =  self.registryMetadata.lastTriggerIndex >= 0 ? self.registryMetadata.lastTriggerIndex : 0
        let toIndex = self.registryMetadata.triggersIndexes.count-1
        if toIndex >= fromIndex{
            let lowestValidIndexValue = self.registryMetadata.triggersIndexes[fromIndex]
            var highestIndexValue = lowestValidIndexValue
            for i in fromIndex ... toIndex{
                let currentIndexValue = self.registryMetadata.triggersIndexes[i]
                if highestIndexValue < currentIndexValue{
                    highestIndexValue = currentIndexValue
                }
            }
            if highestIndexValue > (self.registryMetadata.triggersIndexes.count - 1) {
                // There is at least one hole.
                for value in lowestValidIndexValue ... highestIndexValue {
                    if !self.registryMetadata.triggersIndexes.contains(value){
                        if self.registryMetadata.triggersIndexesHoles.contains(value){
                            self.registryMetadata.triggersIndexesHoles.append(value)
                        }
                    }
                }
            }
        }
    }

    public func triggersHasBeenReceived(triggers: [Trigger]) {
        for trigger in triggers {
            if registryMetadata.triggersIndexes.contains(trigger.index) {
                // we have already integrated this trigger.
                // It is ours.
            } else {
                // Mark the trigger as Incoming
                // If the api is Reachable

                // We will integrate all the trigger even the trigger we have sent.
                // What about filterIN on user.Password?

                // Decode

                // Add to the GET_triggers taskGroup

                // 1. GET all The ressources
                // 2. Upsert the Grabbed Instance and DELETE the assets.
                // 4. Call analyzeConsistency()

                // Those operation are resilient
                // There is no transactionnal guarantees at all
                // Any exectution is conclusive and partial errors are ignored.

                // This approach is conflict free.

            }
        }
    }


    /**
     Acknowledge the trigger permits to detect data holes

     - parameter transmit: the trigger
     */
    public func acknowledgeTrigger(trigger: Trigger) {
        self.acknowledgeTriggerIndex(trigger.index)
    }

    /**
     Acknowledge trigger index

     - parameter index: the index
     */
    public func acknowledgeTriggerIndex(index:Int) {
        if index>0{
            if !registryMetadata.triggersIndexes.contains(index) {
                bprint("Acknowledgement of trigger \(index)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger))
                self.registryMetadata.triggersIndexes.append(index)
                // if It was in a data hole removit.
                if let holeIdx=self.registryMetadata.triggersIndexesHoles.indexOf(index){
                    self.registryMetadata.triggersIndexesHoles.removeAtIndex(holeIdx)
                }
                // Proceed to Indexes Consistency Analysis.
                self._analyzeConsistencyOfTriggerIndexes()
            }
        }else{
            bprint("Trigger index is <0 \(index)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger))
        }
    }



}
