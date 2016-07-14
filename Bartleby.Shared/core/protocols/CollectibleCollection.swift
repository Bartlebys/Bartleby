//
//  CollectibleCollection.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 21/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation
#if os(OSX) && !USE_EMBEDDED_MODULES
import Cocoa
#endif

// A collection without generic constraint.
public typealias Collection=protocol< CollectibleCollection, SuperIterable, Committable>

// We add SequenceType Support to the collection Type.
// 'SequenceType' can only be used as a generic constraint because it has Self or associated type requirements
// So we use IterableCollectibleCollection for concrete  collection implementation and reference in the Registry `internal var _collections=[String:Collection]()`
public typealias IterableCollectibleCollection = protocol<Collection, SequenceType>

// Protocol to mark that a class is a generated collection.
// The collection behavior is generated using flexions.
public protocol CollectibleCollection: Collectible {

    // The undo manager (for automation)
    weak var undoManager: NSUndoManager? { get set }

    // The dataspace UID
    var spaceUID: String { get set }

    #if os(OSX) && !USE_EMBEDDED_MODULES
    // When using cocoa bindings with an array controller
    // You can set the arrayController for a seamless integration
    weak var arrayController: NSArrayController? { get set }
    #endif

    /// You can reference a tableview for automation
    weak var tableView: BXTableView? { get set }


    /**
     Update or create an item

     - parameter item: the collectible item
     */
    func upsert(item: Collectible, commit:Bool)


    /**
     Adds an item

     - parameter item: the collectible item
     */
    func add(item: Collectible,commit:Bool)


    /**
     Insert an item at a given index.

     - parameter item:  the collectible item
     - parameter index: the insertion index
     */
    func insertObject(item: Collectible, inItemsAtIndex index: Int,commit:Bool)


    /**
     Remove the item at a given index.

     - parameter index: the index
     */
    func removeObjectFromItemsAtIndex(index: Int,commit:Bool)

    /**
     Remove the item

     - parameter item: the collectible item.

     - returns: true if the item has been removed
     */
    func removeObject(item: Collectible,commit:Bool) -> Bool


    /**
     Removes an item by it UID

     - parameter id: the UID

     - returns: true if the item has been removed
     */
    func removeObjectWithID(id: String,commit:Bool) -> Bool

}


public protocol Committable {

    /**

     Commits the changes in one bunch
     - returns: an array of UID.
     */
    func commitChanges() -> [String]

}


public protocol SuperIterable {
    /**

     An iterator that permit dynamic approaches. (SequenceType uses Generics)

     - parameter on: the iteration closure

     - returns: return value description
     */
    func superIterate(@noescape on:(element:Collectible)->())
}


public typealias SupervisionClosure = (key:String,oldValue:AnyObject?,newValue:AnyObject?)->()

public protocol Supervisable {

    /// Shall we commit that instance during next autocommit?
    var toBeCommitted: Bool { get }

    /**
     Tags the changed keys
     And Mark that the instance requires to be committed if the auto commit observer is active
     This mecanism can replace KVO if necessary.

     - parameter key:      the key
     - parameter oldValue: the oldValue
     - parameter newValue: the newValue
     */
    func provisionChanges(forKey key:String,oldValue:AnyObject?,newValue:AnyObject?)


    /**
     Adds a closure observer

     - parameter observer: the observer
     - parameter closure:  the closure to be called.
     */
    func addChangesObserver(observer:Identifiable, closure:SupervisionClosure)

    /**
     Remove the observer's closure

     - parameter observer: the observer.
     */
    func removeChangesObserver(observer:Identifiable)


    /**
     Locks the auto commit observer
     */
    func disableSupervision()

    /**
     Unlock the auto commit observer
     */
    func enableSupervision()
}
