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
        if let metadataString = try JSON.encoder.encode(self).optionalString(using: Default.STRING_ENCODING){
            let crypted = try Bartleby.cryptoDelegate.encryptString(metadataString,useKey:Bartleby.configuration.KEY)
            if let metadataData = crypted.data(using:Default.STRING_ENCODING){
                   return metadataData
            }
        }
        throw DocumentMetadataError.dataSerializationFailed
    }

    // Data DeSerialization
    public static func fromCryptedData(_ data:Data,document:BartlebyDocument) throws ->DocumentMetadata{
        if let cryptedJson = String(data: data, encoding:Default.STRING_ENCODING){
            let decrypted = try Bartleby.cryptoDelegate.decryptString(cryptedJson,useKey:Bartleby.configuration.KEY)
            if let decryptedData = decrypted.data(using:Default.STRING_ENCODING){
                let metadata = try document.dynamics.deserialize(typeName: DocumentMetadata.typeName(), data: data, document: nil) as! DocumentMetadata
                return metadata
            }
        }
        throw DocumentMetadataError.dataDeserializationFailed
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
