//
//  RelationShip.swift
//  bartleby
//
//  Created by Benoit Pereira da silva on 26/12/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

public enum Relationship: String {
    /// Serialized into the Object
    case free
    case ownedBy

    /// "owns" is Computed at runtime during registration to determine the the Subject
    /// Ownership is computed asynchronously for better resilience to distributed pressure
    /// Check ManagedCollection.propagate()
    case owns
}
