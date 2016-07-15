//
//  Collectible.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 21/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation




// Collectible items are identifiable and serializable
public protocol Collectible:  Identifiable, Serializable, Supervisable,DictionaryRepresentation, UniversalType,JSONString {

    // This flag is set to true on first commit.
    var committed: Bool { get set }

    // This flag should be set to true
    // When the collaborative server has acknowledged the object creation
    var distributed: Bool { get set }

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


public protocol JSONString{
   func toJSONString(prettyPrint:Bool)->String
}