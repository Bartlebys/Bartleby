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

     + Trigger getTriggers(spaceUID,lastIndex=-1)
     + SSE /triggers/spaceUID/ (Auth required)

     # SSE Encoding

     To insure good performance we encode the triggers for SSE usage.
     ```
     [<index>==-1,<sessionUID>,<senderUID>,<spaceUID>,<collectionName>,UID1, UID2,...]
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

     */

    // MARK: Acknowledgement

    public func triggerHasBeenReceived(trigger: Trigger) {
        self._receivedTriggersUID.append(trigger.UID)
    }

    public func triggerHasBeenSent(trigger: Trigger) {
        self._sentTriggersUID.append(trigger.UID)

    }

}
