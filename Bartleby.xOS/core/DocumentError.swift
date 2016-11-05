//
//  DocumentError.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 16/09/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation

#if os(OSX)
    import AppKit
#else
    import UIKit
#endif

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif


public enum DocumentError: Error {
    case duplicatedCollectionName(collectionName:String)
    case attemptToLoadAnNonSupportedCollection(collectionName:String)
    case unExistingCollection(collectionName:String)
    case missingCollectionProxy(collectionName:String)
    case collectionProxyTypeError
    case collectionTypeError
    case rootObjectTypeMissMatch
    case instanceNotFound
    case instanceTypeMissMatch
    case attemptToSetUpRootObjectUIDMoreThanOnce
    case unSupportedFileType(typeName:String)
    case undefined
    case utf8EncodingError
}
