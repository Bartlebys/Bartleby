//
//  BlocksManagedCollection.swift
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

// MARK: - Notification

extension Notification.Name {
    public struct Blocks {
        /// Posted when the selected blocks changed
        public static let selectionChanged = Notification.Name(rawValue: "org.bartlebys.notification.Blocks.selectedblocksChanged")
    }
}


// MARK: A  collection controller of "blocks"

// This controller implements data automation features.

@objc(BlocksManagedCollection) open class BlocksManagedCollection : BartlebyObject,IterableCollectibleCollection{

    // Universal type support
    override open class func typeName() -> String {
        return "BlocksManagedCollection"
    }

    open var spaceUID:String {
        get{
            return self.document?.spaceUID ?? Default.NO_UID
        }
    }

    open var documentUID:String{
        get{
            return self.document?.UID ?? Default.NO_UID
        }
    }

    /// Init with prefetched content
    ///
    /// - parameter items: itels
    ///
    /// - returns: the instance
    required public init(items:[Block]) {
        super.init()
        self._items=items
    }

    required public init() {
        super.init()
    }

    weak open var undoManager:UndoManager?

    weak open var tableView: BXTableView?

    // The underling _items storage
    fileprivate dynamic var _items:[Block]=[Block](){
        didSet {
            if _items != oldValue {
                self.provisionChanges(forKey: "_items",oldValue: oldValue,newValue: _items)
            }
        }
    }

    open func generate() -> AnyIterator<Block> {
        var nextIndex = -1
        let limit=self._items.count-1
        return AnyIterator {
            nextIndex += 1
            if (nextIndex > limit) {
                return nil
            }
            return self._items[nextIndex]
        }
    }


    open subscript(index: Int) -> Block {
        return self._items[index]
    }

    open var startIndex:Int {
        return 0
    }

    open var endIndex:Int {
        return self._items.count
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
        return self._items.count
    }

    open func indexOf(element:@escaping(Block) throws -> Bool) rethrows -> Int?{
        return self._getIndexOf(element as! Collectible)
    }

    open func item(at index:Int)->Collectible?{
        return self[index]
    }


    fileprivate func _getIndexOf(_ item:Collectible)->Int?{
        if item.collectedIndex >= 0 {
            return item.collectedIndex
        }else{
            if let idx=_items.index(where:{return $0.UID == item.UID}){
                self[idx].collectedIndex=idx
                return idx
            }
        }
        return nil
    }

    fileprivate func _incrementIndexes(greaterThan lowerIndex:Int){
        let count=_items.count
        if count > lowerIndex{
            for i in lowerIndex...count-1{
                self[i].collectedIndex += 1
            }
        }
    }

    fileprivate func _decrementIndexes(greaterThan lowerIndex:Int){
        let count=_items.count
        if count > lowerIndex{
            for i in lowerIndex...count-1{
                self[i].collectedIndex -= 1
            }
        }
    }
    /**
    An iterator that permit dynamic approaches.
    - parameter on: the closure
    */
    open func superIterate(_ on:@escaping(_ element: Collectible)->()){
        for item in self._items {
            on(item)
        }
    }


    /**
    Commit all the changes in one bunch
    Marking commit on each item will toggle hasChanged flag.
    */
    open func commitChanges() -> [String] {
        var UIDS=[String]()
        if self.shouldBeCommitted{
            let changedItems=self._items.filter { $0.shouldBeCommitted == true }
            for changed in changedItems{
                UIDS.append(changed.UID)
				let tobeUpdated = changedItems.filter { $0.distributed == true }
				let toBeCreated = changedItems.filter { $0.distributed == false }
				if toBeCreated.count > 0 {
				    CreateBlocks.commit(toBeCreated, inDocumentWithUID:self.documentUID)
				}
				if tobeUpdated.count > 0 {
				    UpdateBlocks.commit(tobeUpdated, inDocumentWithUID:self.documentUID)
				}

            }
            self.committed=true
        }
        return UIDS
    }

    // MARK: Identifiable

    override open class var collectionName:String{
        return Block.collectionName
    }

    override open var d_collectionName:String{
        return Block.collectionName
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["_items"])
        return exposed
    }


    /// Set the value of the given key
    ///
    /// - parameter value: the value
    /// - parameter key:   the key
    ///
    /// - throws: throws an Exception when the key is not exposed
    override open func setExposedValue(_ value:Any?, forKey key: String) throws {
        switch key {
            case "_items":
                if let casted=value as? [Block]{
                    self._items=casted
                }
            default:
                return try super.setExposedValue(value, forKey: key)
        }
    }


    /// Returns the value of an exposed key.
    ///
    /// - parameter key: the key
    ///
    /// - throws: throws Exception when the key is not exposed
    ///
    /// - returns: returns the value
    override open func getExposedValueForKey(_ key:String) throws -> Any?{
        switch key {
            case "_items":
               return self._items
            default:
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
			self._items <- ( map["_items"] )

            if map.mappingType == .fromJSON {
               forEach { $0.collection=self }
            }
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self._items=decoder.decodeObject(of: [NSArray.classForCoder(),Block.classForCoder()], forKey: "_items")! as! [Block]
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self._items,forKey:"_items")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }


    // MARK: Upsert


    open func upsert(_ item: Collectible, commit:Bool=true){
        if let idx=_items.index(where:{return $0.UID == item.UID}){
            // it is an update
            // we must patch it
            let currentInstance=_items[idx]
            if commit==false{
                // When upserting from a trigger
                // We do not want to produce Larsen effect on data.
                // So we lock the auto commit observer before applying the patch
                // And we unlock the autoCommit Observer after the patch.
                currentInstance.doNotCommit {
                    try? currentInstance.mergeWith(item)
                }
            }else{
                try? currentInstance.mergeWith(item)
            }
        }else{
            // It is a creation
            self.add(item, commit:commit)
        }
    }

    // MARK: Add


    open func add(_ item:Collectible, commit:Bool=true){
        self.insertObject(item, inItemsAtIndex: _items.count, commit:commit)
    }

    // MARK: Insert

    /**
    Inserts an object at a given index into the collection.

    - parameter item:   the item
    - parameter index:  the index in the collection (not the ArrayController arranged object)
    - parameter commit: should we commit the insertion?
    */
    open func insertObject(_ item: Collectible, inItemsAtIndex index: Int, commit:Bool=true) {
        if let item=item as? Block{

            item.collection = self // Reference the collection
            item.collectedIndex = index // Update the index
            self._incrementIndexes(greaterThan:index)

            // Insert the item
            self._items.insert(item, at: index)
            #if os(OSX) && !USE_EMBEDDED_MODULES
            if let arrayController = self.arrayController{

                // Re-arrange (in case the user has sorted a column)
                arrayController.rearrangeObjects()

                if let tableView = self.tableView{
                    Async.main{
                        let sorted=self.arrayController?.arrangedObjects as! [Block]
                        // Find the object just added
                        if let row=sorted.index(where:{ $0.UID==item.UID }){
                            // Start editing
                            tableView.editColumn(0, row: row, with: nil, select: true)
                        }
                    }
                }
            }
            #endif


            if item.committed==false && commit==true {
               CreateBlock.commit(item, inDocumentWithUID:self.documentUID)
            }

        }else{

        }
    }




    // MARK: Remove

    /**
    Removes an object at a given index from the collection.

    - parameter index:  the index in the collection (not the ArrayController arranged object)
    - parameter commit: should we commit the removal?
    */
    open func removeObjectFromItemsAtIndex(_ index: Int, commit:Bool=true) {
       let item : Block =  self[index]
        self._decrementIndexes(greaterThan:index)

        // Unregister the item
        Bartleby.unRegister(item)

        //Update the commit flag
        item.committed=false

        // Remove the item from the collection
        self._items.remove(at:index)

    
        if commit==true{
            DeleteBlock.commit(item,from:self.documentUID) 
        }
    }


    open func removeObjects(_ _items: [Collectible],commit:Bool=true){
        for item in self._items{
            self.removeObject(item,commit:commit)
        }
    }

    open func removeObject(_ item: Collectible, commit:Bool=true){
        if let instance=item as? Block{
            if let idx=self._getIndexOf(instance){
                self.removeObjectFromItemsAtIndex(idx, commit:commit)
            }
        }
    }

    open func removeObjectWithIDS(_ ids: [String],commit:Bool=true){
        for uid in ids{
            self.removeObjectWithID(uid,commit:commit)
        }
    }

    open func removeObjectWithID(_ id:String, commit:Bool=true){
        if let idx=self.index(where:{ return $0.UID==id } ){
            self.removeObjectFromItemsAtIndex(idx, commit:commit)
        }
    }


    // MARK: - Selection management Facilities

    fileprivate var _KVOContext: Int = 0

#if os(OSX) && !USE_EMBEDDED_MODULES
    // We auto-configure most of the array controller.
    // And set up  indexes selection observation layer.
    open weak var arrayController:NSArrayController? {
        willSet{
        // Remove observer on previous array Controller
            arrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &self._KVOContext)
        }
        didSet{
            //self.document?.setValue(self, forKey: "blocks")
            arrayController?.objectClass=Block.self
            arrayController?.entityName=Block.className()
            arrayController?.bind("content", to: self, withKeyPath: "_items", options: nil)
            // Add observer
            arrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .new, context: &self._KVOContext)
            if let indexes=self.document?.metadata.stateDictionary[self.selectedBlocksIndexesKey] as? [Int]{
                let indexesSet = NSMutableIndexSet()
                indexes.forEach{ indexesSet.add($0) }
                arrayController?.setSelectionIndexes(indexesSet as IndexSet)
             }
        }
    }

    // KVO on ArrayController selectionIndexes

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &_KVOContext else {
            // If the context does not match, this message
            // must be intended for our superclass.
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if let keyPath = keyPath, let object = object {
            if keyPath=="selectionIndexes" &&  (object as? NSArrayController) == self.arrayController {
                if let items = self.arrayController?.selectedObjects as? [Block] {
                     if let selected = self.selectedBlocks{
                        if items.count == selected.count{
                            var noChanges=true
                            for item in items{
                              if !items.contains(where: { (instance) -> Bool in
                                    return instance.UID==item.UID
                                }){
                                    noChanges=false
                                    break
                                }
                            }
                            if noChanges==true{
                                return
                            }
                        }
                        self.selectedBlocks=items
                    }
                }
            }
        }
    }


    deinit{
        self.arrayController?.removeObserver(self, forKeyPath: "selectionIndexes")
    }

#endif

    open let selectedBlocksIndexesKey="selectedBlocksIndexesKey"

    dynamic open var selectedBlocks:[Block]?{
        didSet{
            if let blocks = selectedBlocks {
                 let indexes:[Int]=blocks.map({ (block) -> Int in
                    return blocks.index(where:{ return $0.UID == block.UID })!
                })
                self.document?.metadata.stateDictionary[selectedBlocksIndexesKey]=indexes
                NotificationCenter.default.post(name:NSNotification.Name.Blocks.selectionChanged, object: nil)
            }
        }
    }

    // A facility
    var firstSelectedBlock:Block? { return self.selectedBlocks?.first }



}