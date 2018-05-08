//
//  DocumentMetadataProtocol.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 12/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

#if !USE_EMBEDDED_MODULES
    import Alamofire
#endif

public enum DocumentMetadataError: Error {
    case duplicatedCollectionName(name: String)
    case errorOfCasting
    case dataSerializationFailed
    case dataDeserializationFailed
}

// A model that encapsulates the descriptions-CollectionMetadatum of its persitent collections
// and stores the collaborative session data

public protocol DocumentMetadataProtocol: Codable {
    associatedtype CollectionMetadatumType
    associatedtype User

    // Data Serialization
    func toCryptedData() throws -> Data

    // Data DeSerialization
    static func fromCryptedData(_ data: Data, document: BartlebyDocument) throws -> DocumentMetadata

    // The data space UID can be shared between multiple Documents.
    var spaceUID: String { get set }

    // Defines the document UID
    var persistentUID: String { get set }

    // The root user of the Document is the user currently associated to the local instance of the Document
    // The full user instance.
    // We donnot want to store this user in the user collection ( to prevent its deletion and to mark its singularity)
    var currentUser: User? { get }

    // The state data dictionary
    var statesDictionary: [String: Data] { get set }

    // Store the metadatum of each collection.
    var collectionsMetadata: [CollectionMetadatumType] { get }

    // Configure the schema (generally generated)
    func configureSchema(_ metadatum: CollectionMetadatumType) throws -> Void

    // Should return the password if saveThePassword == true else a void string ""
    var storedPassword: String? { get }

    // Should we save the password
    var saveThePassword: Bool { get set }

    // The collaboration URL
    var collaborationServerURL: URL? { get set }
}
