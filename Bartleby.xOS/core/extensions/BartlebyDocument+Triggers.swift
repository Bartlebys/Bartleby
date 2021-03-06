//
//  BartlebyDocument+Triggers.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 05/05/2016.
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import Alamofire
#endif

/*

 This extension implements the logic that integrate consistently the data.

 Check the Data Sync Document for more informations.
 https://github.com/Bartlebys/Bartleby/blob/master/Documents/DataSynchronization.md

 */
extension BartlebyDocument {

    // MARK: - Triggers Receipts

    /**
     The trigger has been sent by a  Server Sent Event or received  by an EndPoint.

     - parameter triggers: the collection of Trigger
     */
    internal func _triggersHasBeenReceived(_ triggers:[Trigger]) {
        let nb=self.metadata.receivedTriggers.count
        for trigger in triggers{
            // We store the triggers index for debug history
            self.metadata.triggersIndexesDebugHistory.append(trigger.index)
            // We don't want to keep useless triggers that could be received during a divergence resolution.
            if trigger.index > self.metadata.lastIntegratedTriggerIndex &&
                !(self.metadata.receivedTriggers.contains(where: { trigger.index == $0.index})){
                self.metadata.receivedTriggers.append(trigger)
            }
        }

        if self.metadata.receivedTriggers.count > nb{
            // If some new trigger have been received, we sorte the receivedTrigger list
            self.metadata.receivedTriggers=self.metadata.receivedTriggers.sorted { (lTrigger, rTrigger) -> Bool in
                return lTrigger.index<rTrigger.index
            }
        }

        for trigger in triggers{
            let triggerMetrics=Metrics()
            triggerMetrics.streamOrientation = .downStream
            triggerMetrics.operationName = trigger.action + "SSE"
            let data = try? JSON.encoder.encode(trigger)
            let s = (data != nil ) ? (data!.optionalString(using: Default.STRING_ENCODING) ?? "") : ""
            triggerMetrics.httpContext = HTTPContext(code: 0, caller: "TriggerHasBeenReceived", relatedURL: self.sseURL, httpStatusCode: 0, responseString: s)
            triggerMetrics.httpContext!.responseString = ""
            // Not sure it is required...
            // To be controlled.
            if let payloads = trigger.payloads {
                for (idx , payload) in payloads.enumerated() {
                    triggerMetrics.httpContext!.responseString! += ((idx > 0) ? "," : "") + (payload.optionalString(using: Default.STRING_ENCODING) ?? Default.NO_MESSAGE)
                }
            }
            self.report(triggerMetrics)
        }

        self._integrateContiguousData()
    }


    // MARK: - Owned Operation Acknowledgment

    /// Called by the generative Operation layer on Owned Operations
    /// - parameter ack: the Acknowledgement object
    public func record(_ ack:Acknowledgment){

        self.metadata.triggersIndexesDebugHistory.append(ack.triggerIndex)
        self.metadata.ownedTriggersIndexes.append(ack.triggerIndex)

        if ack.triggerIndex == self.metadata.lastIntegratedTriggerIndex+1 {
            // This index is contigous.
            self.metadata.lastIntegratedTriggerIndex=ack.triggerIndex
            self._integrateContiguousData()
        }else{
            // There is possibly a divergence https://github.com/Bartlebys/Bartleby/issues/27
            // So we will load the triggers from the lastIntegratedTriggerIndex + 1
            let fromIndex=self.metadata.lastIntegratedTriggerIndex+1
            self.log("Trying to resolve possible divergences from index \(fromIndex)",file:#file,function:#function,line:#line,category:logsCategoryFor(Trigger.self),decorative:false)
            TriggersAfterIndex.execute(from:self.UID, index:fromIndex, sucessHandler: { (triggers) in
                self._triggersHasBeenReceived(triggers)
            }) { (context) in
                if context.httpStatusCode != 404{
                    // What to do on failure ?
                    self.log("Failure on Divergences resolution Attempt from index: \(fromIndex) \(context)",file:#file,function:#function,line:#line,category:logsCategoryFor(Trigger.self),decorative:false)
                }
            }
        }
    }



    /// Integrates contigous data
    fileprivate func _integrateContiguousData(){
        var toBeRemovedIndexes=[Int]()
        var idx=0

        for trigger in self.metadata.receivedTriggers{

            // Purge the out dated triggers
            if trigger.index < self.metadata.lastIntegratedTriggerIndex{
                toBeRemovedIndexes.append(idx)
                continue
            }

            // Integrate contigous triggers
            if trigger.index == (self.metadata.lastIntegratedTriggerIndex+1){
                self._integrate(trigger)
                toBeRemovedIndexes.append(idx)
            }else{
                break
            }
            idx += 1
        }

        // Remove the processed triggers.
        for idx in toBeRemovedIndexes.reversed(){
            self.metadata.receivedTriggers.remove(at: idx)
        }

        // QA check if we encounter data Holes.
        // If a trigger is missing try to fill the hole
        let missing=self._missingContiguousTriggersIndexes()
        if missing.count>0{
            let s=missing.map({"\($0)"})
            self.log("Trying to fill a data hole for index(es): \(s)",file:#file,function:#function,line:#line,category:logsCategoryFor(Trigger.self),decorative:false)
            TriggersForIndexes.execute(from: self.UID, indexes: missing, sucessHandler: { (triggers) in
                self._triggersHasBeenReceived(triggers)
            }) { (context) in
                if context.httpStatusCode != 404{
                    // What to do on failure ?
                    self.log("Failure on data all filling for index(es): \(s) \(context)",file:#file,function:#function,line:#line,category:logsCategoryFor(Trigger.self),decorative:false)
                }
            }
        }
    }



    /**
     Integrates the triggered data in the Document.
     This method is called on GlobalQueue.Main.get() queue

     - parameter triggeredData: the triggered data
     */
    fileprivate func _integrate(_ trigger:Trigger){

        for hook in self.triggerHooks{
            hook.triggerWillBeIntegrated(trigger: trigger)
        }

        // Integrate
        if trigger.action.contains("Delete") {
            // It is a deletion.
            let UIDS=trigger.UIDS.components(separatedBy: ",")
            self.deleteByIds(UIDS)
        }else{

            // it is a creation or an update
            // We gonna upsert in the collection
            if let dataPayloads=trigger.payloads,
                let collection = self.collectionByName(trigger.targetCollectionName){
                do {
                    for payload in dataPayloads{
                        let typeName = collection.collectedType.typeName()
                         // We need to cast the dynamic type to ManagedModel & BartlebyCollection (Collectible alone is not enough)
                        if let collectible = try self.dynamics.deserialize(typeName: typeName, data: payload, document: nil) as? ManagedModel & Collectible{
                             collection.upsert(collectible, commit:false)
                        }
                    }
                }catch{
                    self.log("Deserialization exception \(error)", file: #file, function: #function, line: #line, category: logsCategoryFor(Trigger.self), decorative: false)
                }
            }
        }
        self.metadata.lastIntegratedTriggerIndex=trigger.index

        for hook in self.triggerHooks{
            hook.triggerHasBeenIntegrated(trigger: trigger)
        }

    }



    // MARK: - Recovery methods

    /**

     This method is the ultimate to fix a blocked / corrupted data.
     It may be destructive.

     Fixes the last lastIntegratedTriggerIndex to the highest value.
     And integrates all the triggered data
     */
    public func forceDataIntegration(){

        // If some new trigger have been received, we sorte the receivedTrigger list
        self.metadata.receivedTriggers=self.metadata.receivedTriggers.sorted { (lTrigger, rTrigger) -> Bool in
            return lTrigger.index<rTrigger.index
        }

        for trigger  in self.metadata.receivedTriggers{
            self._integrate(trigger)
        }

        // Reinitialize
        // Set the lastIntegratedTriggerIndex to the highest possible value
        self.metadata.lastIntegratedTriggerIndex = self._maxTriggerIndex()
    }

    fileprivate func _maxTriggerIndex()->Int{
        let highestTriggerIndex:Int=self.metadata.receivedTriggers.last?.index ?? 0
        let higestOwned:Int=self.metadata.ownedTriggersIndexes.max() ?? 0
        return  max(highestTriggerIndex,higestOwned)
    }

    // MARK: - API triggers on demand

    /**
     Tries to load new triggers if some
     */
    public func loadNewTriggers() {

        // Grab all the triggers > lastIndex
        // TriggersAfterIndex
        // AND Call triggersHasBeenReceived(...)
        TriggersAfterIndex.execute(from:self.UID, index:self.metadata.lastIntegratedTriggerIndex, sucessHandler: { (triggers) in
            self._triggersHasBeenReceived(triggers)
        }) { (context) in
            // What to do on failure
        }
    }


    /**
     Returns missing contiguous indexes

     - returns:
     */
    fileprivate func _missingContiguousTriggersIndexes()->[Int]{
        var missingIndexes=[Int]()
        let nextIndexToBeIntegrated=self.metadata.lastIntegratedTriggerIndex+1
        let maxIndex=self._maxTriggerIndex()
        if nextIndexToBeIntegrated <= maxIndex{
            for index in  nextIndexToBeIntegrated ... maxIndex{
                if (!self.metadata.receivedTriggers.contains(where:{$0.index==index})) &&
                    !self.metadata.ownedTriggersIndexes.contains(index){
                    missingIndexes.append(index)
                }
            }
        }

        return missingIndexes
    }



    // MARK: - Informations

    /**

     - returns: a bunch information on the current Buffer.
     */
    open func getTriggerBufferInformations()->String{

        var informations = "\nLast integrated trigger Index: \(self.metadata.lastIntegratedTriggerIndex)\n"
        // Missing
        let missing=self._missingContiguousTriggersIndexes()
        informations += missing.reduce("Missing indexes to insure continuity (\(missing.count)): ", { (string, index) -> String in
            return "\(string) \(index)"
        })
        informations += "\n"


        // Data buffer
        informations += "\n"
        informations += "Triggers to be integrated (\(self.metadata.receivedTriggers.count)):\n"
        for trigger in self.metadata.receivedTriggers {
            if let data = try? JSON.prettyEncoder.encode(trigger){
                if let s = data.optionalString(using: Default.STRING_ENCODING){
                    let n = s.count// We can  the trigger envelop.
                    informations += "\(trigger.index) [\(n) Bytes] \(trigger.action) \(trigger.origin ?? "" ) \(trigger.UIDS)\n"
                }
            }
        }

        // Owned Indexes
        informations += "\n"
        let ownedTriggersIndexes=self.metadata.ownedTriggersIndexes
        informations += "Owned Indexes (\(ownedTriggersIndexes.count)): "
        informations += ownedTriggersIndexes.reduce("", { (string, index) -> String in
            return "\(string) \(index)"
        })

        if (self.metadata.debugTriggersHistory) {
            // Owned Indexes
            informations += "\n\n"
            let history=self.metadata.triggersIndexesDebugHistory
            informations += "History Triggers Indexes (\(history.count)): "
            informations += history.reduce("", { (string, index) -> String in
                let owned=self.metadata.ownedTriggersIndexes.contains(index)
                return "\(string) \(owned ? "[":"")\(index)\(owned ? "]":"")"
            })
        }


        informations += "\n\n"
        informations += "-----------------------\n"
        informations += "Diagnostic:\n"
        informations += "\n"
        var noProblem=true

        // Trigger data That should be deleted

        var anomaliesTriggerDataThatShouldBeDeleted=[Int]()
        for trigger in self.metadata.receivedTriggers {
            if trigger.index <= self.metadata.lastIntegratedTriggerIndex{
                anomaliesTriggerDataThatShouldBeDeleted.append(trigger.index)
            }
        }
        let nba=anomaliesTriggerDataThatShouldBeDeleted.count

        if nba > 0{
            informations += "Nb Of trigger that should have been deleted :(\(anomaliesTriggerDataThatShouldBeDeleted.count))\n"

            for idx in anomaliesTriggerDataThatShouldBeDeleted.sorted(){
                informations += "\(idx) "
            }
            informations += "\n"
        }

        noProblem = (noProblem && (nba == 0 ))
        if noProblem{
            return  "**Everything is OK!**\n" + informations
        }else{
            return "**We have encountered issues please check the details below!**\n" + informations
        }
    }



    // MARK: - SSE

    /**
     Connect to SSE
     */
    internal func _connectToSSE() {
        self.log("SSE is transitioning online",file:#file,function:#function,line:#line,category: "SSE")
        // The connection is restricted to identified users
        // `PERMISSION_BY_IDENTIFICATION` the current user must be in the dataspace.
        self.currentUser.login(sucessHandler: {

            let headers=HTTPManager.httpHeadersWithToken(inDocumentWithUID: self.UID, withActionName: "SSETriggers")
            self._sse=EventSource(url:self.sseURL.absoluteString,headers:headers)

            self.log("Creating the event source instance: \(self.sseURL)",file:#file,function:#function,line:#line,category: "SSE")

            self._sse!.addEventListener("relay") { (id, event, data) in

                // Parse the Data

                /*

                 ```
                 id: 1466684879     <- the Event ID
                 event: relay       <- the Event Name
                 data: {            <- the data

                 "i":1,                                                     <- the trigger index
                 "o":"MkY2NzA4MUYtRDFGQi00Qjk0LTgyNzctNDUwQThDRjZGMDU3",    <- The observation UID
                 "r":"MzY5MDA4OTYtMDUxNS00MzdFLTgzOEEtNTQ1QjU4RDc4MEY3",    <- The run UID
                 "d": 0.0566778                                             <- The sseDbProcessingDuration
                 "s":"RjQ0QjU0NDMtMjE4OC00NEZBLUFFODgtRTA1MzlGN0FFMTVE",    <- The sender UID
                 "c":"users",                                               <- The collection name
                 "n":"CreateUser",                                          <- origin   : The action that have originated the trigger (optionnal)
                 "a":"ReadUserbyId",                                        <- action   : The action to be triggered
                 "u":"RjQ0QjU0NDMtMjE4OC00NEZBLUFFODgtRTA1MzlGN0FFMTVE"     <- the uids : The concerned UIDS
                 "p":"[]"                                                   <- the payloads : The payloads of the original operation
                 ```

                 */
                do {
                    if let dataFromString=data?.data(using: String.Encoding.utf8){
                        if let JSONDictionary = try JSONSerialization.jsonObject(with: dataFromString, options:.allowFragments) as? [String:Any] {
                            if  let index:Int=JSONDictionary["i"] as? Int,
                                let observationUID:String=JSONDictionary["o"] as? String,
                                let action:String=JSONDictionary["a"] as? String,
                                let collectionName=JSONDictionary["c"] as? String,
                                let uids=JSONDictionary["u"] as? String{

                                // Note that Payloads are void on Deletion.
                                let payloads=JSONDictionary["p"] as? [[String:Any]]

                                let trigger=Trigger()
                                trigger.spaceUID=self.spaceUID

                                // Mandatory Trigger Data
                                trigger.index=index
                                trigger.observationUID=observationUID
                                trigger.action=action
                                trigger.targetCollectionName=collectionName
                                trigger.UIDS=uids

                                // Payloads are void on Deletion
                                if let notVoidPayloads = payloads{
                                    //We transform the dictionary payload to Data
                                    let dataPayloads:[Data] = notVoidPayloads.map({ (dictionary) -> Data in
                                        do{
                                            return try JSONSerialization.data(withJSONObject: dictionary, options: [])
                                        }catch{
                                            self.log("\(error) on \(dictionary) ",category: "SSE")
                                            return Data()
                                        }
                                    })
                                    trigger.payloads = dataPayloads
                                }

                                // Optional data
                                // That may be omitted on triggering

                                if let sseDbProcessingDuration=JSONDictionary["d"] as? Double{
                                    trigger.sseDbProcessingDuration=sseDbProcessingDuration
                                }
                                trigger.runUID=JSONDictionary["r"] as? String
                                trigger.senderUID=JSONDictionary["s"] as? String
                                trigger.origin=JSONDictionary["n"] as? String

                                var triggers=[Trigger]()
                                triggers.append(trigger)
                                // Uses BartlebyDocument+Triggers extension.
                                self._triggersHasBeenReceived(triggers)
                            }
                        }
                    }
                    
                }catch{
                    self.log("Exception \(error) on \(String(describing: id)) \(String(describing: event)) \(String(describing: data))",file:#file,function:#function,line:#line,category: "SSE")
                }
            }
            
        }) { (context) in
            self.log("Login failed \(context)",file:#file,function:#function,line:#line,category: "SSE")
            self.metadata.online=false
        }
        
    }
    
    /**
     Closes the Server sent EventSource
     */
    internal func _closeSSE() {
        if let sse=self._sse{
            sse.close()
            self._sse=nil
        }
    }
}
