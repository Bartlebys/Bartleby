//
//  Collectible.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 21/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

// Collectible items are identifiable and serializable
public protocol Collectible:  Identifiable,Referenced, Serializable,DictionaryRepresentation, Supervisable,Committable,ChangesInspectable, UniversalType,Exposed, JSONString {

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
    // This name will be used to identify the collection in the Document
    static var collectionName: String { get }

    // An accessor to the static collectionName
    var d_collectionName: String { get }
}

