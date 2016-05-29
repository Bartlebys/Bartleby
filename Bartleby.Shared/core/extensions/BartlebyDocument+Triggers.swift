//
//  BartlebyDocument+Triggers.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 05/05/2016.
//
//

import Foundation


extension BartlebyDocument {

    /*

     # Triggers Life Cycle

     OutGoing triggers are provisionned before transmission in document.triggers
     On successful transmission they are deleted (like operations)
     Received triggers are immediately executed and deleted (local execution is resilient to fault, faults are ignored)

     # CRUD on Triggers
     Normal Users can use the "Create" an "Read" on triggers "Update" and "Delete" are reserved to SuperAdmin and Iss

     # API

     + Trigger getTriggerSuccessors(spaceUID,lastIndex=-1) (ACL)
     + SSE /triggers/spaceUID/ (ACL)
     # SSE Encoding

     To insure good performance we encode the triggers for SSE usage.
     ```
     [<index>==-1,<senderUID>,<spaceUID>,<collectionName>,UID1, UID2,...]
     ```

     # Trigger.upserted or Trigger.deleted are also encoded

     ```
     //An array of String encoding [collectionName,UID1, UID2,...]
     public var upserted: [String] = [String]()
     //An array of String encoding [collectionName, UID1, UID2,...]
     public var deleted: [String] = [String]()
     ```

     On trigger incorporate a full bunch of consistent actions.
     You can encode a complete graph transformation within one trigger.

     # Why do we use Upsert ?

     Because triggered information are transformed to get operations.
     A new instance or an updated instance can be grabbed the same way.


     # Trigger.index
     The index is injected server side using a semaphore on insertion to guarantee its consistency.
     self.registryMetadata.triggersIndexes permitts to detect the data Holes


     */

    // MARK: -

    public func getTriggerAfter(lastIndex: Int) {
        // Grab all the triggers > lastIndex
        // AND Call triggersHasBeenReceived(...)



    }

    public func getTriggersForIndexes(set: Set<Int>) {
        // Grab the triggers for a given range.
        // And Call triggersHasBeenReceived(...)
    }



    public func analyzeConsistency() {
        // Check self.registryMetadata.triggersIndexes
        // If there are holes call getTriggersForIndexes()
        // PREVENT UNLIMITED LOOP ?
    }


    public func triggersHasBeenReceived(triggers: [Trigger]) {
        for trigger in triggers {
            if let _ = registryMetadata.triggersIndexes.indexOf(trigger.index) {
                // we have already integrated this trigger.
                // It is ours.
            } else {
                // Mark the trigger as Incoming
                trigger.direction = .Incoming
                self.triggers.add(trigger)


                // If the api is Reachable

                // We will integrate all the trigger even the trigger we have sent.
                // What about filterIN on user.Password?

                // Decode

                // Add to the GET_triggers taskGroup

                // 1. GET all The assets
                // 2. Upsert the Grabbed Instance and DELETE the assets.
                // 3. Call triggerHasBeenSent(..)
                // 4. Call analyzeConsistency()

                // Those operation are resilient
                // There is no transactionnal guarantees at all
                // Any exectution is conclusive and partial errors are ignored.

                // This approach is conflict free.

            }
        }
    }



    /**
     To be called when the trigger has been successufully sent.

     - parameter trigger: the outgoing trigger
     */
    public func triggerHasBeenSent(trigger: Trigger) {
        self.acknowledgeTrigger(trigger)
        self.delete(trigger)
    }

    /**
     Acknowledge the trigger permits to detect data holes

     - parameter trigger: the trigger
     */
    public func acknowledgeTrigger(trigger: Trigger) {
        if trigger.index>=0 {
            if registryMetadata.triggersIndexes.indexOf(trigger.index) == nil {
                self.registryMetadata.triggersIndexes.append(trigger.index)
            }
        } else {
            // Should never occur (Dev purposes)
            bprint("Trigger index is <0 \(trigger)", file: #file, function: #function, line: #line, category:bprintCategoryFor(trigger))
        }
    }

}
