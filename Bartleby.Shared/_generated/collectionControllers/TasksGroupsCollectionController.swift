//
//  TasksGroupsCollectionController.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for benoit@pereira-da-silva.com
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
// WE TRY TO GENERATE ANY REPETITIVE CODE AND TO IMPROVE THE QUALITY ITERATIVELY
//
// Copyright (c) 2015  Chaosmos | https://chaosmos.fr  All rights reserved.
//
import Foundation
#if os(OSX)
import AppKit
#endif
#if !USE_EMBEDDED_MODULES
import Alamofire
import ObjectMapper
#endif

// MARK: A  collection controller of "tasksGroups"

// This controller implements data automation features.
// it uses KVO , KVC , dynamic invocation, oS X cocoa bindings,...
// It should be used on documents and not very large collections as it is computationnally intensive

@objc(TasksGroupsCollectionController) public class TasksGroupsCollectionController : JObject,IterableCollectibleCollection{

    // Universal type support
    override public class func typeName() -> String {
        return "TasksGroupsCollectionController"
    }

    weak public var undoManager:NSUndoManager?

    public var spaceUID:String=Default.NO_UID

    public var observableByUID:String=Default.NOT_OBSERVABLE

    #if os(OSX) && !USE_EMBEDDED_MODULES

    public weak var arrayController:NSArrayController?

    #endif

    weak public var tableView: BXTableView?

    public var enableKVO=false

    convenience init(enableKVO:Bool){
        self.init()
        self.enableKVO=enableKVO
    }

    public func generate() -> AnyGenerator<TasksGroup> {
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

    required public init() {
        super.init()
    }

    deinit{
        _stopObservingAllItems()
    }

    dynamic public var items:[TasksGroup]=[TasksGroup]()

    // We store the UIDs to guarantee KVO consistency.
    // Example : calling Mapper().toJSON(self) on a Collection adds the items to KVO.
    // Calling twice would add twice the observers.
    private var _observedUIDS=[String]()


    private func _stopObservingAllItems(){
        for item in items {
            _stopObserving(item)
        }
    }

    private func _startObservingAllItems(){
        for item in items {
            _startObserving(item)
        }
    }




// MARK: Identifiable

    override public class var collectionName:String{
        return TasksGroup.collectionName
    }

    override public var d_collectionName:String{
        return TasksGroup.collectionName
    }





    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
		self.items <- map["items"]
		_startObservingAllItems()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
		self.items=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),TasksGroup.classForCoder()]), forKey: "items")! as! [TasksGroup]
		_startObservingAllItems()

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
        if let item=item as? TasksGroup{


            #if os(OSX) && !USE_EMBEDDED_MODULES
            if let arrayController = self.arrayController{
                // Add it to the array controller's content array
                arrayController.insertObject(item, atArrangedObjectIndex:index)

                // Re-sort (in case the use has sorted a column)
                arrayController.rearrangeObjects()

                // Get the sorted array
                let sorted = arrayController.arrangedObjects as! [TasksGroup]

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

            self._startObserving(item)


        }else{
           
        }
    }




    // MARK: Remove

    public func removeObjectFromItemsAtIndex(index: Int) {
        if let item : TasksGroup = items[index] {

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

            self._stopObserving(item)

        

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


    // MARK: - Key Value Observing

    private var KVOContext: Int = 0

    private func _startObserving(item: TasksGroup) {
        if _observedUIDS.indexOf(item.UID) == nil && self.enableKVO {
            _observedUIDS.append(item.UID)
			item.addObserver(self, forKeyPath: "document", options: .Old, context: &KVOContext)
			item.addObserver(self, forKeyPath: "status", options: .Old, context: &KVOContext)
			item.addObserver(self, forKeyPath: "priority", options: .Old, context: &KVOContext)
			item.addObserver(self, forKeyPath: "spaceUID", options: .Old, context: &KVOContext)
			item.addObserver(self, forKeyPath: "tasks", options: .Old, context: &KVOContext)
			item.addObserver(self, forKeyPath: "lastChainedTask", options: .Old, context: &KVOContext)
			item.addObserver(self, forKeyPath: "progressionState", options: .Old, context: &KVOContext)
			item.addObserver(self, forKeyPath: "completionState", options: .Old, context: &KVOContext)
			item.addObserver(self, forKeyPath: "name", options: .Old, context: &KVOContext)
			item.addObserver(self, forKeyPath: "handlers", options: .Old, context: &KVOContext)
        }
    }

    private func _stopObserving(item: TasksGroup) {
        if self.enableKVO{
            if let idx=_observedUIDS.indexOf(item.UID)  {
                _observedUIDS.removeAtIndex(idx)
				item.removeObserver(self, forKeyPath: "document", context: &KVOContext)
				item.removeObserver(self, forKeyPath: "status", context: &KVOContext)
				item.removeObserver(self, forKeyPath: "priority", context: &KVOContext)
				item.removeObserver(self, forKeyPath: "spaceUID", context: &KVOContext)
				item.removeObserver(self, forKeyPath: "tasks", context: &KVOContext)
				item.removeObserver(self, forKeyPath: "lastChainedTask", context: &KVOContext)
				item.removeObserver(self, forKeyPath: "progressionState", context: &KVOContext)
				item.removeObserver(self, forKeyPath: "completionState", context: &KVOContext)
				item.removeObserver(self, forKeyPath: "name", context: &KVOContext)
				item.removeObserver(self, forKeyPath: "handlers", context: &KVOContext)
            }
        }
    }

    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &KVOContext else {
        // If the context does not match, this message
        // must be intended for our superclass.
        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        if let undoManager = self.undoManager{

            if let keyPath = keyPath, object = object, change = change {
                var oldValue: AnyObject? = change[NSKeyValueChangeOldKey]
                 if oldValue is NSNull {
                    oldValue = nil
                }
                undoManager.prepareWithInvocationTarget(object).setValue(oldValue, forKeyPath: keyPath)
            }
        }
        #if os(OSX) && !USE_EMBEDDED_MODULES
        // Sort descriptors support
        if let keyPath = keyPath {
            if let arrayController = self.arrayController{
                for sortDescriptor:NSSortDescriptor in arrayController.sortDescriptors{
                    if sortDescriptor.key==keyPath {
                        // Re-sort
                        arrayController.rearrangeObjects()
                    }
                }
            }
        }
        #endif
    }
}