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

@objc(UsersCollectionController) public class UsersCollectionController : JObject,IterableCollectibleCollection{

    // Universal type support
    override public class func typeName() -> String {
        return "UsersCollectionController"
    }

    // Registry is referenced on Collection Proxy Creation.
    public var registry:BartlebyDocument?

    public var spaceUID:String {
        get{
            return self.registry?.spaceUID ?? Default.NO_UID
        }
    }

    public var registryUID:String{
        get{
            return self.registry?.UID ?? Default.NO_UID
        }
    }

    weak public var undoManager:UndoManager?

    #if os(OSX) && !USE_EMBEDDED_MODULES

    public weak var arrayController:NSArrayController?

    #endif

    weak public var tableView: BXTableView?

    public func generate() -> AnyIterator<User> {
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


    public subscript(index: Int) -> User? {
        return self.items[index]
    }

    public func itemAtIndex(_ index:Int)->Collectible?{
        return self[index]
    }

    public var startIndex:Int {
        return 0
    }

    public var endIndex:Int {
        return self.items.count
    }

    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return i+1
    }


    public var count:Int {
        return self.items.count
    }

    public func indexOf(predicate: (User) throws -> Bool) rethrows -> Int?{
        return try self.items.index(where:predicate)
    }

    public func indexOf(element: User) -> Int?{
        return self.items.index(where:{$0.UID==element.UID})
    }


    /**
    An iterator that permit dynamic approaches.
    The Registry ignores the real types.
    - parameter on: the closure
    */
    public func superIterate(_ on:@escaping(_ element: Collectible)->()){
        for item in self.items {
            on(item)
        }
    }


    /**
    Commit all the changes in one bunch
    Marking commit on each item will toggle hasChanged flag.
    */
    public func commitChanges() -> [String] {
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

    required public init() {
        super.init()
    }


    public dynamic var items:[User]=[User](){
        didSet {
            if items != oldValue {
                self.provisionChanges(forKey: "items",oldValue: oldValue,newValue: items)
            }
        }
    }

    // MARK: Identifiable

    override public class var collectionName:String{
        return User.collectionName
    }

    override public var d_collectionName:String{
        return User.collectionName
    }



    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override open func mapping(_ map: Map) {
        super.mapping(map)
        self.disableSupervisionAndCommit()
		self.items <- ( map["items"] )
		
        if map.mappingType == .fromJSON {
            forEach { $0?.collection=self }
        }
        self.enableSuperVisionAndCommit()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.disableSupervisionAndCommit()
		self.items=decoder.decodeObject(of: [User.classForCoder()], forKey: "items")! as! [User]
		
        self.disableSupervisionAndCommit()
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self.items,forKey:"items")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }




    // MARK: Upsert

    public func upsert(_ item: Collectible, commit:Bool){

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


    public func add(_ item:Collectible, commit:Bool){
        self.insertObject(item, inItemsAtIndex: items.count, commit:commit)
    }

    // MARK: Insert

    /**
    Inserts an object at a given index into the collection.

    - parameter item:   the item
    - parameter index:  the index in the collection (not the ArrayController arranged object)
    - parameter commit: should we commit the insertion?
    */
    public func insertObject(_ item: Collectible, inItemsAtIndex index: Int, commit:Bool) {
        if let item=item as? User{

            item.collection = self // Reference the collection

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
    public func removeObjectFromItemsAtIndex(_ index: Int, commit:Bool) {
        if let item : User =  self[index] {

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
    }


    public func removeObjects(_ items: [Collectible],commit:Bool){
        for item in self.items{
            self.removeObject(item,commit:commit)
        }
    }

    public func removeObject(_ item: Collectible, commit:Bool){
        if let instance=item as? User{
            if let idx=self.index(where: { return $0?.UID == instance.UID } ){
                self.removeObjectFromItemsAtIndex(idx, commit:commit)
            }
        }
    }

    public func removeObjectWithIDS(_ ids: [String],commit:Bool){
        for uid in ids{
            self.removeObjectWithID(uid,commit:commit)
        }
    }

    public func removeObjectWithID(_ id:String, commit:Bool){
        if let idx=self.index(where:{ return $0?.UID==id } ){
            self.removeObjectFromItemsAtIndex(idx, commit:commit)
        }
    }


    
}