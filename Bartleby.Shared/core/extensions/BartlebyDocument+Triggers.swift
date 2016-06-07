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
     data: {"i":7,"s":"<sender UID>","a":"ReadUsers","i":"<user UID>, <user UID>"}

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


    // MARK: - SSE


    var sse:EventSource{
        get{
            if let SSE=self._SSE{
                return SSE
            }else{
                let baseUrl=Bartleby.sharedInstance.getCollaborationURLForSpaceUID(self.spaceUID)
                let lastIndex=0
                let stringURL=baseUrl.URLByAppendingPathComponent("SSETriggers/?spaceUID=\(self.spaceUID)&lastIndex=\(lastIndex)&showDetails==false").absoluteString
                let headers=HTTPManager.httpHeadersWithToken(inDataSpace: self.spaceUID, withActionName: "")
                self._SSE=EventSource(url:stringURL,headers:headers)
                return self._SSE!
            }
        }
    }



    public func connectToSSE() {
        self.sse.connect()
        self.sse.addEventListener("relay") { (id, event, data) in
           bprint("\(id) \(event) \(data)",file:#file,function:#function,line:#line,category: Default.BPRINT_CATEGORY)
            // ACKNOWLEDGE
        }
    }



    public func closeSSE() {
        self.sse.close()
        self._SSE=nil
    }


    public func reconnectSSE() -> () {
        self.closeSSE()
        self.connectToSSE()
    }

}
