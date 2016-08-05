//
//  TasksCollectionController.swift
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

// MARK: A  collection controller of "tasks"

// This controller implements data automation features.

@objc(TasksCollectionController) public class TasksCollectionController : JObject,IterableCollectibleCollection{

    // Universal type support
    override public class func typeName() -> String {
        return "TasksCollectionController"
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

    public func generate() -> AnyGenerator<Task> {
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


    public subscript(index: Int) -> Task {
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

    /**
    An iterator that permit dynamic approaches.
    The Registry ignore the real types.
    Currently we do not use SequenceType, Subscript, ...

    - parameter on: the closure
    */
    public func superIterate(on:(element: Collectible)->()){
        for item in self.items {
            on(element:item)
        }
    }



    /**
     Commit is ignored because
     Distant persistency is not allowed for Task
    */
    public func commitChanges() ->[String] { 
        return [String]()
    }
    

    required public init() {
        super.init()
    }


    dynamic public var items:[Task]=[Task](){
        didSet {
            if items != oldValue {
                self.provisionChanges(forKey: "items",oldValue: oldValue,newValue: items)
            }
        }
    }

    // MARK: Identifiable

    override public class var collectionName:String{
        return Task.collectionName
    }

    override public var d_collectionName:String{
        return Task.collectionName
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
		self.items=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),Task.classForCoder()]), forKey: "items")! as! [Task]
		
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
        #if os(OSX) && !USE_EMBEDDED_MODULES
        if let arrayController = self.arrayController{
            self.insertObject(item, inItemsAtIndex: arrayController.arrangedObjects.count, commit:commit)
        }else{
            self.insertObject(item, inItemsAtIndex: items.count, commit:commit)
        }
        #else
        self.insertObject(item, inItemsAtIndex: items.count, commit:commit)
        #endif
    }

    // MARK: Insert

    public func insertObject(item: Collectible, inItemsAtIndex index: Int, commit:Bool) {
        if let item=item as? Task{

            item.collection = self // Reference the collection

            #if os(OSX) && !USE_EMBEDDED_MODULES
            if let arrayController = self.arrayController{
                // Add it to the array controller's content array
                arrayController.insertObject(item, atArrangedObjectIndex:index)

                // Re-sort (in case the user has sorted a column)
                arrayController.rearrangeObjects()

                // Get the sorted array
                let sorted = arrayController.arrangedObjects as! [Task]

                if let tableView = self.tableView{
                    // Find the object just added
                    let row = sorted.indexOf(item)!
                    // Begin the edit in the first column
                    tableView.editColumn(0, row: row, withEvent: nil, select: true)
                 }

            }else{
                // Add directly to the collection
                self.items.insert(item, atIndex: index)
            }
            #else
                self.items.insert(item, atIndex: index)
            #endif


            // Commit is ignored because
            // Distant persistency is not allowed for Task
            
        }else{
           
        }
    }




    // MARK: Remove

    public func removeObjectFromItemsAtIndex(index: Int, commit:Bool) {
        if let item : Task = items[index] {

            // Unregister the item
            Registry.unRegister(item)

            //Update the commit flag
            item.committed=false
            #if os(OSX) && !USE_EMBEDDED_MODULES
            // Remove the item from the array
            if let arrayController = self.arrayController{
                arrayController.removeObjectAtArrangedObjectIndex(index)
            }else{
                items.removeAtIndex(index)
            }
            #else
            items.removeAtIndex(index)
            #endif

        
            // Commit is ignored because
            // Distant persistency is not allowed for Task
            

        }
    }

     public func removeObject(item: Collectible, commit:Bool)->Bool{
        if let instance=item as? Task{
            #if os(OSX) && !USE_EMBEDDED_MODULES
                if let arrayController = self.arrayController{
                    if let idx=(arrayController.arrangedObjects as? [Task])?.indexOf(instance){
                        self.removeObjectFromItemsAtIndex(idx, commit:commit)
                        return true
                    }
                }else{
                    if let idx=self.items.indexOf(instance){
                        self.removeObjectFromItemsAtIndex(idx, commit:commit)
                        return true
                    }
                }
            #else
                if let idx=self.items.indexOf(instance){
                    self.removeObjectFromItemsAtIndex(idx, commit:commit)
                    return true
                }
            #endif
        }
        return false
    }


    public func removeObjectWithID(id:String, commit:Bool)->Bool{
        #if os(OSX) && !USE_EMBEDDED_MODULES
            if let arrayController = self.arrayController{
                if let idx=(arrayController.arrangedObjects as? [Task])?.indexOf({ return $0.UID==id }){
                    self.removeObjectFromItemsAtIndex(idx, commit:commit)
                    return true
                }
            }else{
                if let idx=self.items.indexOf( { return $0.UID==id } ){
                    self.removeObjectFromItemsAtIndex(idx, commit:commit)
                    return true
                }
            }
        #else
            if let idx=self.items.indexOf( { return $0.UID==id } ){
                self.removeObjectFromItemsAtIndex(idx, commit:commit)
                return true
            }
        #endif
        return false
    }
    
}