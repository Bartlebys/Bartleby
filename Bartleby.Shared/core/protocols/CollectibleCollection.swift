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

// Informal Protocol to mark that a class is a generated collection.
// The collection behavior is generated using flexions.
public protocol CollectibleCollection: Collectible {

    weak var undoManager: NSUndoManager? { get set }

    var spaceUID: String { get set }

    var observableByUID: String { get set }

    #if os(OSX) && !USE_EMBEDDED_MODULES
    // When using cocoa bindings with an array controller
    // You can set the arrayController for a seamless integration
    weak var arrayController: NSArrayController? { get set }
    #endif

    // And also a tableview
    weak var tableView: BXTableView? { get set }

    func add(item: Collectible)

    func insertObject(item: Collectible, inItemsAtIndex index: Int)

    func removeObjectFromItemsAtIndex(index: Int)

    func removeObject(item: Collectible) -> Bool

    func removeObjectWithID(id: String) -> Bool

}


// @bpds split files ?


public typealias Collection=protocol< CollectibleCollection, SuperIterable, Committable>


public protocol Committable {

    /**
     Commits the changes in one bunch
     */
    func commitChanges()

}



public protocol SuperIterable {
    /**

     An iterator that permit dynamic approaches. (not equivalent to SequenceType)

     - parameter on: the iteration closure

     - returns: return value description
     */
    func superIterate(@noescape on:(element: protocol<Collectible, Supervisable>)->())
}


public protocol Supervisable {
    var toBeCommitted: Bool { get }
    func commitRequired()
    func lockChangesFlag()
    func unLockChangesFlag()
}


public protocol IterableCollectibleCollection: CollectibleCollection, SequenceType, SuperIterable, Committable {

}
