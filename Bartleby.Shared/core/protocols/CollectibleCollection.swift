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

/// We add SequenceType Support
// 'SequenceType' can only be used as a generic constraint because it has Self or associated type requirements
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
     Adds an item

     - parameter item: the collectible item
     */
    func add(item: Collectible)

    /**
     Insert an item at a given index.

     - parameter item:  the collectible item
     - parameter index: the insertion index
     */
    func insertObject(item: Collectible, inItemsAtIndex index: Int)


    /**
     Remove the item at a given index.

     - parameter index: the index
     */
    func removeObjectFromItemsAtIndex(index: Int)

    /**
     Remove the item

     - parameter item: the collectible item.

     - returns: true if the item has been removed
     */
    func removeObject(item: Collectible) -> Bool


    /**
     Removes an item by it UID

     - parameter id: the UID

     - returns: true if the item has been removed
     */
    func removeObjectWithID(id: String) -> Bool

}


// @bpds split files ?

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


public protocol Supervisable {

    /// Shall we commit that instance during next autocommit?
    var toBeCommitted: Bool { get }
    /**
     Mark that the instance requires to be committed if the auto commit observer is active
     */
    func provisionChanges()

    /**
     Locks the auto commit observer
     */
    func lockAutoCommitObserver()

    /**
     Unlock the auto commit observer
     */
    func unlockAutoCommitObserver()
}
