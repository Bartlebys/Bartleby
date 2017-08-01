//
//  JDocumentMetadata.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 12/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation


// The standard DocumentMetadata implementation
// The underlining model has been implemented by flexions in BaseDocumentMetadata
extension DocumentMetadata:DocumentMetadataProtocol {

    // Data Serialization
    public func toCryptedData() throws -> Data{
        let metadataString = try JSONEncoder().encode(self)
        return  try Bartleby.cryptoDelegate.encryptData(metadataString, useKey: Bartleby.configuration.KEY)
    }

    // Data DeSerialization
    public static func fromCryptedData(_ data:Data) throws ->DocumentMetadata{
        let decrypted = try Bartleby.cryptoDelegate.decryptData(data,useKey:Bartleby.configuration.KEY)
        return try JSONDecoder().decode(DocumentMetadata.self, from: decrypted)
    }


    public func configureSchema(_ metadatum: CollectionMetadatum) throws ->() {
        for m in self.collectionsMetadata {
            if m.collectionName == metadatum.collectionName {
                throw DocumentMetadataError.duplicatedCollectionName(name:m.collectionName)
            }
        }
        self.collectionsMetadata.append(metadatum)
    }

    @objc dynamic public var storedPassword: String?{
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
