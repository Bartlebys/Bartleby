//
//  Collectible.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 21/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

// Collectible items are identifiable and serializable
public protocol Collectible:  Referenced,Serializable,DataUpdatable,DictionaryRepresentation,Supervisable,Committable,ChangesInspectable,UniversalType,Exposed,Mergeable,JSONString,Relational,ProvisionChanges {

    // The UID of the collectible object
    var UID:String { get set }

    // The collection of the item
    var collection:CollectibleCollection? { get set }

    // The creator UID
    var creatorUID: String { get set }

    // You can associate and external ID
    var externalID:String { get set }

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


    /// - Parameter commit:

    /// Erases globally the instance and its dependent relations.
    /// Throws ErasingError and DocumentError
    /// You may Override this method to purge files (e.g: Node, Block, ...)
    /// Erase the collectible instance (and its dependent relations)
    /// - Parameters:
    ///   - commit: set to true by default (we set to false only  not to commit triggered Deletion)
    ///   - eraserUID: the eraser UID
    /// - Returns: N/A
    func erase(commit:Bool,eraserUID:String)throws->()
}

