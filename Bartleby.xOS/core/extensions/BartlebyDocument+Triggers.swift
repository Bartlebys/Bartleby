//
//  BartlebyDocument+Triggers.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 05/05/2016.
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import Alamofire
    import ObjectMapper
#endif

/*

 This extension implements the logic that integrate consistently the data.

 Check the Data Sync Document for more informations.
 https://github.com/Bartlebys/Bartleby/blob/master/DataSynchronization.md

 */
extension BartlebyDocument {

    // MARK: - Triggers Receipts

    /**
     This is first step of the trigger life cycle.

     The Server Sent Event is decoded by the registry
     or the Triggers are received via an EndPoint.

     Then this method is called.

     - parameter triggers: the collection of Trigger
     */
    internal func _triggersHasBeenReceived(_ triggers:[Trigger]) {

        let indexes=triggers.map {$0.index}
        self.acknowledgeTriggerIndexes(indexes)


        // Proceed to loading or direct insertion of triggers.
        for trigger in triggers{
            if !self.registryMetadata.ownedTriggersIndexes.contains(trigger.index){
                self.registryMetadata.receivedTriggers.append(trigger)
            }else{
                bprint("Data larsen on \(trigger)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger.self))
            }
        }

        self.registryMetadata.receivedTriggers.sort { (lTrigger, rTrigger) -> Bool in
            return lTrigger.index<rTrigger.index
        }

        self._integrateContiguousData()

    }

    // MARK: - Triggers Indexes Acknowledgment


    /**
     Called by the generative Operation layer
     it permitts to discriminate owned triggers from external triggers.
     Owned triggers should not be loaded!

     - parameter index: the trigger index.
     */
    public func acknowledgeOwnedTriggerIndex(_ index:Int){
        if self.registryMetadata.triggersIndexes.contains(index) {
            bprint("Attempt to acknowledgeOwnedTriggerIndex more than once trigger with index: \(index)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger.self))
        }else{
            // We want ownedTriggersIndexes to be sorted
            self.registryMetadata.ownedTriggersIndexes.sort { (lIdx, rIdx) -> Bool in
                return lIdx<rIdx
            }
            self.registryMetadata.ownedTriggersIndexes.append(index)
            let indexes=[index]
            self.acknowledgeTriggerIndexes(indexes)
        }
        self._integrateContiguousData()
    }


    /**
     Acknowledges the triggers indexes

     - parameter indexes: the triggers indexes
     */
    public func acknowledgeTriggerIndexes(_ indexes:[Int]) {
        for index in indexes{
            if (self.registryMetadata.debugTriggersHistory) {
                registryMetadata.triggersIndexesDebugHistory.append(index)
            }
            if index>=0{
                if registryMetadata.triggersIndexes.contains(index) {
                    bprint("Attempt to acknowledgeTriggerIndex more than once trigger with index: \(index)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger.self))
                }else{
                    bprint("Acknowledgement of trigger \(index)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger.self))
                    self.registryMetadata.triggersIndexes.append(index)
                }
            }else{
                bprint("Trigger index is <0 \(index)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger.self))
            }
        }
    }



    // MARK: - Local Data Integration

    /**

     Integrates the data and re-computes: lastIntegratedTriggerIndex, triggersIndexes
     Continuity of triggers indexes is required to insure data consistency.

     */
    fileprivate func _integrateContiguousData(){

        // We proceed on the main queue
        //GlobalQueue.main.get().async {

        // #1 Integrate contigous data

        var lastIntegratedTriggerIndex=self.registryMetadata.lastIntegratedTriggerIndex
        for trigger  in self.registryMetadata.receivedTriggers{

            // Integrate continuous data
            if trigger.index == (lastIntegratedTriggerIndex+1)  || self.registryMetadata.ownedTriggersIndexes.contains(lastIntegratedTriggerIndex + 1){
                self._integrate(trigger)
                lastIntegratedTriggerIndex = trigger.index
            }
        }

        // #2 Verify the continuity with the currently ownedTriggersIndexes
        // ownedTriggersIndexes is sorted

        if  let maxOwnedTriggerIndex=self.registryMetadata.ownedTriggersIndexes.max(),
            let minOwnedTriggerIndex=self.registryMetadata.ownedTriggersIndexes.min(){
            if lastIntegratedTriggerIndex <= maxOwnedTriggerIndex{
                for index in minOwnedTriggerIndex...maxOwnedTriggerIndex{
                    if index == (lastIntegratedTriggerIndex+1) {
                        lastIntegratedTriggerIndex = index
                    }
                }
            }
        }

        // #3 setup the lastIntegratedTriggerIndex
        self.registryMetadata.lastIntegratedTriggerIndex=lastIntegratedTriggerIndex

        // #4 keep only the index > lastIntegratedTriggerIndex in triggersIndexes
        let filteredIndexes=self.registryMetadata.triggersIndexes.filter { $0>lastIntegratedTriggerIndex }
        self.registryMetadata.triggersIndexes=filteredIndexes

        // If necessary we grab the missing indexes
        self.grabMissingTriggerIndexes()
        // }

    }



    /**
     Integrates the triggered data in the registry.
     This method is called on GlobalQueue.Main.get() queue

     - parameter triggeredData: the triggered data
     */
    fileprivate func _integrate(_ trigger:Trigger){
        // Integrate
        if trigger.action.contains("Delete") {
            // It is a deletion.
            let UIDS=trigger.UIDS.components(separatedBy: ",")
            let collectionName=trigger.targetCollectionName
            self.deleteByIds(UIDS, fromCollectionWithName: collectionName)
        }else{
            // it is a creation or un update
            if let jsonDictionaries=trigger.payloads{
                var collectibleItems=[Collectible]()
                do {
                    for jsonDictionary in jsonDictionaries{
                        if let collectible = try Bartleby.defaultSerializer.deserializeFromDictionary(jsonDictionary) as? Collectible{
                            collectibleItems.append(collectible)
                        }
                    }
                    if collectibleItems.count>0{
                        self.upsert(collectibleItems)
                    }
                }catch{
                    bprint("Deserialization exception \(error)", file: #file, function: #function, line: #line, category: bprintCategoryFor(Trigger.self), decorative: false)
                }
            }
        }
        // Remove the trigger from the collection.
        if let idx=self.registryMetadata.receivedTriggers.index(of: trigger){
            self.registryMetadata.receivedTriggers.remove(at: idx)
        }
    }


    // MARK: -

    /**
     Did we integrate all the pending data ?
     - returns: Return true if all the triggers have been integrated
     */
    public func isDataUpToDate()->Bool{
        return (self.registryMetadata.receivedTriggers.count == 0 && self.missingContiguousTriggersIndexes().count==0)
    }


    /**
     Returns missing contiguous indexes

     - returns:
     */
    public func missingContiguousTriggersIndexes()->[Int]{
        var missingIndexes=[Int]()
        let triggersIndexes=self.registryMetadata.triggersIndexes
        let nextIndexToBeIntegrated=self.registryMetadata.lastIntegratedTriggerIndex+1
        if let maxIndex=triggersIndexes.max(){
            for index in  nextIndexToBeIntegrated ... maxIndex{
                if !triggersIndexes.contains(index){
                    missingIndexes.append(index)
                }
            }
        }
        return missingIndexes
    }



    // MARK: - Recovery methods

    /**
     This method tries to fill the gap
     */
    public func grabMissingTriggerIndexes(){
        let missingTriggersIndexes=self.missingContiguousTriggersIndexes()
        // Todo compute missingTriggersIndexes
        if missingTriggersIndexes.count>0{
            let s=missingTriggersIndexes.reduce("", { (string, index) -> String in
                return string + ",\(index) "
            })
            bprint("Grabbing missing trigger index \(s)",file:#file,function:#function,line:#line,category:"TriggerContinuity",decorative:false)
            TriggersForIndexes.execute(fromRegistryWithUID:self.UID, indexes:missingTriggersIndexes, sucessHandler: { (triggers) in
                let s=missingTriggersIndexes.reduce("", { (r,index) -> String in
                    return "\(r) \(index) "
                })
                bprint("Fault correction on reintegration of\(s)",file:#file,function:#function,line:#line,category:"TriggerContinuity",decorative:false)
                self._triggersHasBeenReceived(triggers)
            }) { (context) in
                bprint("Failure \(context)",file:#file,function:#function,line:#line,category:"TriggerContinuity",decorative:false)
            }
        }
    }

    /**

     This method is the ultimate to fix a blocked / corrupted data.
     It may be destructive.

     Fixes the last lastIntegratedTriggerIndex to the highest value.
     And integrates all the triggered data
     */
    public func forceDataIntegration(){
        for trigger  in self.registryMetadata.receivedTriggers{
            self._integrate(trigger)
        }
        // Reinitialize
        self.registryMetadata.triggersIndexes=[Int]()
        // Set the lastIntegratedTriggerIndex to the highest possible value
        let highestTriggerIndex:Int=self.registryMetadata.receivedTriggers.last?.index ?? 0
        let higestOwned:Int=self.registryMetadata.ownedTriggersIndexes.max() ?? 0
        self.registryMetadata.lastIntegratedTriggerIndex = max(highestTriggerIndex,higestOwned)

    }




    // MARK: - API triggers on demand

    /**
     Tries to load new triggers if some
     */
    public func loadNewTriggers() {

        // Grab all the triggers > lastIndex
        // TriggersAfterIndex
        // AND Call triggersHasBeenReceived(...)
        TriggersAfterIndex.execute(fromRegistryWithUID:self.UID, index:self.registryMetadata.lastIntegratedTriggerIndex, sucessHandler: { (triggers) in
            self._triggersHasBeenReceived(triggers)
        }) { (context) in
            // What to do on failure
        }
    }


    // MARK: - Tools (Called from inspector Menu)

    public func cleanUpOutDatedDataTriggers(){
        for t in  self.registryMetadata.receivedTriggers.reversed(){
            if t.index<=self.registryMetadata.lastIntegratedTriggerIndex{
                if let idx=self.registryMetadata.receivedTriggers.index(of: t){
                    self.registryMetadata.receivedTriggers.remove(at:idx)
                }
            }
        }
    }


    // MARK: - Informations

    /**

     - returns: a bunch information on the current Buffer.
     */
    open func getTriggerBufferInformations()->String{

        var informations = "\nLast integrated trigger Index: \(self.registryMetadata.lastIntegratedTriggerIndex)\n"
        // Missing
        let missing=self.missingContiguousTriggersIndexes()
        informations += missing.reduce("Missing indexes to insure continuity (\(missing.count)): ", { (string, index) -> String in
            return "\(string) \(index)"
        })
        informations += "\n"


        // Data buffer
        informations += "\n"
        informations += "Triggers to be integrated (\(self.registryMetadata.receivedTriggers.count)):\n"
        for trigger in self.registryMetadata.receivedTriggers {
            let s = trigger.serialize()
            let n = s.count // We can should the trigger envelop.
            informations += "\(trigger.index) [\(n) Bytes] \(trigger.action) \(trigger.origin ?? "" ) \(trigger.UIDS)\n"
        }

        // Owned Indexes
        informations += "\n"
        let ownedTriggersIndexes=self.registryMetadata.ownedTriggersIndexes
        informations += "Owned Indexes (\(ownedTriggersIndexes.count)): "
        informations += ownedTriggersIndexes.reduce("", { (string, index) -> String in
            return "\(string) \(index)"
        })

        if (self.registryMetadata.debugTriggersHistory) {
            // Owned Indexes
            informations += "\n\n"
            let history=self.registryMetadata.triggersIndexesDebugHistory
            informations += "History Triggers Indexes (\(history.count)): "
            informations += history.reduce("", { (string, index) -> String in
                let owned=self.registryMetadata.ownedTriggersIndexes.contains(index)
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
        for trigger in self.registryMetadata.receivedTriggers {
            if trigger.index <= self.registryMetadata.lastIntegratedTriggerIndex{
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

    // The online flag is driving the "connection" process
    // It connects to the SSE and starts the supervisionLoop
    override open var online:Bool{
        willSet{
            // Transition on line
            if newValue==true && online==false{
                self._connectToSSE()
            }
            // Transition off line
            if newValue==false && online==true{
                bprint("SSE is transitioning offline",file:#file,function:#function,line:#line,category: "SSE")
                self._closeSSE()
            }
            if newValue==online{
                bprint("Neutral online var setting",file:#file,function:#function,line:#line,category: "SSE")
            }
        }
        didSet{
            self.registryMetadata.online=online
            self.startSupervisionLoopIfNecessary()
        }
    }


    /**
     Connect to SSE
     */
    internal func _connectToSSE() {
        bprint("SSE is transitioning online",file:#file,function:#function,line:#line,category: "SSE")
        // The connection is restricted to identified users
        // `PERMISSION_BY_IDENTIFICATION` the current user must be in the dataspace.
        self.currentUser.login(sucessHandler: {

            let headers=HTTPManager.httpHeadersWithToken(inRegistryWithUID: self.UID, withActionName: "SSETriggers")
            self._sse=EventSource(url:self.sseURL.absoluteString,headers:headers)

            bprint("Creating the event source instance: \(self.sseURL)",file:#file,function:#function,line:#line,category: "SSE")

            self._sse!.addEventListener("relay") { (id, event, data) in
                bprint("\(id) \(event) \(data)",file:#file,function:#function,line:#line,category: "SSE")

                // Parse the Data

                /*

                 ```
                 id: 1466684879     <- the Event ID
                 event: relay       <- the Event Name
                 data: {            <- the data

                 "i":1,                                                     <- the trigger index
                 "o":"MkY2NzA4MUYtRDFGQi00Qjk0LTgyNzctNDUwQThDRjZGMDU3",    <- The observation UID
                 "r":"MzY5MDA4OTYtMDUxNS00MzdFLTgzOEEtNTQ1QjU4RDc4MEY3",    <- The run UID
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
                            bprint("\(JSONDictionary)",file:#file,function:#function,line:#line,category:DEFAULT_BPRINT_CATEGORY,decorative:false)
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
                                trigger.payloads=payloads

                                // Optional data
                                // That may be omitted on triggering

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
                    bprint("Exception \(error) on \(id) \(event) \(data)",file:#file,function:#function,line:#line,category: "SSE")
                }
            }
            
        }) { (context) in
            bprint("Login failed \(context)",file:#file,function:#function,line:#line,category: "SSE")
            self.registryMetadata.online=false
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
