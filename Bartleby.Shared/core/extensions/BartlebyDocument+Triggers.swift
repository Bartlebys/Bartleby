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

     The triggers are stored before transmission in document.triggers

     Triggers CRUD
     + Trigger getNewTrigger(minRank)


     Trigger.upserted or deleted encoding = [spaceUID,collectionName,UID1, UID2,...]
     SSE_Trigger encoding = [senderUID,index,spaceUID,collectionName,UID1, UID2,...]


     */



    public func triggerHasBeenReceived(trigger: Trigger) {
        self._receivedTriggersUID.append(trigger.UID)
    }

    public func triggerHasBeenSent(trigger: Trigger) {
        self._sentTriggersUID.append(trigger.UID)

    }

}
