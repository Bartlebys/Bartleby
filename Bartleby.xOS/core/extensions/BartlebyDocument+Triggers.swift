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

 This extension implements the logic that loads and integrate consistently the data.
 Data from Consecutive Received triggers are integrated.

 We try to load the data as soon as possible.

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

        self.registryMetadata.receivedTriggers.append(contentsOf: triggers)
        self.registryMetadata.receivedTriggers.sort { (lTrigger, rTrigger) -> Bool in
            return lTrigger.index<rTrigger.index
        }

        // Proceed to loading or direct insertion of triggers.
        for trigger in triggers{
            if !self.registryMetadata.ownedTriggersIndexes.contains(trigger.index){
                if trigger.action.contains("Delete"){
                    // it is a destructive action.
                    self._triggeredDataBuffer[trigger]=[[String:AnyObject]]()
                }else{
                    // It is creation action
                    // Load data for un owned triggers only.
                    self._loadDataFrom(trigger)
                }
            }else{
                bprint("Data larsen on \(trigger)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger.self))
            }
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



    // MARK: - Triggers Data Loading

    /**
     Loads the data for the given trigger.

     - parameter trigger: the trigger.
     */
    fileprivate func _loadDataFrom(_ trigger:Trigger, doNotReactOnFault:Bool=false){

        let alreadyLoaded=self._triggeredDataBuffer.contains(where: { $0.0.index == trigger.index })
        if !alreadyLoaded {

            /////////////////////////
            // Request Interpreter
            ////////////////////////

            let uids = trigger.UIDS.components(separatedBy: ",")
            if (uids.count==0){
                bprint("Trigger interpretation issue uids are void! \(trigger)", file: #file, function: #function, line:#line , category: bprintCategoryFor(trigger), decorative: false)
                return
            }

            let multiple = uids.count > 1
            let action = trigger.action
            let entityName = Pluralization.singularize(trigger.targetCollectionName).lowercased()
            let baseURL = Bartleby.sharedInstance.getCollaborationURL(self.UID)
            var dictionary:Dictionary<String, Any>=[:]
            var pathURL = baseURL
            if !multiple{
                let UID=uids.first!
                pathURL = baseURL.appendingPathComponent("\(entityName)/\(UID)")
            }else{
                pathURL = baseURL.appendingPathComponent("\(entityName)")
                dictionary["ids"]=uids as AnyObject?
            }
            let urlRequest=HTTPManager.requestWithToken(inRegistryWithUID:self.UID,withActionName:action ,forMethod:"GET", and: pathURL)
            do {
                let r=try URLEncoding().encode(urlRequest,with:dictionary)
                request(r).validate().responseJSON(completionHandler: { (response) in

                    /////////////////////////
                    // Result Handling
                    ////////////////////////

                    let request=response.request
                    let result=response.result
                    let response=response.response

                    if result.isFailure {
                        if let statusCode=response?.statusCode {
                            if statusCode==404{
                                if !doNotReactOnFault{
                                    self._onRead404Fault(trigger)
                                }
                                return
                            }
                        }
                        // ERROR
                        bprint("Trigger failure \(request) \(result) \(response)", file: #file, function: #function, line:#line , category: bprintCategoryFor(trigger), decorative: false)

                    }else{
                        if let statusCode=response?.statusCode {
                            if 200...299 ~= statusCode {
                                // In case of concurrent loading we prefer to test again if the trigger as not been already loaded
                                let alreadyLoaded=self._triggeredDataBuffer.contains(where: { $0.0.index == trigger.index })
                                if !alreadyLoaded{
                                    if multiple{
                                        // upsert a collection
                                        if let dictionaries=result.value as? [[String : Any]]{
                                            self._triggeredDataBuffer[trigger]=dictionaries
                                        }
                                    }else{
                                        // Unique entity
                                        if let jsonDictionary=result.value as? [String : Any]{
                                            self._triggeredDataBuffer[trigger]=[jsonDictionary]
                                        }
                                    }
                                    self._integrateContiguousData()
                                }else{
                                    // ERROR
                                    bprint("Trigger error \(request) \(result) \(response)", file: #file, function: #function, line:#line , category: bprintCategoryFor(trigger), decorative: false)
                                }
                            }
                        }
                    }
                })
            }catch{

            }
        }
    }

    /// Implements the READ & UPDATE 404 fault logic
    /// Check : #17 https://github.com/Bartlebys/Bartleby/issues/17
    /// For detailled explanations.
    /// - parameter trigger: the trigger
    fileprivate func _onRead404Fault(_ trigger:Trigger){
        let UIDS=trigger.UIDS.components(separatedBy:",")
        /// We proceed for each UID.
        for UID in UIDS{
            if !self.registryMetadata.deletedUIDs.contains(UID){ // Call the EntityExistsById endPoints once.
                let baseURL = Bartleby.sharedInstance.getCollaborationURL(self.UID)
                let pathURL = baseURL.appendingPathComponent("exists")
                let dictionary:Dictionary<String, Any>=["id":UID]
                let urlRequest=HTTPManager.requestWithToken(inRegistryWithUID:self.UID,withActionName:"EntityExistsById" ,forMethod:"GET", and: pathURL)
                do {
                    let r=try URLEncoding().encode(urlRequest,with:dictionary)
                    request(r).validate().responseJSON(completionHandler: { (response) in
                        let result=response.result
                        let response=response.response
                        GlobalQueue.main.get().async {
                            if result.isFailure {
                                if let statusCode=response?.statusCode {
                                    if statusCode==404{
                                        // Every thing is ok for this UID
                                        // For performance purposes cache this reponse by adding the UID to the known deletedUIDs
                                        self.registryMetadata.deletedUIDs.append(UID)
                                        return
                                    }
                                }
                            }else{
                                if let statusCode=response?.statusCode {
                                    if 200...299 ~= statusCode {
                                        if let index=self.registryMetadata.deletedUIDs.index(of:UID){
                                            self.registryMetadata.deletedUIDs.remove(at: index)
                                        }
                                    }
                                }
                            }
                            if !self.registryMetadata.triggersQuarantine.contains(trigger){
                                // We were not in a 4O4 case
                                // It is not normal
                                // So let's put the trigger in Quarantine
                                self.registryMetadata.triggersQuarantine.append(trigger)
                            }
                        }

                    })
                }catch{
                    bprint("O, Read404Fault exception \(error)", file: #file, function: #function, line: #line, category: bprintCategoryFor(Trigger.self), decorative: false)
                }
            }
        }

        /// In any case we cleanup the trigger on 404 faults
        GlobalQueue.main.get().async {
            self._cleanUPTrigger(trigger)
        }
    }

    // MARK: - Local Data Integration

    /**

     Integrates the data and re-computes: lastIntegratedTriggerIndex, triggersIndexes
     Continuity of triggers indexes is required to insure data consistency.

     */
    fileprivate func _integrateContiguousData(){

        // @TODO this method uses a lot o resources.
        // It should  be optimized .
        // May be by using a [Int:(Trigger,data)] where the int is the index (sorted)
        // NEED TO BE QUALIFIED


        // We proceed on the main queue
        GlobalQueue.main.get().async {

            // #1 Sort the triggered data
            let sortedData=self._triggeredDataBuffer.sorted { (lEntry, rEntry) -> Bool in
                return lEntry.0.index < rEntry.0.index
            }

            // #2 Integrate contigous data

            var lastIntegratedTriggerIndex=self.registryMetadata.lastIntegratedTriggerIndex
            for data  in sortedData{
                let triggerIndex=data.0.index
                // Integrate continuous data
                if triggerIndex == (lastIntegratedTriggerIndex+1)  || self.registryMetadata.ownedTriggersIndexes.contains(lastIntegratedTriggerIndex + 1){
                    self._integrate(data)
                    lastIntegratedTriggerIndex = triggerIndex
                }
            }


            // #3 Verify the continuity with the currently ownedTriggersIndexes
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

            // #4 setup the lastIntegratedTriggerIndex
            self.registryMetadata.lastIntegratedTriggerIndex=lastIntegratedTriggerIndex

            // #5 keep only the index > lastIntegratedTriggerIndex in triggersIndexes
            let filteredIndexes=self.registryMetadata.triggersIndexes.filter { $0>lastIntegratedTriggerIndex }
            self.registryMetadata.triggersIndexes=filteredIndexes
        }
    }



    /**
     Integrates the triggered data in the registry.
     This method is called on GlobalQueue.Main.get() queue

     - parameter triggeredData: the triggered data
     */
    fileprivate func _integrate(_ triggeredData:(Trigger,[[String : Any]])){
        // Integrate
        if triggeredData.1.count==0 {
            // It is a deletion.
            let UIDS=triggeredData.0.UIDS.components(separatedBy: ",")
            let collectionName=triggeredData.0.targetCollectionName
            self.deleteByIds(UIDS, fromCollectionWithName: collectionName)
        }else{
            // it is a creation or un update
            let jsonDictionaries=triggeredData.1
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

        //Clean up the integrated Trigger
        self._cleanUPTrigger(triggeredData.0)
    }


    /// Removes the trigger from the buffer and received triggers.
    ///
    /// - parameter trigger: the trigger to cleanup
    fileprivate func _cleanUPTrigger(_ trigger:Trigger){
        // Remove the trigger from the collection.
        if let idx=self.registryMetadata.receivedTriggers.index(of: trigger){
            self.registryMetadata.receivedTriggers.remove(at: idx)
        }

        //CleanUp the triggerData
        if let idx=self._triggeredDataBuffer.index(where: { (data) -> Bool in
            return trigger.index == data.0.index
        }){
            // Remove the triggered data
            self._triggeredDataBuffer.remove(at: idx)
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
            TriggersForIndexes.execute(fromRegistryWithUID:self.UID, indexes:missingTriggersIndexes, sucessHandler: { (triggers) in
                self._triggersHasBeenReceived(triggers)
            }) { (context) in
                // What to do in case of failure.
                Bartleby.todo("What to do?", message: "From BartlebyDocument+Triggers.swift func grabMissingTriggerIndexes() line \(#line)")
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
        GlobalQueue.main.get().async {

            let sortedData=self._triggeredDataBuffer.sorted { (lEntry, rEntry) -> Bool in
                return lEntry.0.index < rEntry.0.index
            }
            for data  in sortedData{
                self._integrate(data)
            }

            
            // Reinitialize
            self.registryMetadata.triggersIndexes=[Int]()
            // Set the lastIntegratedTriggerIndex to the highest possible value
            let highestTriggerIndex:Int=self.registryMetadata.receivedTriggers.last?.index ?? 0
            let higestOwned:Int=self.registryMetadata.ownedTriggersIndexes.max() ?? 0
            self.registryMetadata.lastIntegratedTriggerIndex = max(highestTriggerIndex,higestOwned)

        }
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
        for (t,_) in  self._triggeredDataBuffer.reversed(){
            if t.index<=self.registryMetadata.lastIntegratedTriggerIndex{
                if let idx=self._triggeredDataBuffer.index(forKey: t){
                    self._triggeredDataBuffer.remove(at: idx)
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
        informations += missing.reduce("Missing indexes (\(missing.count)): ", { (string, index) -> String in
            return "\(string) \(index)"
        })
        informations += "\n"

        // TriggerIndexes
        let triggersIndexes=self.registryMetadata.triggersIndexes

        informations += "Trigger Indexes (\(triggersIndexes.count)): "
        informations += triggersIndexes.reduce("", { (string, index) -> String in
            return "\(string) \(index)"
        })
        informations += "\n"

        // Data buffer
        informations += "\n"
        informations += "Triggers to be integrated (\(self._triggeredDataBuffer.count)):\n"
        let sorted=self._triggeredDataBuffer.sorted { (l, r) -> Bool in
            return l.0.index > r.0.index
        }
        for (trigger,dictionary) in sorted {
            let s = try?JSONSerialization.data(withJSONObject: dictionary, options: [])
            let n = (s?.count ?? 0)
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
        for (t,_) in self._triggeredDataBuffer {
            if t.index <= self.registryMetadata.lastIntegratedTriggerIndex{
                anomaliesTriggerDataThatShouldBeDeleted.append(t.index)
            }
        }
        let nba=anomaliesTriggerDataThatShouldBeDeleted.count
        
        if nba > 0{
            informations += "Nb Of trigger Data that should have been deleted :(\(anomaliesTriggerDataThatShouldBeDeleted.count))\n"
            
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
    
} 
