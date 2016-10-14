//
//  Collectible.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 21/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

// Collectible items are identifiable and serializable
public protocol Collectible:  Identifiable,Referenced, Serializable,DictionaryRepresentation, Distribuable, Supervisable,ChangesInspectable, UniversalType,Exposed, JSONString {

    // The collection of the item
    var collection:CollectibleCollection? { get set }

    // Reflects the index of of the item in the collection initial value is -1 
    // During it life cycle the collection updates if necessary its real value.
    // It allow better perfomance in Collection Controllers ( e.g : random insertion and entity removal )
    var collectedIndex: Int { get set }

    // The creator UID
    var creatorUID: String { get set }

    // A summary that can be used for example by ExternalReferences to describe the instance
    var summary: String? { get set }

    // If set to true the instance is cleanup during cleanup routine.
    // suitable for unit test instances, or other temporary elements
    var ephemeral: Bool { get set }

    // The name of its holding collection e.g: projects for the class Project
    // This name will be used to identify the collection in the Registry
    static var collectionName: String { get }

    // An accessor to the static collectionName
    var d_collectionName: String { get }
}

public protocol Exposed{

    /// Return all the exposed instance variables names. Exposed means public and modifiable.
    var exposedKeys:[String] { get }

    /// Set the value of the given key
    ///
    /// - parameter value: the value
    /// - parameter key:   the key
    ///
    /// - throws: throws JObjectExpositionError when the key is not exposed
    func setExposedValue(_ value:Any?, forKey key: String) throws


    /// Returns the value of an exposed key.
    ///
    /// - parameter key: the key
    ///
    /// - throws: throws JObjectExpositionError when the key is not exposed
    ///
    /// - returns: returns the value
    func getExposedValueForKey(_ key:String) throws -> Any?

}


// TODO Create files 

public protocol Referenced{
    var document:BartlebyDocument? { get set }
}

public protocol ChangesInspectable{
    var changedKeys:[KeyedChanges] { get set }
}

/**
 *  A simple Objc compliant object to keep track of changes in memory
 */
@objc(KeyedChanges) open class KeyedChanges:NSObject {

    var elapsed=Bartleby.elapsedTime
    var key:String
    var changes:String

    init(key:String,changes:String) {
        self.key=key
        self.changes=changes
    }
}
