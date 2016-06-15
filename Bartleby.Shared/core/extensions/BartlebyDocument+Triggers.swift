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


    /**
     Tries to load new triggers if some
     */
    public func loadNewTriggers() {

        // Grab all the triggers > lastIndex
        // TriggersAfterIndex
        // AND Call triggersHasBeenReceived(...)
        TriggersAfterIndex.execute(fromDataSpace: self.spaceUID, index:self.registryMetadata.lastIntegratedTriggerIndex, sucessHandler: { (triggers) in
                self._triggersHasBeenReceived(triggers)
            }) { (context) in

        }
    }

    /**
     Load  the pending triggers.

     - parameter indexes: the indexes.
     */
    public func loadPendingTriggers() {
        if self.registryMetadata.triggersIndexesToLoad.count>0{
            TriggersForIndexes.execute(fromDataSpace: self.spaceUID, indexes:self.registryMetadata.triggersIndexesToLoad, sucessHandler: { (triggers) in
                self._triggersHasBeenReceived(triggers)
            }) { (context) in
                // WHAT TO DO ?
            }
        }
    }


    // MARK: - Triggers Acknowledgement (indexes and data holes management)

    /**
     Acknowledge the trigger

     - parameter transmit: the trigger
     */
    public func acknowledgeTrigger(trigger: Trigger) {
        self.acknowledgeTriggerIndex(trigger.index)
    }

    /**
     Acknowledge the trigger permits to detect data holes

     - parameter transmit: the trigger
     */
    public func acknowledgeTriggers(triggers: [Trigger]) {
        let indexes=triggers.map {$0.index}
        self.acknowledgeTriggerIndexes(indexes)
    }


    /**
     Called by generative operation layer to discriminate owned triggers.

     - parameter index: the trigger index.
     */
    public func acknowledgeOwnedTriggerIndex(index:Int){
        // We always add the index. 
        // Double insertion could be checked for QA.
        self.registryMetadata.ownedTriggersIndexes.append(index)
        self.acknowledgeTriggerIndex(index)
    }

    /**
     Acknowledge trigger index

     - parameter index: the index
     */
    public func acknowledgeTriggerIndex(index:Int) {
        let indexes=[index]
        self.acknowledgeTriggerIndexes(indexes)
    }

    /**
    Acknowledges the triggers indexes

     - parameter indexes: the triggers indexes
     */
    public func acknowledgeTriggerIndexes(indexes:[Int]) {
        for index in indexes{
            if index>0{
                if !registryMetadata.triggersIndexes.contains(index) {
                    bprint("Acknowledgement of trigger \(index)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger))
                    self.registryMetadata.triggersIndexes.append(index)
                    if let holeIdx=self.registryMetadata.triggersIndexesToLoad.indexOf(index){
                        self.registryMetadata.triggersIndexesToLoad.removeAtIndex(holeIdx)
                    }
                }
            }else{
                bprint("Trigger index is <0 \(index)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger))
            }
        }
        // Proceed to Indexes Consistency Analysis.
        self._analyzeConsistencyOfTriggerIndexes()
    }


    /**
     Analyze the consistency of the indexes and Computes :
     - self.registryMetadata.triggersIndexesToLoad
     - self.registryMetadata.lastIntegrableTriggerIndex
     */
    private func _analyzeConsistencyOfTriggerIndexes() {
        let fromIndex =  self.registryMetadata.lastIntegratedTriggerIndex >= 0 ? self.registryMetadata.lastIntegratedTriggerIndex : 0
        let toIndex = self.registryMetadata.triggersIndexes.count-1
        if toIndex >= fromIndex{
            let lowestValidIndexValue = self.registryMetadata.triggersIndexes[fromIndex]
            var highestIndexValue = lowestValidIndexValue
            for i in fromIndex ... toIndex{
                let currentIndexValue = self.registryMetadata.triggersIndexes[i]
                if highestIndexValue < currentIndexValue{
                    highestIndexValue = currentIndexValue
                    self.registryMetadata.lastIntegrableTriggerIndex=currentIndexValue
                }
            }
            if highestIndexValue > (self.registryMetadata.triggersIndexes.count - 1) {
                // There is at least one hole.
                for value in lowestValidIndexValue ... highestIndexValue {
                    if !self.registryMetadata.triggersIndexes.contains(value){
                        if self.registryMetadata.triggersIndexesToLoad.contains(value){
                            self.registryMetadata.triggersIndexesToLoad.append(value)
                        }
                    }
                }
            }else{
                // There is no data hole.
            }
        }
    }



    // MARK: - Triggers storage

    private func _triggersHasBeenReceived(triggers:[Trigger]) {

        self.acknowledgeTriggers(triggers)
        self.registryMetadata.receivedTriggers.appendContentsOf(triggers)
        self.registryMetadata.receivedTriggers.sortInPlace { (lTrigger, rTrigger) -> Bool in
            return lTrigger.index<rTrigger.index
        }

        // Determine the integrable triggers

        let integrableIndexRange = self.registryMetadata.lastIntegratedTriggerIndex ... self.registryMetadata.lastIntegrableTriggerIndex
        let integrableTriggers = self.registryMetadata.receivedTriggers.filter { (trigger) -> Bool in
            return integrableIndexRange ~= trigger.index
        }
        self._loadDataFrom(integrableTriggers)
    }


    // MARK: - Data Loading


    private func _loadDataFrom(triggers: [Trigger]){
        for trigger in triggers{
            if !self.registryMetadata.ownedTriggersIndexes.contains(trigger.index){
                // Load data for un owned triggers only.
                self._loadDataFrom(trigger)
            }

        }
    }
    
    
    private func _loadDataFrom(trigger:Trigger){

    }



}