//
//  ManagedBlocks.swift
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

public extension Notification.Name {
    public struct Blocks {
        /// Posted when the selected blocks changed
        public static let selectionChanged = Notification.Name(rawValue: "org.bartlebys.notification.Blocks.selectedBlocksChanged")
    }
}


// MARK: A  collection controller of "blocks"

// This controller implements data automation features.

@objc(ManagedBlocks) open class ManagedBlocks : ManagedModel,IterableCollectibleCollection{

    // Staged "blocks" identifiers (used to determine what should be committed on the next loop)
    fileprivate dynamic var _staged=[String]()

    // Store the  "blocks" identifiers to be deleted on the next loop
    fileprivate var _deleted=[String]()

    // Ordered UIDS
    fileprivate var _UIDS=[String]()

    // The underlining "blocks" list
    fileprivate dynamic var _items=[Block]()  {
        didSet {
            if !self.wantsQuietChanges && _items != oldValue {
                self.provisionChanges(forKey: "_items",oldValue: oldValue,newValue: _items)
            }
        }
    }

    // The underlining "blocks" storage
    fileprivate var _storage=[String:Block]()

    fileprivate func _rebuildFromStorage(){
        self._UIDS=[String]()
        self._items=[Block]()
        for (UID,item) in self._storage{
            self._UIDS.append(UID)
            self._items.append(item)
        }
    }

    /// Marks that a collectible instance should be committed.
    ///
    /// - Parameter item: the collectible instance
    open func stage(_ item: Collectible){
        if !self._staged.contains(item.UID){
            self._staged.append(item.UID)
            self.shouldBeSaved = true
            self.referentDocument?.hasChanged()
        }
    }

    // Used to determine if the wrapper should be saved.
    open var shouldBeSaved:Bool=false

    // Universal type support
    override open class func typeName() -> String {
        return "ManagedBlocks"
    }

    open var spaceUID:String { return self.referentDocument?.spaceUID ?? Default.NO_UID }

    /// Init with prefetched content
    ///
    /// - parameter items: itels
    ///
    /// - returns: the instance
    required public init(items:[Block], within document:BartlebyDocument) {
        super.init()
        self.referentDocument = document
        for item in items{
            let UID=item.UID
            self._UIDS.append(UID)
            self._storage[UID]=item
            self._items=items
        }
    }

    required public init() {
        super.init()
    }

    // Should be called to propagate references (Collection, ReferentDocument, Owned relations)
    open func propagate(){
        #if BARTLEBY_CORE_DEBUG
        if self.referentDocument == nil{
            glog("Document Reference is nil during Propagation on ManagedBlocks", file: #file, function: #function, line: #line, category: Default.LOG_FAULT, decorative: false)
        }
        #endif
        for item in self{
            // Reference the collection
            item.collection=self
            // Re-build the own relation.
            item.ownedBy.forEach({ (ownerUID) in
                if let o = Bartleby.registredManagedModelByUID(ownerUID){
                    if !o.owns.contains(item.UID){
                        o.owns.append(item.UID)
                    }
                }else{
                    // If the owner is not already available defer the homologous ownership registration.
                    Bartleby.appendToDeferredOwnershipsList(item, ownerUID: ownerUID)
                }
            })
        }
    }

    open var undoManager:UndoManager? { return self.referentDocument?.undoManager }

    open func generate() -> AnyIterator<Block> {
        var nextIndex = -1
        let limit=self._storage.count-1
        return AnyIterator {
            nextIndex += 1
            if (nextIndex > limit) {
                return nil
            }
            let key=self._UIDS[nextIndex]
            return self._storage[key]
        }
    }


    open subscript(index: Int) -> Block {
        let key=self._UIDS[index]
        return self._storage[key]!
    }

    open var startIndex:Int {
        return 0
    }

    open var endIndex:Int {
        return self._UIDS.count
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
        return self._storage.count
    }

    open func indexOf(element:@escaping(Block) throws -> Bool) rethrows -> Int?{
        return self._getIndexOf(element as! Collectible)
    }

    open func item(at index:Int)->Collectible?{
        if index >= 0 && index < self._storage.count{
            return self[index]
        }else{
            self.referentDocument?.log("Index Error \(index)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
        }
        return nil
    }

    fileprivate func _getIndexOf(_ item:Collectible)->Int?{
        return self._UIDS.index(of: item.UID)
    }

    /**
    An iterator that permit dynamic approaches.
    - parameter on: the closure
    */
    open func superIterate(_ on:@escaping(_ element: Collectible)->()){
        for UID in self._UIDS {
            let item=self._storage[UID]!
            on(item)
        }
    }


    /// Commit all the staged changes and planned deletions.
    open func commitChanges(){
        if self._staged.count>0{
            var changedBlocks=[Block]()
            for itemUID in self._staged{
                if let o:Block = try? Bartleby.registredObjectByUID(itemUID){
                    changedBlocks.append(o)
                }
            }
			let tobeUpdated = changedBlocks.filter { $0.commitCounter > 0  }
			let toBeCreated = changedBlocks.filter { $0.commitCounter == 0 }
			if toBeCreated.count > 0 {
			    CreateBlocks.commit(toBeCreated, in:self.referentDocument!)
			}
			if tobeUpdated.count > 0 {
			    UpdateBlocks.commit(tobeUpdated, in:self.referentDocument!)
			}

            self.hasBeenCommitted()
            self._staged.removeAll()
        }
     
        if self._deleted.count > 0 {
            var toBeDeletedBlocks=[Block]()
            for itemUID in self._deleted{
                if let o:Block = try? Bartleby.registredObjectByUID(itemUID){
                    toBeDeletedBlocks.append(o)
                }
            }
            if toBeDeletedBlocks.count > 0 {
                DeleteBlocks.commit(toBeDeletedBlocks, from: self.referentDocument!)
                Bartleby.unRegister(toBeDeletedBlocks)
            }
            self._deleted.removeAll()
        }
    }

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
        exposed.append(contentsOf:["_storage","_staged"])
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
            case "_storage":
                if let casted=value as? [String:Block]{
                    self._storage=casted
                }
            case "_staged":
                if let casted=value as? [String]{
                    self._staged=casted
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
            case "_storage":
               return self._storage
            case "_staged":
               return self._staged
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
        self.quietChanges {
			self._storage <- ( map["_storage"] )
			self._staged <- ( map["_staged"] )
            self._deleted <- ( map["_deleted"] )
            if map.mappingType == MappingType.fromJSON{
                self._rebuildFromStorage()
            }
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.quietChanges {
            self._storage=decoder.decodeObject(of: [NSDictionary.classForCoder(),NSString.self,Block.classForCoder()], forKey: "_storage")! as! [String:Block]
			self._staged=decoder.decodeObject(of: [NSArray.classForCoder(),NSString.self], forKey: "_staged")! as! [String]
            self._deleted=decoder.decodeObject(of: [NSArray.classForCoder(),NSString.self], forKey: "_deleted")! as! [String]
            self._rebuildFromStorage()
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self._storage,forKey:"_storage")
		coder.encode(self._staged,forKey:"_staged")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

    // MARK: - Upsert


    open func upsert(_ item: Collectible, commit:Bool=true){
        do{
            if self._UIDS.contains(item.UID){
                // it is an update
                // we must patch it
                let currentInstance=_storage[item.UID]!
                if commit==false{
                    var catched:Error?
                    // When upserting from a trigger
                    // We do not want to produce Larsen effect on data.
                    // So we lock the auto commit observer before to merge
                    // And we unlock the autoCommit Observer after the merging.
                    currentInstance.doNotCommit {
                        do{
                            try currentInstance.mergeWith(item)
                        }catch{
                            catched=error
                        }
                    }
                    if catched != nil{
                        throw catched!
                    }
                }else{
                    try currentInstance.mergeWith(item)
                }
            }else{
                // It is a creation
                self.add(item, commit:commit)
            }
        }catch{
            self.referentDocument?.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
        }
        self.shouldBeSaved = true
    }

    // MARK: Add


    open func add(_ item:Collectible, commit:Bool=true){
        self.insertObject(item, inItemsAtIndex: _storage.count, commit:commit)
    }

    // MARK: Insert

    /**
    Inserts an object at a given index into the collection.

    - parameter item:   the item
    - parameter index:  the index in the collection (not the ArrayController arranged object)
    - parameter commit: should we commit the insertion?
    */
    open func insertObject(_ item: Collectible, inItemsAtIndex index: Int, commit:Bool=true) {
        if let item = item as? Block{
            item.collection = self
            self._UIDS.insert(item.UID, at: index)
            self._items.insert(item, at:index)
            self._storage[item.UID]=item

            if let undoManager = self.undoManager{
                // Has an edit occurred already in this event?
                if undoManager.groupingLevel > 0 {
                    // Close the last group
                    undoManager.endUndoGrouping()
                    // Open a new group
                    undoManager.beginUndoGrouping()
                }
            }

            // Add the inverse of this invocation to the undo stack
            if let undoManager: UndoManager = undoManager {
                (undoManager.prepare(withInvocationTarget: self) as AnyObject).removeObjectFromItemsAtIndex(index, commit:commit)
                if !undoManager.isUndoing {
                    undoManager.setActionName(NSLocalizedString("AddBlock", comment: "AddBlock undo action"))
                }
            }
                        #if os(OSX) && !USE_EMBEDDED_MODULES
            if let arrayController = self.arrayController{

                // Re-arrange (in case the user has sorted a column)
                arrayController.rearrangeObjects()
            }
            #endif


            if commit==true {
               CreateBlock.commit(item, in:self.referentDocument!)
            }
            self.shouldBeSaved = true
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

        // Add the inverse of this invocation to the undo stack
        if let undoManager: UndoManager = undoManager {
            // We don't want to introduce a retain cycle
            // But with the objc magic casting undoManager.prepareWithInvocationTarget(self) as? UsersManagedCollection fails
            // That's why we have added an registerUndo extension on UndoManager
            undoManager.registerUndo({ () -> Void in
               self.insertObject(item, inItemsAtIndex: index, commit:commit)
            })
            if !undoManager.isUndoing {
                undoManager.setActionName(NSLocalizedString("RemoveBlock", comment: "Remove Block undo action"))
            }
        }
        
        // Remove the item from the collection
        let UID=item.UID
        self._UIDS.remove(at: index)
        self._items.remove(at: index)
        self._storage.removeValue(forKey: UID)
        if let stagedIdx=self._staged.index(of: UID){
            self._staged.remove(at: stagedIdx)
        }
    
        if commit==true{
           self._deleted.append(UID)
        }
        self.shouldBeSaved = true
    }


    open func removeObjects(_ items: [Collectible],commit:Bool=true){
        for item in items{
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

    // MARK: Filter

    /// Create a filtered copy of a collectible collection
    ///
    /// - Parameter isIncluded: the filtering closure
    /// - Returns: the filtered Collection
    open func filteredCopy(_ isIncluded: (Collectible)-> Bool) -> CollectibleCollection{
        let filteredCollection=ManagedBlocks()
        for item in self._items{
            if isIncluded(item){
                filteredCollection._UIDS.append(item.UID)
                filteredCollection._storage[item.UID]=item
                filteredCollection._items.append(item)
            }
        }
        return filteredCollection
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
            //self.referentDocument?.setValue(self, forKey: "blocks")
            arrayController?.objectClass=Block.self
            arrayController?.entityName=Block.className()
            arrayController?.bind("content", to: self, withKeyPath: "_items", options: nil)
            // Add observer
            arrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .new, context: &self._KVOContext)
            if let indexes=self.referentDocument?.metadata.stateDictionary[self.selectedBlocksIndexesKey] as? [Int]{
                let indexesSet = NSMutableIndexSet()
                indexes.forEach{ indexesSet.add($0) }
                arrayController?.setSelectionIndexes(indexesSet as IndexSet)
             }
        }
    }

    // KVO on ArrayController selectionIndexes

    // Note :
    // If you use an ArrayController & Bartleby automation
    // to modify the current selection you should use the array controller
    // e.g: referentDocument.blocks.arrayController?.setSelectedObjects(blocks)
    // Do not use document.blocks.selectedBlocks=blocks

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
                    self.selectedBlocks=items
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
            Bartleby.syncOnMain {
                if let blocks = selectedBlocks {
                     let indexes:[Int]=blocks.map({ (block) -> Int in
                        return blocks.index(where:{ return $0.UID == block.UID })!
                    })
                    self.referentDocument?.metadata.stateDictionary[selectedBlocksIndexesKey]=indexes
                }else{
                    self.referentDocument?.metadata.stateDictionary[selectedBlocksIndexesKey]=[Int]()

                }
                NotificationCenter.default.post(name:NSNotification.Name.Blocks.selectionChanged, object: nil)
            }
        }
    }

    // A facility
    open var firstSelectedBlock:Block? { return self.selectedBlocks?.first }



}