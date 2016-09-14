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
public protocol BartlebyCollection:CollectibleCollection, SuperIterable, Committable{

}

// We add SequenceType Support to the collection Type.
// 'SequenceType' can only be used as a generic constraint because it has Self or associated type requirements
// So we use IterableCollectibleCollection for concrete  collection implementation and reference in the Registry `internal var _collections=[String:Collection]()`
public protocol IterableCollectibleCollection:BartlebyCollection,Collection{

}

// Protocol to mark that a class is a generated collection.
// The collection behavior is generated using flexions.
public protocol CollectibleCollection: Collectible {

    // The undo manager (for automation)
    weak var undoManager: UndoManager? { get set }


    var registry:BartlebyDocument? { get set }

    // The dataspace UID
    var spaceUID: String { get }

    // The registry UID
    var registryUID:String { get }

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
    func upsert(_ item: Collectible, commit:Bool)


    /**
     Adds an item

     - parameter item: the collectible item
     */
    func add(_ item: Collectible,commit:Bool)


    /**
     Insert an item at a given index.

     - parameter item:  the collectible item
     - parameter index: the insertion index
     */
    func insertObject(_ item: Collectible, inItemsAtIndex index: Int,commit:Bool)


    /**
     Remove the item at a given index.

     - parameter index: the index
     */
    func removeObjectFromItemsAtIndex(_ index: Int,commit:Bool)

    /**
     Remove the item

     - parameter item: the collectible item.
     */
    func removeObject(_ item: Collectible,commit:Bool)


    /**
     Remove a bunch of items

     - parameter items: the collectible items.
     */
    func removeObjects(_ items: [Collectible],commit:Bool)


    /**
     Removes an item by it UID

     - parameter id: the UID
     */
    func removeObjectWithID(_ id: String,commit:Bool)


    /**
     Removes an item by it UID

     - parameter id: the UID
     */
    func removeObjectWithIDS(_ ids: [String],commit:Bool)

    ///
    /// Returns the Collectible instance at a given index.
    /// - parameter index: the instance
    ///
    /// - returns: a Collectible Instance
    func item(at index:Int)->Collectible?


    /// Return the  number of items
    var count:Int { get }


}
