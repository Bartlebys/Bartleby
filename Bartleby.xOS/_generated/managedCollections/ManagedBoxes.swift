//
//  ManagedBoxes.swift
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
#endif

// MARK: - Notification

public extension Notification.Name {
    public struct Boxes {
        /// Posted when the selected boxes changed
        public static let selectionChanged = Notification.Name(rawValue: "org.bartlebys.notification.Boxes.selectedBoxesChanged")
    }
}


// MARK: A  collection controller of "boxes"

// This controller implements data automation features.

@objc open class ManagedBoxes : ManagedModel,IterableCollectibleCollection{

    open var collectedType:Collectible.Type { return Box.self }

    // Staged "boxes" identifiers (used to determine what should be committed on the next loop)
    fileprivate var _staged=[String]()

    // Store the  "boxes" identifiers to be deleted on the next loop
    fileprivate var _deleted=[String]()

    // Ordered UIDS
    fileprivate var _UIDS=[String]()

    // The "boxes" list (computed by _rebuildFromStorage and on operations)
    @objc fileprivate dynamic var _items=[Box]()  {
        didSet {
            if !self.wantsQuietChanges && _items != oldValue {
                self.provisionChanges(forKey: "_items",oldValue: oldValue,newValue: _items)
            }
        }
    }

    // The underlining "boxes" storage (serialized)
    // We cannot use the `Collected` generic type for _items and set `@objc dynamic` at the same time
    // `@objc dynamic` is required to be able to use KVO and `CocoaBindings`
    // May be we will stop using KVO and Cocoa Bindings in the future when Apple will give use alternative dynamic approach.
    // Refer to Apple documentation for more explanation.
    // https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/AdoptingCocoaDesignPatterns.html
    // So we use a strongly typed `Box for the storage
    // While the API deals with `Collectible` instances.
    fileprivate var _storage=[String:Box]()

    fileprivate func _rebuildFromStorage(){
        self._UIDS=[String]()
        self._items=[Box]()
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
        }
        // When operation off line The staging may have already occur in previous session.
        // So we need to mark shouldBeSaved even if the element is already staged
        self.shouldBeSaved = true
        self.referentDocument?.hasChanged()
    }

    /// Returns the collected items
    /// You should not normally use this method directly
    /// We use this to offer better performances during collection proxy deserialization phase
    /// This method may be removed in next versions
    /// - Returns: the collected items
    open func getItems()->[Collectible]{
        return self._items
    }

    // Used to determine if the wrapper should be saved.
    open var shouldBeSaved:Bool=false

    // Universal type support
    override open class func typeName() -> String {
        return "ManagedBoxes"
    }

    open var spaceUID:String { return self.referentDocument?.spaceUID ?? Default.NO_UID }

    /// Init with prefetched content
    ///
    /// - parameter items: itels
    ///
    /// - returns: the instance
    required public init(items:[Box], within document:BartlebyDocument) {
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
            glog("Document Reference is nil during Propagation on ManagedBoxes", file: #file, function: #function, line: #line, category: Default.LOG_FAULT, decorative: false)
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

    open func generate() -> AnyIterator<Box> {
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


    open subscript(index: Int) -> Box {
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

    open func indexOf(element:@escaping(Box) throws -> Bool) rethrows -> Int?{
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
            var changedBoxes=[Box]()
            for itemUID in self._staged{
                if let o:Box = try? Bartleby.registredObjectByUID(itemUID){
                    changedBoxes.append(o)
                }
            }
			let tobeUpdated = changedBoxes.filter { $0.commitCounter > 0  }
			let toBeCreated = changedBoxes.filter { $0.commitCounter == 0 }
			if toBeCreated.count > 0 {
			    CreateBoxes.commit(toBeCreated, in:self.referentDocument!)
			}
			if tobeUpdated.count > 0 {
			    UpdateBoxes.commit(tobeUpdated, in:self.referentDocument!)
			}

            self.hasBeenCommitted()
            self._staged.removeAll()
        }
     
        if self._deleted.count > 0 {
            var toBeDeletedBoxes=[Box]()
            for itemUID in self._deleted{
                if let o:Box = try? Bartleby.registredObjectByUID(itemUID){
                    toBeDeletedBoxes.append(o)
                }
            }
            if toBeDeletedBoxes.count > 0 {
                DeleteBoxes.commit(toBeDeletedBoxes, from: self.referentDocument!)
                Bartleby.unRegister(toBeDeletedBoxes)
            }
            self._deleted.removeAll()
        }
    }

    override open class var collectionName:String{
        return Box.collectionName
    }

    override open var d_collectionName:String{
        return Box.collectionName
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
                if let casted=value as? [String:Box]{
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





    
     // MARK: - Codable


    public enum CodingKeys: String,CodingKey{
		case _storage
		case _staged
		case _deleted
    }

    required public init(from decoder: Decoder) throws{
		try super.init(from: decoder)
        try self.quietThrowingChanges {
			let values = try decoder.container(keyedBy: CodingKeys.self)
			self._storage = try values.decode([String:Box].self,forKey:._storage)
			self._staged = try values.decode([String].self,forKey:._staged)
			self._deleted = try values.decode([String].self,forKey:._deleted)
			self._rebuildFromStorage()
        }
    }

    override open func encode(to encoder: Encoder) throws {
		try super.encode(to:encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self._storage,forKey:._storage)
		try container.encode(self._staged,forKey:._staged)
		try container.encode(self._deleted,forKey:._deleted)
    }
    


    // MARK: - Upsert


    /// Updates or creates an item
    ///
    /// - Parameters:
    ///   - item: the Box    ///   - commit: should we commit the `Upsertion`?
    /// - Returns: N/A
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
                self.add(item, commit:commit,isUndoable:false)
            }
        }catch{
            self.referentDocument?.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
        }
        self.shouldBeSaved = true
    }

    // MARK: Add

    /// Ads an Box    ///
    /// - Parameters:
    ///   - item: the Box    ///   - commit: should we commit the addition?
    ///   - isUndoable: is the addition reversible by the undo manager?
    /// - Returns: N/A
    open func add(_ item:Collectible, commit:Bool=true,isUndoable:Bool){
        self.insertObject(item, inItemsAtIndex: _storage.count, commit:commit,isUndoable:isUndoable)
    }


    /// Ads some items
    ///
    /// - Parameters:
    ///   - items: the collectible items to add
    ///   - commit: should we commit the additions?
    ///   - isUndoable: are the additions reversible by the undo manager?
    /// - Returns: N/A
    open func append(_ items:[Collectible],commit:Bool, isUndoable:Bool){
        if let items  = items as? [Box] {
            self._items.append(contentsOf:items)
            for item in items{
                item.collection = self
                self._UIDS.append(item.UID)
                self._storage[item.UID]=item
            }
            #if os(OSX) && !USE_EMBEDDED_MODULES
            if let arrayController = self.arrayController{
                // Re-arrange (in case the user has sorted a column)
                arrayController.rearrangeObjects()
            }
            #endif
  
            if isUndoable{
                // Add the inverse of this invocation to the undo stack
                if let undoManager: UndoManager = self.undoManager {
                    self.beginUndoGrouping()
                    undoManager.registerUndo(withTarget: self, handler: { (targetSelf) in
                        targetSelf.removeObjects(items, commit:commit)
                    })
                    if !undoManager.isUndoing {
                        undoManager.setActionName(NSLocalizedString("Add Box", comment: "AddBox undo action"))
                    }
                }
            }
            if commit==true {
               CreateBoxes.commit(items, in:self.referentDocument!)
            }

            self.shouldBeSaved = true
        }
    }



    // MARK: Insert

    ///  Insert an item at a given index.
    ///
    /// - Parameters:
    ///   - item: the collectible item
    ///   - index: the index
    ///   - commit: should we commit the addition?
    ///   - isUndoable: is the addition reversible by the undo manager?
    /// - Returns: N/A
    open func insertObject(_ item: Collectible, inItemsAtIndex index: Int, commit:Bool=true,isUndoable:Bool) {
        if let item = item as? Box{
            item.collection = self
            self._UIDS.insert(item.UID, at: index)
            self._items.insert(item, at:index)
            self._storage[item.UID]=item
  
            if isUndoable{
                // Add the inverse of this invocation to the undo stack
                if let undoManager: UndoManager = self.undoManager {
                    self.beginUndoGrouping()
                    undoManager.registerUndo(withTarget: self, handler: { (targetSelf) in
                        targetSelf.removeObjectWithID(item.UID, commit:commit)
                    })
                    if !undoManager.isUndoing {
                        undoManager.setActionName(NSLocalizedString("Add Box", comment: "AddBox undo action"))
                    }
                }
            }
            
            #if os(OSX) && !USE_EMBEDDED_MODULES
            if let arrayController = self.arrayController{
                // Re-arrange (in case the user has sorted a column)
                arrayController.rearrangeObjects()
            }
            #endif

            if commit==true {
               CreateBox.commit(item, in:self.referentDocument!)
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
        guard self._storage.count > index else {
            return
        }
        let item : Box =  self[index]

      // Add the inverse of this invocation to the undo stack
        if let undoManager: UndoManager = self.undoManager {
            self.beginUndoGrouping()
            // Add the inverse of this invocation to the undo stack
            let serializedData = item.serialize()
             undoManager.registerUndo(withTarget: self, handler: { (targetSelf) in
                targetSelf.addObjectFrom(serializedData)
             })
            if !undoManager.isUndoing {
                undoManager.setActionName(NSLocalizedString("Remove Box", comment: "Remove Box undo action"))
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

        #if os(OSX) && !USE_EMBEDDED_MODULES
            if let arrayController = self.arrayController{
                // Re-arrange (in case the user has sorted a column)
                arrayController.rearrangeObjects()
            }
        #endif

        try? item.erase()
        self.shouldBeSaved = true
    }

    /// Add an Object from an opaque serialized Data
    /// And registers the object into bartleby and its parent collection
    /// Used by the UndoManager.
    ///
    /// - Parameter data: the serialized Object
    open func addObjectFrom(_ data:Data){
        do{
            if let box:Box = try self.referentDocument?.serializer.deserialize(data,register:true){
                if let owners = Bartleby.registredManagedModelByUIDs(box.ownedBy){
                    for owner in owners{
                        // Re associate the relations.
                        if !owner.owns.contains(box.UID){
                            owner.owns.append(box.UID)
                        }
                    }
                }
                self.add(box, commit: true, isUndoable:false)
            }
        }catch{
            self.referentDocument?.log("\(error)")
        }
    }


    open func removeObjects(_ items: [Collectible],commit:Bool=true){
        for item in items{
            self.removeObject(item,commit:commit)
        }
    }

    open func removeObject(_ item: Collectible, commit:Bool=true){
        if let instance=item as? Box{
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
        let filteredCollection=ManagedBoxes()
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


#if os(OSX) && !USE_EMBEDDED_MODULES

    fileprivate var _KVOContext: Int = 0

    // We auto-configure most of the array controller.
    // And set up  indexes selection observation layer.
    open weak var arrayController:NSArrayController? {
        willSet{
        // Remove observer on previous array Controller
            arrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &self._KVOContext)
        }
        didSet{
            //self.referentDocument?.setValue(self, forKey: "boxes")
            arrayController?.objectClass=Box.self
            arrayController?.entityName=Box.className()
            arrayController?.bind(NSBindingName("content"), to: self, withKeyPath: "_items", options: nil)
            // Add observer
            arrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .new, context: &self._KVOContext)
            let indexesSet = NSMutableIndexSet()
            for instanceUID in self._selectedUIDS{
                if let idx = self._UIDS.index(of:instanceUID){
                    indexesSet.add(idx)
                }
            }
            arrayController?.setSelectionIndexes(indexesSet as IndexSet)

        }
    }

    // KVO on ArrayController selectionIndexes

    // Note :
    // If you use an ArrayController & Bartleby automation
    // to modify the current selection you should use the array controller
    // e.g: referentDocument.boxes.arrayController?.setSelectedObjects(boxes)
    // Do not use document.boxes.selectedBoxes=boxes

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &_KVOContext else {
            // If the context does not match, this message
            // must be intended for our superclass.
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if let keyPath = keyPath, let object = object {
            if keyPath=="selectionIndexes" &&  (object as? NSArrayController) == self.arrayController {
                if let items = self.arrayController?.selectedObjects as? [Box] {
                    self.selectedBoxes=items
                }
            }
        }
    }


    deinit{
        self.arrayController?.removeObserver(self, forKeyPath: "selectionIndexes")
    }

#endif


    fileprivate var _selectedUIDS:[String]{
        set{
            Bartleby.syncOnMain {
                if let boxes = self.selectedBoxes {
                    let _selectedUIDS:[String]=boxes.map({ (box) -> String in
                        return box.UID
                    })
                    self.referentDocument?.metadata.saveStateOf(_selectedUIDS, identified: self.selectedBoxesUIDSKeys)
                }
            }
        }
        get{
            return Bartleby.syncOnMainAndReturn{ () -> [String] in
                return self.referentDocument?.metadata.getStateOf(identified: self.selectedBoxesUIDSKeys) ?? [String]()
            }
        }
    }

    open let selectedBoxesUIDSKeys="selectedBoxesUIDSKeys"

    // Note :
    // If you use an ArrayController & Bartleby automation
    // to modify the current selection you should use the array controller
    // e.g: referentDocument.boxes.arrayController?.setSelectedObjects(boxes)
    @objc dynamic open var selectedBoxes:[Box]?{
        didSet{
            Bartleby.syncOnMain {
                if let boxes = selectedBoxes {
                    let UIDS:[String]=boxes.map({ (box) -> String in
                        return box.UID
                    })
                    self._selectedUIDS = UIDS
                }
                NotificationCenter.default.post(name:NSNotification.Name.Boxes.selectionChanged, object: nil)
            }
        }
    }

    // A facility
    open var firstSelectedBox:Box? { return self.selectedBoxes?.first }



}