//
//  BartlebyOperation.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 27/10/2016.
//
//

import Foundation

public enum BartlebyOperationError: Error {
    case dataNotFound
    case operationNotFound(UID: String)
    case documentNotFound(documentUID: String)
}

/// An operation is a client server request CRUD or URD
public protocol BartlebyOperation: Collectible, Pusher {
}
