//
//  ManagedCollection.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/12/2016.
//
//

import Foundation

//
//  ManagedTs.swift
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
    public struct Object {
        /// Posted when the selected tags changed
        public static let selectionChanged = Notification.Name(rawValue: "org.bartlebys.notification.Ts.selectedTsChanged")
    }
}

// MARK: A generic collectionController

// This controller implements data automation features.
open class ManagedCollection<T:Collectible,Equatable>: ManagedModel,Collection{

    // Used to determine if the wrapper should be saved.
    open var shouldBeSaved:Bool=false

    // Universal type support
    override open class func typeName() -> String {
        return "ManagedCollection"
    }

    open var spaceUID:String { return self.referentDocument?.spaceUID ?? Default.NO_UID }

    /// Init with prefetched content
    ///
    /// - parameter items: itels
    ///
    /// - returns: the instance
    required public init(items:[T], within document:BartlebyDocument) {
        super.init()
        self.referentDocument = document
        self._items = items
    }

    required public init() {
        super.init()
    }

    // Should be called to propagate the collection reference
    open func propagateCollection(){
        #if BARTLEBY_CORE_DEBUG
            if self.referentDocument == nil{
                glog("Document Reference is nil during Propagation on ManagedTs", file: #file, function: #function, line: #line, category: Default.LOG_FAULT, decorative: false)
            }
        #endif

        self.forEach {
            $0.collection = self
        }
    }

    open var undoManager:UndoManager? { return self.referentDocument?.undoManager }

    weak open var tableView: BXTableView?

    // The underling _items storage
    fileprivate var _items:[T]=[T](){
        didSet {
            /*
            if !self.wantsQuietChanges && _items != oldValue {
                self.provisionChanges(forKey: "_items",oldValue: oldValue,newValue: _items)
            }*/
        }
    }

    open func generate() -> AnyIterator<T> {
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


    open subscript(index: Int) -> T {
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

    open func indexOf(element:@escaping(T) throws -> Bool) rethrows -> Int?{
        return self._getIndexOf(element as! T)
    }

    open func item(at index:Int)->Collectible?{
        if index >= 0 && index < self._items.count{
            return self[index]
        }else{
            self.referentDocument?.log("Index Error \(index)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
        }
        return nil
    }

    fileprivate func _getIndexOf(_ item:T)->Int?{
        if item.collectedIndex >= 0 {
            return item.collectedIndex
        }else{
            if let idx=_items.index(where:{return $0.UID == item.UID}){
                var instance=self[idx]
                instance.collectedIndex = idx
                return idx
            }
        }
        return nil
    }

    fileprivate func _incrementIndexes(greaterThan lowerIndex:Int){
        let count = self._items.count
        if count > lowerIndex{
            for i in lowerIndex...count-1{
                var instance=self[i]
                instance.collectedIndex += 1
            }
        }
    }

    fileprivate func _decrementIndexes(greaterThan lowerIndex:Int){
        let count = self._items.count
        if count > lowerIndex{
            for i in lowerIndex...count-1{
                var instance=self[i]
                instance.collectedIndex -= 1
            }
        }
    }
    /**
     An iterator that permit dynamic approaches.
     - parameter on: the closure
     */
    open func superIterate(_ on:@escaping(_ element: T)->()){
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
            }
            let tobeUpdated = changedItems.filter { $0.commitCounter > 0  }
            let toBeCreated = changedItems.filter { $0.commitCounter == 0 }
            if toBeCreated.count > 0 {
                //CreateTs.commit(toBeCreated, in:self.referentDocument!)
            }
            if tobeUpdated.count > 0 {
               // UpdateTs.commit(tobeUpdated, in:self.referentDocument!)
            }

            self.hasBeenCommitted()
        }
        return UIDS
    }

    override open class var collectionName:String{
        return T.collectionName
    }

    override open var d_collectionName:String{
        return T.collectionName
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
            if let casted=value as? [T]{
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
        self.quietChanges {
            self._items <- ( map["_items"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.quietChanges {
            //self._items=decoder.decodeObject(of: [NSArray.classForCoder(),T.classForCoder()], forKey: "_items")! as! [T]
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
        coder.encode(self._items,forKey:"_items")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }


    // MARK: - Upsert


    open func upsert(_ item: T, commit:Bool=true){
        do{
            if let idx=_items.index(where:{return $0.UID == item.UID}){
                // it is an update
                // we must patch it
                let currentInstance=_items[idx]
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
    }

    // MARK: Add


    open func add(_ item:T, commit:Bool=true){
        self.insertObject(item, inItemsAtIndex: _items.count, commit:commit)
    }

    // MARK: Insert

    /**
     Inserts an object at a given index into the collection.

     - parameter item:   the item
     - parameter index:  the index in the collection (not the ArrayController arranged object)
     - parameter commit: should we commit the insertion?
     */
    open func insertObject(_ item: T, inItemsAtIndex index: Int, commit:Bool=true) {

            var item = item
            item.collectedIndex = index // Update the index
            item.collection = self as? CollectibleCollection
            self._incrementIndexes(greaterThan:index)


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
                // @ TODO
                /*
                (undoManager.prepare(withInvocationTarget: self) as AnyObject).removeObjectFromItemsAtIndex(index, commit:commit)
                if !undoManager.isUndoing {
                    undoManager.setActionName(NSLocalizedString("AddT", comment: "AddT undo action"))
                }
 */
            }
            // Insert the item
            self._items.insert(item, at: index)
            #if os(OSX) && !USE_EMBEDDED_MODULES
                if let arrayController = self.arrayController{

                    // Re-arrange (in case the user has sorted a column)
                    arrayController.rearrangeObjects()

                    if let tableView = self.tableView{
                        Async.main{
                            let sorted=self.arrayController?.arrangedObjects as! [T]
                            // Find the object just added
                            if let row=sorted.index(where:{ $0.UID==item.UID }){
                                // Start editing
                                tableView.editColumn(0, row: row, with: nil, select: true)
                            }
                        }
                    }
                }
            #endif


            if commit==true {
                //CreateT.commit(item, in:self.referentDocument!)
            }


    }




    // MARK: Remove

    /**
     Removes an object at a given index from the collection.

     - parameter index:  the index in the collection (not the ArrayController arranged object)
     - parameter commit: should we commit the removal?
     */
    open func removeObjectFromItemsAtIndex(_ index: Int, commit:Bool=true) {
        let item : T =  self[index]
        self._decrementIndexes(greaterThan:index)

        // Add the inverse of this invocation to the undo stack
        if let undoManager: UndoManager = undoManager {
            // We don't want to introduce a retain cycle
            // But with the objc magic casting undoManager.prepareWithInvocationTarget(self) as? UsersManagedCollection fails
            // That's why we have added an registerUndo extension on UndoManager
            undoManager.registerUndo({ () -> Void in
                self.insertObject(item, inItemsAtIndex: index, commit:commit)
            })
            if !undoManager.isUndoing {
                undoManager.setActionName(NSLocalizedString("RemoveT", comment: "Remove T undo action"))
            }
        }

        // Remove the item from the collection
        self._items.remove(at:index)


        if commit==true{
            //DeleteT.commit(item,from:self.referentDocument!)
        }
    }


    open func removeObjects(_ items: [T],commit:Bool=true){
        for item in items{
            self.removeObject(item,commit:commit)
        }
    }

    open func removeObject(_ item: T, commit:Bool=true){
        if let instance=item as? T{
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
            //self.referentDocument?.setValue(self, forKey: "tags")
            arrayController?.objectClass=T.self as! AnyClass
            arrayController?.entityName=T.typeName()
            arrayController?.bind("content", to: self, withKeyPath: "_items", options: nil)
            // Add observer
            arrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .new, context: &self._KVOContext)
            if let indexes=self.referentDocument?.metadata.stateDictionary[self.selectedTsIndexesKey] as? [Int]{
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
    // e.g: referentDocument.tags.arrayController?.setSelectedObjects(tags)
    // Do not use document.tags.selectedTs=tags

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &_KVOContext else {
            // If the context does not match, this message
            // must be intended for our superclass.
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if let keyPath = keyPath, let object = object {
            if keyPath=="selectionIndexes" &&  (object as? NSArrayController) == self.arrayController {
                if let items = self.arrayController?.selectedObjects as? [T] {
                    self.selectedTs=items
                }
            }
        }
    }


    deinit{
        self.arrayController?.removeObserver(self, forKeyPath: "selectionIndexes")
    }

    #endif

    open let selectedTsIndexesKey="selectedTsIndexesKey"
    
    open var selectedTs:[T]?{
        didSet{
            if let tags = selectedTs {
                let indexes:[Int]=tags.map({ (tag) -> Int in
                    return tags.index(where:{ return $0.UID == tag.UID })!
                })
                self.referentDocument?.metadata.stateDictionary[selectedTsIndexesKey]=indexes
                //NotificationCenter.default.post(name:NSNotification.Name.Ts.selectionChanged, object: nil)
            }
        }
    }
    
    // A facility
    open var firstSelectedT:T? { return self.selectedTs?.first }
    
    
    
}
