//
//  PushOperationsCollectionController.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for [Benoit Pereira da Silva] (https://pereira-da-silva.com/contact)
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  [Bartleby's org] (https://bartlebys.org)   All rights reserved.
//
import Foundation
#if os(OSX)
import AppKit
#endif
#if !USE_EMBEDDED_MODULES
import Alamofire
import ObjectMapper
#endif

// MARK: A  collection controller of "pushOperations"

// This controller implements data automation features.

@objc(PushOperationsCollectionController) open class PushOperationsCollectionController : JObject,IterableCollectibleCollection{

    // Universal type support
    override open class func typeName() -> String {
        return "PushOperationsCollectionController"
    }

    open var spaceUID:String {
        get{
            return self.document?.spaceUID ?? Default.NO_UID
        }
    }

    open var registryUID:String{
        get{
            return self.document?.UID ?? Default.NO_UID
        }
    }

    /// Init with prefetched content
    ///
    /// - parameter items: itels
    ///
    /// - returns: the instance
    required public init(items:[PushOperation]) {
        super.init()
        self.items=items
    }

    required public init() {
        super.init()
    }

    weak open var undoManager:UndoManager?

    #if os(OSX) && !USE_EMBEDDED_MODULES

    // We auto configure most of the array controller.
    open weak var arrayController:NSArrayController? {
        didSet{
            self.document?.setValue(self, forKey: "pushOperations")
            arrayController?.objectClass=PushOperation.self
            arrayController?.entityName=PushOperation.className()
            arrayController?.bind("content", to: self, withKeyPath: "items", options: nil)
        }
    }

    #endif

    weak open var tableView: BXTableView?

    // The underling items storage
    fileprivate dynamic var items:[PushOperation]=[PushOperation](){
        didSet {
            if items != oldValue {
                self.provisionChanges(forKey: "items",oldValue: oldValue,newValue: items)
            }
        }
    }

    open func generate() -> AnyIterator<PushOperation> {
        var nextIndex = -1
        let limit=self.items.count-1
        return AnyIterator {
            nextIndex += 1
            if (nextIndex > limit) {
                return nil
            }
            return self.items[nextIndex]
        }
    }


    open subscript(index: Int) -> PushOperation {
        return self.items[index]
    }

    open var startIndex:Int {
        return 0
    }

    open var endIndex:Int {
        return self.items.count
    }

    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    open func index(after i: Int) -> Int {
        return i+1
    }


    open var count:Int {
        return self.items.count
    }

    open func indexOf(element:@escaping(PushOperation) throws -> Bool) rethrows -> Int?{
        return self._getIndexOf(element as! Collectible)
    }

    open func item(at index:Int)->Collectible?{
        return self[index]
    }


    fileprivate func _getIndexOf(_ item:Collectible)->Int?{
        if item.collectedIndex >= 0 {
            return item.collectedIndex
        }else{
            if let idx=items.index(where:{return $0.UID == item.UID}){
                self[idx].collectedIndex=idx
                return idx
            }
        }
        return nil
    }

    fileprivate func _incrementIndexes(greaterThan lowerIndex:Int){
        let count=items.count
        if count > lowerIndex{
            for i in lowerIndex...count-1{
                self[i].collectedIndex += 1
            }
        }
    }

    fileprivate func _decrementIndexes(greaterThan lowerIndex:Int){
        let count=items.count
        if count > lowerIndex{
            for i in lowerIndex...count-1{
                self[i].collectedIndex -= 1
            }
        }
    }
    /**
    An iterator that permit dynamic approaches.
    The Registry ignores the real types.
    - parameter on: the closure
    */
    open func superIterate(_ on:@escaping(_ element: Collectible)->()){
        for item in self.items {
            on(item)
        }
    }



    /**
     Commit is ignored because
     Distant persistency is not allowed for PushOperation
    */
    open func commitChanges() ->[String] {
        return [String]()
    }
    

    // MARK: Identifiable

    override open class var collectionName:String{
        return PushOperation.collectionName
    }

    override open var d_collectionName:String{
        return PushOperation.collectionName
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["items"])
        return exposed
    }


    /// Set the value of the given key
    ///
    /// - parameter value: the value
    /// - parameter key:   the key
    ///
    /// - throws: throws JObjectExpositionError when the key is not exposed
    override open func setExposedValue(_ value:Any?, forKey key: String) throws {
        switch key {

            case "items":
                if let casted=value as? [PushOperation]{
                    self.items=casted
                }            default:
                try super.setExposedValue(value, forKey: key)
        }
    }


    /// Returns the value of an exposed key.
    ///
    /// - parameter key: the key
    ///
    /// - throws: throws JObjectExpositionError when the key is not exposed
    ///
    /// - returns: returns the value
    override open func getExposedValueForKey(_ key:String) throws -> Any?{
        switch key {

            case "items":
               return self.items            default:
                return try super.getExposedValueForKey(key)
        }
    }
    // MARK: - Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }

    override open func mapping(map: Map) {
        super.mapping(map: map)
        self.silentGroupedChanges {
			self.items <- ( map["items"] )
			
          if map.mappingType == .fromJSON {
                forEach { $0.collection=self }
            }
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self.items=decoder.decodeObject(of: [NSArray.classForCoder(),PushOperation.classForCoder()], forKey: "items")! as! [PushOperation]
			
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self.items,forKey:"items")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }


    // MARK: Upsert

    open func upsert(_ item: Collectible, commit:Bool){

        if let idx=items.index(where:{return $0.UID == item.UID}){
            // it is an update
            // we must patch it
            let currentInstance=items[idx]
            if commit==false{
                // When upserting from a trigger
                // We do not want to produce Larsen effect on data.
                // So we lock the auto commit observer before applying the patch
                // And we unlock the autoCommit Observer after the patch.
                currentInstance.disableAutoCommit()
            }

            let dictionary=item.dictionaryRepresentation()
            currentInstance.patchFrom(dictionary)
            if commit==false{
                currentInstance.enableAutoCommit()
            }
        }else{
            // It is a creation
            self.add(item, commit:commit)
        }
    }

    // MARK: Add


    open func add(_ item:Collectible, commit:Bool){
        self.insertObject(item, inItemsAtIndex: items.count, commit:commit)
    }

    // MARK: Insert

    /**
    Inserts an object at a given index into the collection.

    - parameter item:   the item
    - parameter index:  the index in the collection (not the ArrayController arranged object)
    - parameter commit: should we commit the insertion?
    */
    open func insertObject(_ item: Collectible, inItemsAtIndex index: Int, commit:Bool) {
        if let item=item as? PushOperation{

            item.collection = self // Reference the collection
            item.collectedIndex = index // Update the index
            self._incrementIndexes(greaterThan:index)

            // Insert the item
            self.items.insert(item, at: index)
            #if os(OSX) && !USE_EMBEDDED_MODULES
            if let arrayController = self.arrayController{

                // Re-arrange (in case the user has sorted a column)
                arrayController.rearrangeObjects()

                if let tableView = self.tableView{
                    DispatchQueue.main.async(execute: {
                        let sorted=self.arrayController?.arrangedObjects as! [PushOperation]
                        // Find the object just added
                        if let row=sorted.index(where:{ $0.UID==item.UID }){
                            // Start editing
                            tableView.editColumn(0, row: row, with: nil, select: true)
                        }
                    })
                }
            }
            #endif


            // Commit is ignored because
            // Distant persistency is not allowed for PushOperation
            
        }else{

        }
    }




    // MARK: Remove

    /**
    Removes an object at a given index from the collection.

    - parameter index:  the index in the collection (not the ArrayController arranged object)
    - parameter commit: should we commit the removal?
    */
    open func removeObjectFromItemsAtIndex(_ index: Int, commit:Bool) {
       let item : PushOperation =  self[index]
        self._decrementIndexes(greaterThan:index)

        // Unregister the item
        Registry.unRegister(item)

        //Update the commit flag
        item.committed=false

        // Remove the item from the collection
        self.items.remove(at:index)

    
        // Commit is ignored because
        // Distant persistency is not allowed for PushOperation
            }


    open func removeObjects(_ items: [Collectible],commit:Bool){
        for item in self.items{
            self.removeObject(item,commit:commit)
        }
    }

    open func removeObject(_ item: Collectible, commit:Bool){
        if let instance=item as? PushOperation{
            if let idx=self._getIndexOf(instance){
                self.removeObjectFromItemsAtIndex(idx, commit:commit)
            }
        }
    }

    open func removeObjectWithIDS(_ ids: [String],commit:Bool){
        for uid in ids{
            self.removeObjectWithID(uid,commit:commit)
        }
    }

    open func removeObjectWithID(_ id:String, commit:Bool){
        if let idx=self.index(where:{ return $0.UID==id } ){
            self.removeObjectFromItemsAtIndex(idx, commit:commit)
        }
    }

}