//
//  UsersCollectionController.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for b@bartlebys.org
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  Bartleby's | https://bartlebys.org  All rights reserved.
//
import Foundation
#if os(OSX)
import AppKit
#endif
#if !USE_EMBEDDED_MODULES
import Alamofire
import ObjectMapper
#endif

// MARK: A  collection controller of "users"

// This controller implements data automation features.

@objc(UsersCollectionController) open class UsersCollectionController : JObject,IterableCollectibleCollection{

    // Universal type support
    override open class func typeName() -> String {
        return "UsersCollectionController"
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
    required public init(items:[User]) {
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
            self.document?.setValue(self, forKey: "users")
            arrayController?.objectClass=User.self
            arrayController?.entityName=User.className()
            arrayController?.bind("content", to: self, withKeyPath: "items", options: nil)
        }
    }

    #endif

    weak open var tableView: BXTableView?

    // The underling items storage
    fileprivate dynamic var items:[User]=[User](){
        didSet {
            if items != oldValue {
                self.provisionChanges(forKey: "items",oldValue: oldValue,newValue: items)
            }
        }
    }

    open func generate() -> AnyIterator<User> {
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


    open subscript(index: Int) -> User {
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

    open func indexOf(element:@escaping(User) throws -> Bool) rethrows -> Int?{
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
    Commit all the changes in one bunch
    Marking commit on each item will toggle hasChanged flag.
    */
    open func commitChanges() -> [String] {
        var UIDS=[String]()
        if self.toBeCommitted{ // When one member has to be committed its collection _shouldBeCommited flag is turned to true
            let changedItems=self.items.filter { $0.toBeCommitted == true }
            bprint("\(changedItems.count) \( changedItems.count>1 ? "users" : "user" )  has changed in UsersCollectionController",file:#file,function:#function,line:#line,category: Default.BPRINT_CATEGORY)
            for changed in changedItems{
                UIDS.append(changed.UID)
                UpdateUser.commit(changed, inRegistryWithUID:self.registryUID)
            }
            self.committed=true
        }
        return UIDS
    }

    // MARK: Identifiable

    override open class var collectionName:String{
        return User.collectionName
    }

    override open var d_collectionName:String{
        return User.collectionName
    }



    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override open func mapping(_ map: Map) {
        super.mapping(map)
        self.silentGroupedChanges {
			self.items <- ( map["items"] )
			
          if map.mappingType == .fromJSON {
                forEach { $0.collection=self }
            }
        }
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self.items=decoder.decodeObject(of: [NSArray.classForCoder(),User.classForCoder()], forKey: "items")! as! [User]
			
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
        if let item=item as? User{

            item.collection = self // Reference the collection
            item.collectedIndex = index // Update the index
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
                (undoManager.prepare(withInvocationTarget: self) as AnyObject).removeObjectFromItemsAtIndex(index, commit:commit)
                if !undoManager.isUndoing {
                    undoManager.setActionName(NSLocalizedString("AddUser", comment: "AddUser undo action"))
                }
            }
                        // Insert the item
            self.items.insert(item, at: index)
            #if os(OSX) && !USE_EMBEDDED_MODULES
            if let arrayController = self.arrayController{

                // Re-arrange (in case the user has sorted a column)
                arrayController.rearrangeObjects()

                if let tableView = self.tableView{
                    DispatchQueue.main.async(execute: {
                        let sorted=self.arrayController?.arrangedObjects as! [User]
                        // Find the object just added
                        if let row=sorted.index(where:{ $0.UID==item.UID }){
                            // Start editing
                            tableView.editColumn(0, row: row, with: nil, select: true)
                        }
                    })
                }
            }
            #endif


            if item.committed==false && commit==true{
               CreateUser.commit(item, inRegistryWithUID:self.registryUID)
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
    open func removeObjectFromItemsAtIndex(_ index: Int, commit:Bool) {
       let item : User =  self[index]
        self._decrementIndexes(greaterThan:index)

        // Add the inverse of this invocation to the undo stack
        if let undoManager: UndoManager = undoManager {
            // We don't want to introduce a retain cycle
            // But with the objc magic casting undoManager.prepareWithInvocationTarget(self) as? UsersCollectionController fails
            // That's why we have added an registerUndo extension on UndoManager
            undoManager.registerUndo({ () -> Void in
               self.insertObject(item, inItemsAtIndex: index, commit:commit)
            })
            if !undoManager.isUndoing {
                undoManager.setActionName(NSLocalizedString("RemoveUser", comment: "Remove User undo action"))
            }
        }
        
        // Unregister the item
        Registry.unRegister(item)

        //Update the commit flag
        item.committed=false

        // Remove the item from the collection
        self.items.remove(at:index)

    
        if commit==true{
            DeleteUser.commit(item.UID,fromRegistryWithUID:self.registryUID) 
        }
    }


    open func removeObjects(_ items: [Collectible],commit:Bool){
        for item in self.items{
            self.removeObject(item,commit:commit)
        }
    }

    open func removeObject(_ item: Collectible, commit:Bool){
        if let instance=item as? User{
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