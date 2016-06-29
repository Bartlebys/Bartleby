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
    internal func _triggersHasBeenReceived(triggers:[Trigger]) {

        let indexes=triggers.map {$0.index}
        self.acknowledgeTriggerIndexes(indexes)

        self.registryMetadata.receivedTriggers.appendContentsOf(triggers)
        self.registryMetadata.receivedTriggers.sortInPlace { (lTrigger, rTrigger) -> Bool in
            return lTrigger.index<rTrigger.index
        }

        // Proceed to loading or direct insertion of triggers.

        var shouldTryToIntegrateImmediatly=false
        for trigger in triggers{
            if !self.registryMetadata.ownedTriggersIndexes.contains(trigger.index){
                if trigger.action.contains("Delete"){
                    // it is a destructive action.
                    self._triggeredDataBuffer[trigger]=[[String:AnyObject]]()
                    shouldTryToIntegrateImmediatly=true
                }else{
                    // It is creation action
                    // Load data for un owned triggers only.
                    self._loadDataFrom(trigger)
                }
            }else{
                bprint("Data larsen on \(trigger)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger))
            }
        }

        if shouldTryToIntegrateImmediatly{
            self._integrateContiguousData()
        }
    }

    // MARK: - Triggers Indexes Acknowledgment


    /**
     Called by the generative Operation layer
     it permitts to discriminate owned triggers from external triggers.
     Owned triggers should not be loaded!

     - parameter index: the trigger index.
     */
    public func acknowledgeOwnedTriggerIndex(index:Int){
        if self.registryMetadata.triggersIndexes.contains(index) {
            bprint("Attempt to acknowledgeOwnedTriggerIndex more than once trigger with index: \(index)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger))
        }else{
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
    public func acknowledgeTriggerIndexes(indexes:[Int]) {
        for index in indexes{
            if index>=0{
                if registryMetadata.triggersIndexes.contains(index) {
                    bprint("Attempt to acknowledgeTriggerIndex more than once trigger with index: \(index)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger))
                }else{
                    bprint("Acknowledgement of trigger \(index)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger))
                    self.registryMetadata.triggersIndexes.append(index)
                }
            }else{
                bprint("Trigger index is <0 \(index)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger))
            }
        }
    }



    // MARK: - Triggers Data Loading

    /**
     Loads the data for the given trigger.

     - parameter trigger: the trigger.
     */
    private func _loadDataFrom(trigger:Trigger){

        let alreadyLoaded=self._triggeredDataBuffer.contains({ $0.0.index == trigger.index })
        if !alreadyLoaded {

            /////////////////////////
            // Request Interpreter
            ////////////////////////

            let uids = trigger.UIDS.componentsSeparatedByString(",")
            if (uids.count==0){
                bprint("Trigger interpretation issue uids are void! \(trigger)", file: #file, function: #function, line:#line , category: bprintCategoryFor(trigger), decorative: false)
                return
            }

            let multiple = uids.count > 1
            let action = trigger.action
            let entityName = Pluralization.singularize(trigger.collectionName).lowercaseString
            let baseURL = Bartleby.sharedInstance.getCollaborationURLForSpaceUID(self.spaceUID)
            var dictionary:Dictionary<String, AnyObject>=[:]
            var pathURL = baseURL
            if !multiple{
                let UID=uids.first!
                pathURL = baseURL.URLByAppendingPathComponent("\(entityName)/\(UID)")//("group/\(groupId)")
            }else{
                pathURL = baseURL.URLByAppendingPathComponent("\(entityName)")
                dictionary["ids"]=uids
            }
            let urlRequest=HTTPManager.mutableRequestWithToken(inDataSpace:spaceUID,withActionName:action ,forMethod:"GET", and: pathURL)
            let r:Request=request(ParameterEncoding.URL.encode(urlRequest, parameters: dictionary).0)

            r.responseJSON { (response) in

                /////////////////////////
                // Result Handling
                ////////////////////////

                let request=response.request
                let result=response.result
                let response=response.response

                if result.isFailure {
                    // ERROR
                    bprint("Trigger failure \(request) \(result) \(response)", file: #file, function: #function, line:#line , category: bprintCategoryFor(trigger), decorative: false)

                }else{
                    if let statusCode=response?.statusCode {
                        if 200...299 ~= statusCode {
                            // In case of concurrent loading we prefer to test again if the trigger as not been already loaded
                            let alreadyLoaded=self._triggeredDataBuffer.contains({ $0.0.index == trigger.index })
                            if !alreadyLoaded{
                                if multiple{
                                    // upsert a collection
                                    if let dictionaries=result.value as? [[String : AnyObject]]{

                                            self._triggeredDataBuffer[trigger]=dictionaries

                                    }
                                }else{
                                    // Unique entity
                                    if let jsonDictionary=result.value as? [String : AnyObject]{
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
            }
        }

    }

    // MARK: - Local Data Integration

    /**
     Integrates the data and re-computes: lastIntegratedTriggerIndex, triggersIndexes
     Continuity of triggers is required to insure data consistency.
     */
    private func _integrateContiguousData(){
        dispatch_async(GlobalQueue.Main.get()) {
            // Sort the triggered data
            let sortedData=self._triggeredDataBuffer.sort { (lEntry, rEntry) -> Bool in
                return lEntry.0.index < rEntry.0.index
            }

            // Integrate contigous data
            var lastIntegratedTriggerIndex=self.registryMetadata.lastIntegratedTriggerIndex
            for data  in sortedData{
                let triggerIndex=data.0.index
                // Integrate continuous data
                if triggerIndex == lastIntegratedTriggerIndex + 1  || self.registryMetadata.ownedTriggersIndexes.contains(lastIntegratedTriggerIndex + 1){
                    self._integrate(data)
                    lastIntegratedTriggerIndex += 1
                }else{
                    //bprint("Integration is currently suspended at \(data.0)", file: #file, function: #function, line: #line, category: bprintCategoryFor(Trigger), decorative: false)
                    break
                }
            }

            // Verify the continuity with currently ownedTriggersIndexes
            if  let  maxOwnedTriggerIndex=self.registryMetadata.ownedTriggersIndexes.maxElement(){

                if lastIntegratedTriggerIndex < maxOwnedTriggerIndex{
                    for index in lastIntegratedTriggerIndex...maxOwnedTriggerIndex{
                        if index == lastIntegratedTriggerIndex + 1{
                            lastIntegratedTriggerIndex += 1
                        }else{
                            break
                        }
                    }
                }
            }

            // Update the lastIntegratedTriggerIndex
            self.registryMetadata.lastIntegratedTriggerIndex=lastIntegratedTriggerIndex

            // Remove the integrated Indexes
            let filteredIndexes=self.registryMetadata.triggersIndexes.filter { $0>lastIntegratedTriggerIndex }
            self.registryMetadata.triggersIndexes=filteredIndexes
        }
    }



    /**
     Integrates the triggered data in the registry.
     This method is called on GlobalQueue.Main.get() queue

     - parameter triggeredData: the triggered data
     */
    private func _integrate(triggeredData:(Trigger,[[String : AnyObject]])){
        // Integrate
        if triggeredData.1.count==0 {
            // It is a deletion.
            let UIDS=triggeredData.0.UIDS.componentsSeparatedByString(",")
            let collectionName=Trigger.collectionName
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
                bprint("Deserialization exception \(error)", file: #file, function: #function, line: #line, category: bprintCategoryFor(Trigger), decorative: false)
            }
        }

        // Remove the trigger from the collection.
        if let idx=self.registryMetadata.receivedTriggers.indexOf(triggeredData.0){
            self.registryMetadata.receivedTriggers.removeAtIndex(idx)
        }

        //CleanUp the triggerData
        if let idx=self._triggeredDataBuffer.indexOf({ (data) -> Bool in
            return triggeredData.0.index == data.0.index
        }){
            // Remove the triggered data
            self._triggeredDataBuffer.removeAtIndex(idx)
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
        if let maxIndex=triggersIndexes.maxElement(){
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
            TriggersForIndexes.execute(fromDataSpace: self.spaceUID, indexes:missingTriggersIndexes, ignoreHoles: true, sucessHandler: { (triggers) in
                self._triggersHasBeenReceived(triggers)
            }) { (context) in
                // What to do in case of failure.
                Bartleby.todo("What to do?", message: "")
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

        let sortedData=self._triggeredDataBuffer.sort { (lEntry, rEntry) -> Bool in
            return lEntry.0.index < rEntry.0.index
        }
        for data  in sortedData{
            self._integrate(data)
        }
        // Reinitialize
        self.registryMetadata.triggersIndexes=[Int]()

        // Set the lastIntegratedTriggerIndex to the highest possible value
        let highestTriggerIndex:Int=self.registryMetadata.receivedTriggers.last?.index ?? 0
        let higestOwned:Int=self.registryMetadata.ownedTriggersIndexes.maxElement() ?? 0
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
        TriggersAfterIndex.execute(fromDataSpace: self.spaceUID, index:self.registryMetadata.lastIntegratedTriggerIndex, sucessHandler: { (triggers) in
            self._triggersHasBeenReceived(triggers)
        }) { (context) in
            // What to do on failure
        }
    }

}