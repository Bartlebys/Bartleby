//
//  DocumentError.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 16/09/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation

public enum DocumentError: Error {
    case duplicatedCollectionName(collectionName:String)
    case attemptToLoadAnNonSupportedCollection(collectionName:String)
    case unExistingCollection(collectionName:String)
    case missingCollectionProxy(collectionName:String)
    case collectionProxyTypeError
    case collectionTypeError
    case rootObjectTypeMissMatch
    case instanceNotFound
    case instanceTypeMissMatch(found:String)
    case unSupportedFileType(typeName:String)
    case undefined
    case utf8EncodingError
    case fileWrapperNotFound(message:String)
    case blockNotFound(identifiedBy:String)
}
