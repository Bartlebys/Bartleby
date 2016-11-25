//
//  JDocumentMetadata.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 12/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif


// The standard DocumentMetadata implementation
// The underlining model has been implemented by flexions in BaseDocumentMetadata
extension DocumentMetadata:DocumentMetadataProtocol {


    public func configureSchema(_ metadatum: CollectionMetadatum) throws ->() {
        for m in self.collectionsMetadata {
            if m.collectionName == metadatum.collectionName {
                throw DocumentMetadataError.duplicatedCollectionName(name:m.collectionName)
            }
        }
        self.collectionsMetadata.append(metadatum)
    }

    dynamic public var storedPassword: String?{
        get {
            if (self.saveThePassword) {
                if let currentUser=currentUser {
                    return currentUser.password
                }
            }
            return ""
        }
    }

}
