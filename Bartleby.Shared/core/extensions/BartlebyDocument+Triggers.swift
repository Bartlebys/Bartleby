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

 # Why do we always Upsert?

 Because triggered information are transformed to get operations.
 A new instance or an updated instance can be grabbed the same way.


 # Trigger.index

 The index is injected server side
 self.registryMetadata.triggersIndexes permits to detect the data holes

 Data from Consecutive Received triggers are immediately integrated (local execution is resilient to fault, faults are ignored)
 If there are holes we try to fill the gap.

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
                    self._triggeredData[trigger]=nil
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
            self._integrateContinuousPendingData()
        }
    }

    // MARK: - Triggers Indexes Acknowledgment


    /**
     Called by the generative Operation layer
     it permitts to discriminate owned triggers from external triggers.
     owned triggers should not be loaded.

     - parameter index: the trigger index.
     */
    public func acknowledgeOwnedTriggerIndex(index:Int){
        if !registryMetadata.triggersIndexes.contains(index) {
            self.registryMetadata.ownedTriggersIndexes.append(index)
            let indexes=[index]
            self.acknowledgeTriggerIndexes(indexes)
        }else{
            bprint("Attempt to acknowledgeOwnedTriggerIndex more than once trigger with index: \(index)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger))
        }
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
                    if let holeIdx=self.registryMetadata.missingTriggersIndexes.indexOf(index){
                        self.registryMetadata.missingTriggersIndexes.removeAtIndex(holeIdx)
                    }
                }else{
                    bprint("Attempt to acknowledgeTriggerIndex more than once trigger with index: \(index)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger))
                }
            }else{
                bprint("Trigger index is <0 \(index)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger))
            }
        }
        // Proceed to Indexes Consistency Analysis.
        self._analyzeConsistencyOfTriggerIndexes()
    }





    // MARK: - Triggers Data Loading

    /**
     Loads the data for the given trigger.

     - parameter trigger: the trigger.
     */
    private func _loadDataFrom(trigger:Trigger){

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

        let prototypeName = PString.ucfirst(entityName)
        guard let prototypeClass = NSClassFromString(prototypeName) else{
            bprint("Trigger interpretation prototype class not found \(prototypeName)", file: #file, function: #function, line:#line , category: bprintCategoryFor(trigger), decorative: false)
            return
        }
        guard let validatedPrototypeClass = prototypeClass as? Collectible.Type else{
            bprint("Trigger interpretation invalid prototype class \(prototypeName) should adopt protocol<Initializable,Mappable>", file: #file, function: #function, line:#line , category: bprintCategoryFor(trigger), decorative: false)
            return
        }

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

                        /**
                         Dynamic instantiation

                         - parameter jsonDictionary: a json Dictionary to apply on a dynamic Prototype

                         - returns: a optionnal Collectible instance
                         */
                        func __instantiate(from jsonDictionary:[String : AnyObject])->Collectible?{
                            let prototype=validatedPrototypeClass.init()
                            if var mappable=prototype as? Mappable{
                                let mapped=Map(mappingType: .FromJSON, JSONDictionary: jsonDictionary)
                                mappable.mapping(mapped)
                                return mappable as? Collectible
                            }
                            return nil
                        }

                        if multiple{
                            // upsert a collection
                            if let d=result.value as? [[String : AnyObject]]{
                                var instances=[Collectible]()
                                for jsonDictionary in d{
                                    if  let instance=__instantiate(from: jsonDictionary){
                                        instances.append(instance)
                                    }
                                }
                                self._dataReceivedFor(trigger, instances: instances)
                            }
                        }else{
                            // Unique entity
                            if let jsonDictionary=result.value as? [String : AnyObject]{
                                if let instance=__instantiate(from: jsonDictionary){
                                   self._dataReceivedFor(trigger, instances: [instance])
                                }
                            }
                        }
                    }else{
                        // ERROR
                        bprint("Trigger error \(request) \(result) \(response)", file: #file, function: #function, line:#line , category: bprintCategoryFor(trigger), decorative: false)
                    }
                }
            }
        }
    }

    // MARK: - Local Data Integration

    /**
     Called on data reception

     - parameter trigger:   the concerned trigger
     - parameter instances: the grabed instances.
     */
    private func _dataReceivedFor(trigger:Trigger,instances:[Collectible]){
        self._triggeredData[trigger]=instances
        self._integrateContinuousPendingData()
    }



    /**
     Integrates the loaded data of continous triggers
     Continuity of triggers is absolutely essential.
     */
    private func _integrateContinuousPendingData(){
        let sortedData=self._triggeredData.sort { (lEntry, rEntry) -> Bool in
            return lEntry.0.index < rEntry.0.index
        }
        for data  in sortedData{
            let triggerIndex=data.0.index
            // Integrate continuous data
            let nextIntegrableIndex=self.registryMetadata.lastIntegratedTriggerIndex+1
            if triggerIndex == nextIntegrableIndex{
                self._integrate(data)
            }else{
                bprint("Integration is currently suspended at \(data.0)", file: #file, function: #function, line: #line, category: bprintCategoryFor(Trigger), decorative: false)
                break
            }
        }
    }


    /**
     Integrates the triggered data in the registry.

     - parameter triggeredData: the triggered data
     */
    private func _integrate(triggeredData:(Trigger,[Collectible]?)){

        // Integrate
        if triggeredData.1 == nil {
            // It is a deletion.
            let UIDS=triggeredData.0.UIDS.componentsSeparatedByString(",")
            let collectionName=Trigger.collectionName
            self.deleteByIds(UIDS, fromCollectionWithName: collectionName)
        }else{
            // it is a creation or un update
            let collectibleItems=triggeredData.1!
            if collectibleItems.count>0{
                self.upsert(collectibleItems)
            }
        }

        // Update the last integrated trigger index.
        self.registryMetadata.lastIntegratedTriggerIndex=triggeredData.0.index
        // Remove the trigger from the collection.
        if let idx=self.registryMetadata.receivedTriggers.indexOf(triggeredData.0){
            self.registryMetadata.receivedTriggers.removeAtIndex(idx)
        }

        //CleanUp the triggerData
        if let idx=self._triggeredData.indexOf({ (data) -> Bool in
            return triggeredData.0.index == data.0.index
        }){
            // Remove the triggered data
            self._triggeredData.removeAtIndex(idx)
        }

    }


    // MARK: - Consistency


    /**
     Analyzes the consistency of the indexes and Computes :
     - self.registryMetadata.missingTriggersIndexes
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
                }
            }
            if highestIndexValue > (self.registryMetadata.triggersIndexes.count - 1) {
                // There is at least one hole.
                for value in lowestValidIndexValue ... highestIndexValue {
                    if !self.registryMetadata.triggersIndexes.contains(value){
                        if self.registryMetadata.missingTriggersIndexes.contains(value){
                            self.registryMetadata.missingTriggersIndexes.append(value)
                        }
                    }
                }
            }else{
                // There is no data hole.
            }
        }
    }


    /**
     Did we integrate all the pending data ?
     - returns: Return true if all the triggers have been integrated
     */
    public func isDataUpToDate()->Bool{
        return (self.registryMetadata.receivedTriggers.count == 0)
    }

    // MARK: - Recovery methods

    /**
     This method tries to fill the gap
     */
    public func grabMissingTriggerIndexes(){
        if self.registryMetadata.missingTriggersIndexes.count>0{
            TriggersForIndexes.execute(fromDataSpace: self.spaceUID, indexes:self.registryMetadata.missingTriggersIndexes, ignoreHoles: true, sucessHandler: { (triggers) in
                self._triggersHasBeenReceived(triggers)
            }) { (context) in
                // What to do in case of failure.
                Bartleby.todo("What to do?", message: "")
            }
        }
    }

    /**
    
     This method is the ultimate to fix a blocked / corrupted data.

     Fixes the last lastIntegratedTriggerIndex to the highest value.
     And integrates all the triggered data
     */
    public func forceDataIntegration(){
        if let highestTrigger=self.registryMetadata.receivedTriggers.last{
            self.registryMetadata.lastIntegratedTriggerIndex=highestTrigger.index
        }
        self.registryMetadata.missingTriggersIndexes=[Int]()

        let sortedData=self._triggeredData.sort { (lEntry, rEntry) -> Bool in
            return lEntry.0.index < rEntry.0.index
        }
        for data  in sortedData{
            self._integrate(data)
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
        TriggersAfterIndex.execute(fromDataSpace: self.spaceUID, index:self.registryMetadata.lastIntegratedTriggerIndex, sucessHandler: { (triggers) in
            self._triggersHasBeenReceived(triggers)
        }) { (context) in
            // What to do on failure
        }
    }

}