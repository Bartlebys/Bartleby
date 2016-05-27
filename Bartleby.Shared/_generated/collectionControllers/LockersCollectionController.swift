//
//  LockersCollectionController.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for benoit@pereira-da-silva.com
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  Chaosmos | https://chaosmos.fr  All rights reserved.
//
import Foundation
#if os(OSX)
import AppKit
#endif
#if !USE_EMBEDDED_MODULES
import Alamofire
import ObjectMapper
#endif

// MARK: A  collection controller of "lockers"

// This controller implements data automation features.

@objc(LockersCollectionController) public class LockersCollectionController : JObject,IterableCollectibleCollection{

    // Universal type support
    override public class func typeName() -> String {
        return "LockersCollectionController"
    }

    weak public var undoManager:NSUndoManager?

    public var spaceUID:String=Default.NO_UID

    public var observableByUID:String=Default.NOT_OBSERVABLE

    #if os(OSX) && !USE_EMBEDDED_MODULES

    public weak var arrayController:NSArrayController?

    #endif

    weak public var tableView: BXTableView?

    public func generate() -> AnyGenerator<Locker> {
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

    /**
    An iterator that permit dynamic approaches.
    The Registry ignore the real types.
    Currently we do not use SequenceType, Subscript, ...

    - parameter on: the closure
    */
    public func superIterate(@noescape on:(element: protocol<Collectible,Supervisable>)->()){
        for item in self.items {
            on(element:item)
        }
    }


    /**
    Commit all the changes in one bunch
    Marking commit on each item will toggle hasChanged flag.
    */
    public func commitChanges() {
        let changedItems=self.items.filter { $0.toBeCommitted == true }
        bprint("\(changedItems.count) \( changedItems.count>1 ? "lockers" : "locker" )  has changed in LockersCollectionController",file:#file,function:#function,line:#line,category: Default.BPRINT_CATEGORY)
        for changed in changedItems{
            UpdateLocker.commit(changed, inDataSpace:self.spaceUID, observableBy: self.observableByUID)
        }

    }

    required public init() {
        super.init()
    }


    dynamic public var items:[Locker]=[Locker]()


    // MARK: Identifiable

    override public class var collectionName:String{
        return Locker.collectionName
    }

    override public var d_collectionName:String{
        return Locker.collectionName
    }



    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
        self.lockAutoCommitObserver()
		self.items <- ( map["items"] )
		
        self.unlockAutoCommitObserver()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.lockAutoCommitObserver()
		self.items=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),Locker.classForCoder()]), forKey: "items")! as! [Locker]
		
        self.unlockAutoCommitObserver()
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		coder.encodeObject(self.items,forKey:"items")
    }


    override public class func supportsSecureCoding() -> Bool{
        return true
    }


    // MARK: Add

    public func add(item:Collectible){
        #if os(OSX) && !USE_EMBEDDED_MODULES
        if let arrayController = self.arrayController{
            self.insertObject(item, inItemsAtIndex: arrayController.arrangedObjects.count)
        }else{
            self.insertObject(item, inItemsAtIndex: items.count)
        }
        #else
        self.insertObject(item, inItemsAtIndex: items.count)
        #endif
    }

    // MARK: Insert

    public func insertObject(item: Collectible, inItemsAtIndex index: Int) {
        if let item=item as? Locker{


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
            if let undoManager: NSUndoManager = undoManager {
                undoManager.prepareWithInvocationTarget(self).removeObjectFromItemsAtIndex(index)
                if !undoManager.undoing {
                    undoManager.setActionName(NSLocalizedString("AddLocker", comment: "AddLocker undo action"))
                }
            }
            
            #if os(OSX) && !USE_EMBEDDED_MODULES
            if let arrayController = self.arrayController{
                // Add it to the array controller's content array
                arrayController.insertObject(item, atArrangedObjectIndex:index)

                // Re-sort (in case the use has sorted a column)
                arrayController.rearrangeObjects()

                // Get the sorted array
                let sorted = arrayController.arrangedObjects as! [Locker]

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


            if item.committed==false{
               CreateLocker.commit(item, inDataSpace:self.spaceUID, observableBy: self.observableByUID)
            }

        }else{
           
        }
    }




    // MARK: Remove

    public func removeObjectFromItemsAtIndex(index: Int) {
        if let item : Locker = items[index] {

            // Add the inverse of this invocation to the undo stack
            if let undoManager: NSUndoManager = undoManager {
                // We don't want to introduce a retain cycle
                // But with the objc magic casting undoManager.prepareWithInvocationTarget(self) as? UsersCollectionController fails
                // That's why we have added an registerUndo extension on NSUndoManager
                undoManager.registerUndo({ () -> Void in
                   self.insertObject(item, inItemsAtIndex: index)
                })
                if !undoManager.undoing {
                    undoManager.setActionName(NSLocalizedString("RemoveLocker", comment: "Remove Locker undo action"))
                }
            }
            
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

        
            DeleteLocker.commit(item.UID,fromDataSpace:self.spaceUID, observableBy: self.observableByUID)  


        }
    }

    public func removeObject(item: Collectible)->Bool{
        var index=0
        for storedItem in items{
            if item.UID==storedItem.UID{
                self.removeObjectFromItemsAtIndex(index)
                return true
            }
            index += 1
        }
        return false
    }

    public func removeObjectWithID(id:String)->Bool{
        var index=0
        for storedItem in items{
            if id==storedItem.UID{
                self.removeObjectFromItemsAtIndex(index)
                return true
            }
            index += 1
        }
        return false
    }

    
}