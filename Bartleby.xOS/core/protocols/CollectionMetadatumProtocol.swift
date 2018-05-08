//
//  CollectionMetadatum.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 03/11/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation



public protocol CollectionMetadatumProtocol {

    // The collection name
    var collectionName: String { get }

    // Allow Bartleby server to insure persistency
    var persistsDistantly: Bool { get set }

    // Should the collection be volatile ? == persist in memory only
    var inMemory: Bool { get set }

}
