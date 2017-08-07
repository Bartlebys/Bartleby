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


// Protocol to mark that a class is a generated collection.
// The collection behavior is generated using flexions.
public protocol CollectibleCollection: Collectible {

    var collectedType:Collectible.Type { get }

    // Used to determine if the wrapper should be saved.
    var shouldBeSaved:Bool { get set }


    /// Marks that a collectible instance should be committed.
    ///
    /// - Parameter item: the collectible instance
    func stage(_ item: Collectible)

    // The undo manager (for automation)
    weak var undoManager: UndoManager? { get }

    // The dataspace UID
    var spaceUID: String { get }

    // The document UID
    var documentUID:String { get }

    // Should be called to propagat references (Collection, ReferentDocument, Owned relations)
    func propagate()


    /// Returns the collected items
    /// You should not normally use this method directly
    /// We use this to offer better performances during collection proxy deserialization phase
    /// This method may be removed in next versions
    /// - Returns: the collected items
    func getItems()->[Collectible]

    /// Updates or creates an item
    ///
    /// - Parameters:
    ///   - item: the item
    ///   - commit: should we commit the `Upsertion`?
    /// - Returns: N/A
    func upsert(_ item: Collectible, commit:Bool)



    /// Ads an item
    ///
    /// - Parameters:
    ///   - item: the collectible item
    ///   - commit: should we commit the addition?
    ///   - isUndoable: is the addition reversible by the undo manager?
    /// - Returns: N/A
    func add(_ item: Collectible,commit:Bool, isUndoable:Bool)



    /// Appends some items
    ///
    /// - Parameters:
    ///   - items: the collectible items to add
    ///   - commit: should we commit the additions?
    ///   - isUndoable: are the additions reversible by the undo manager?
    /// - Returns: N/A
    func append(_ items:[Collectible],commit:Bool, isUndoable:Bool)


    ///  Insert an item at a given index.
    ///
    /// - Parameters:
    ///   - item: the collectible item
    ///   - index: the index
    ///   - commit: should we commit the addition?
    ///   - isUndoable: is the addition reversible by the undo manager?
    /// - Returns: N/A
    func insertObject(_ item: Collectible, inItemsAtIndex index: Int,commit:Bool, isUndoable:Bool)


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


    /// Create a filtered copy of a collectible collection
    ///
    /// - Parameter isIncluded: the filtering closure
    /// - Returns: the filtered Collection
    func filteredCopy(_ isIncluded: (Collectible)-> Bool)-> CollectibleCollection


}
