//
//  PermissionsCollectionController.swift
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

// MARK: A  collection controller of "permissions"

// This controller implements data automation features.

@objc(PermissionsCollectionController) public class PermissionsCollectionController : JObject,IterableCollectibleCollection{

    // Universal type support
    override public class func typeName() -> String {
        return "PermissionsCollectionController"
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

    weak public var undoManager:NSUndoManager?

    #if os(OSX) && !USE_EMBEDDED_MODULES

    public weak var arrayController:NSArrayController?

    #endif

    weak public var tableView: BXTableView?

    public func generate() -> AnyGenerator<Permission> {
        var nextIndex = -1
        let limit=self.items.count-1
        return AnyGenerator {
            nextIndex += 1
            if (nextIndex > limit) {
                return nil
            }
            return self.items[nextIndex]
        }
    }


    public subscript(index: Int) -> Permission {
        return self.items[index]
    }

    public func itemAtIndex(index:Int)->Collectible{
        return self[index]
    }

    public var startIndex:Int {
        return 0
    }

    public var endIndex:Int {
        return self.items.count
    }

    public var count:Int {
        return self.items.count
    }

    public func indexOf(@noescape predicate: (Permission) throws -> Bool) rethrows -> Int?{
        return try self.items.indexOf(predicate)
    }

    public func indexOf(element: Permission) -> Int?{
		return self.items.indexOf(element)
    }


    /**
    An iterator that permit dynamic approaches.
    The Registry ignores the real types.
    - parameter on: the closure
    */
    public func superIterate(on:(element: Collectible)->()){
        for item in self.items {
            on(element:item)
        }
    }


    /**
    Commit all the changes in one bunch
    Marking commit on each item will toggle hasChanged flag.
    */
    public func commitChanges() -> [String] {
        var UIDS=[String]()
        let changedItems=self.items.filter { $0.toBeCommitted == true }
        bprint("\(changedItems.count) \( changedItems.count>1 ? "permissions" : "permission" )  has changed in PermissionsCollectionController",file:#file,function:#function,line:#line,category: Default.BPRINT_CATEGORY)
        for changed in changedItems{
            UIDS.append(changed.UID)
            UpdatePermission.commit(changed, inRegistryWithUID:self.registryUID)
        }
        return UIDS
    }

    required public init() {
        super.init()
    }


    dynamic public var items:[Permission]=[Permission](){
        didSet {
            if items != oldValue {
                self.provisionChanges(forKey: "items",oldValue: oldValue,newValue: items)
            }
        }
    }

    // MARK: Identifiable

    override public class var collectionName:String{
        return Permission.collectionName
    }

    override public var d_collectionName:String{
        return Permission.collectionName
    }



    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
        self.disableSupervisionAndCommit()
		self.items <- ( map["items"] )
		
        if map.mappingType == .FromJSON {
            forEach { $0.collection=self }
        }
        self.enableSuperVisionAndCommit()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.disableSupervisionAndCommit()
		self.items=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),Permission.classForCoder()]), forKey: "items")! as! [Permission]
		
		forEach { $0.collection=self }

        self.enableSuperVisionAndCommit()
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		coder.encodeObject(self.items,forKey:"items")
    }


    override public class func supportsSecureCoding() -> Bool{
        return true
    }




    // MARK: Upsert

    public func upsert(item: Collectible, commit:Bool){

        if let idx=items.indexOf({return $0.UID == item.UID}){
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


    public func add(item:Collectible, commit:Bool){
        self.insertObject(item, inItemsAtIndex: items.count, commit:commit)
    }

    // MARK: Insert

    /**
    Inserts an object at a given index into the collection.

    - parameter item:   the item
    - parameter index:  the index in the collection (not the ArrayController arranged object)
    - parameter commit: should we commit the insertion?
    */
    public func insertObject(item: Collectible, inItemsAtIndex index: Int, commit:Bool) {
        if let item=item as? Permission{

            item.collection = self // Reference the collection
            // Insert the item
            self.items.insert(item, atIndex: index)
            #if os(OSX) && !USE_EMBEDDED_MODULES
            if let arrayController = self.arrayController{

                // Re-sort (in case the user has sorted a column)
                arrayController.rearrangeObjects()

                // Get the sorted array
                let sorted = arrayController.arrangedObjects as! [Permission]

                if let tableView = self.tableView{
                    // Find the object just added
                    let row = sorted.indexOf(item)!
                    // Begin the edit in the first column
                    tableView.editColumn(0, row: row, withEvent: nil, select: true)
                 }

            }
            #endif


            if item.committed==false && commit==true{
               CreatePermission.commit(item, inRegistryWithUID:self.registryUID)
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
    public func removeObjectFromItemsAtIndex(index: Int, commit:Bool) {
        if let item : Permission = items[index] {

            // Unregister the item
            Registry.unRegister(item)

            //Update the commit flag
            item.committed=false

            // Remove the item from the collection
            self.items.removeAtIndex(index)

        
            if commit==true{
                DeletePermission.commit(item.UID,fromRegistryWithUID:self.registryUID) 
            }


        }
    }


    public func removeObjects(items: [Collectible],commit:Bool){
        for item in items{
            self.removeObject(item,commit:commit)
        }
    }

    public func removeObject(item: Collectible, commit:Bool){
        if let instance=item as? Permission{
            if let idx=self.indexOf( { return $0.UID == instance.UID } ){
                self.removeObjectFromItemsAtIndex(idx, commit:commit)
            }
        }
    }

    public func removeObjectWithIDS(ids: [String],commit:Bool){
        for uid in ids{
            self.removeObjectWithID(uid,commit:commit)
        }
    }

    public func removeObjectWithID(id:String, commit:Bool){
        if let idx=self.indexOf( { return $0.UID==id } ){
            self.removeObjectFromItemsAtIndex(idx, commit:commit)
        }
    }


    
}