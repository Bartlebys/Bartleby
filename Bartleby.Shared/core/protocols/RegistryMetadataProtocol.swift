//
//  RegistryMetadata.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 12/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation


public enum RegistryMetadataError: ErrorType {
    case DuplicatedCollectionName
    case ErrorOfCasting
}

// A model that encapsulates the descriptions-CollectionMetadatum of its persitent collections
// and stores the collaborative session data

public protocol RegistryMetadataProtocol: Identifiable, Serializable {

    associatedtype CollectionMetadatumType
    associatedtype User

    //The data space UID can be shared between multiple registries.
    var spaceUID: String { get set }

    //The root user of the registry is the user currently associated to the local instance of the registry
    // The full user instance.
    // We donnot want to store this user in the user collection ( to prevent its deletion and to mark its singularity)
    var currentUser: User? { get set }

    // Root Object UID defines the
    var rootObjectUID: String { get set }

    // The state dictionary
    var stateDictionary: [String:AnyObject] { get set }

    // Store the metadatum of each collection.
    var collectionsMetadata: [CollectionMetadatumType] { get }

    //Configure the schema (generally generated)
    func configureSchema(metadatum: CollectionMetadatumType) throws ->()

    // Should return the password if saveThePassword==true else a void string ""
    var storedPassword: String { get }

    // Should we save the password
    var saveThePassword: Bool { get set }

    // The collaboration URL
    var collaborationServerURL: NSURL? { get set }

}
