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

    // Data Serialization
    public func toCryptedData() throws -> Data{
        if let metadataString=self.toJSONString(){
            let crypted = try Bartleby.cryptoDelegate.encryptString(metadataString,useKey:Bartleby.configuration.KEY)
            if let metadataData = crypted.data(using:.utf8){
                   return metadataData
            }
        }
        throw DocumentMetadataError.dataSerializationFailed
    }

    // Data DeSerialization
    public static func fromCryptedData(_ data:Data) throws ->DocumentMetadata{
        if let cryptedJson = String(data: data, encoding:.utf8){
            let decrypted = try Bartleby.cryptoDelegate.decryptString(cryptedJson,useKey:Bartleby.configuration.KEY)
            if let metadata = Mapper <DocumentMetadata>().map(JSONString:decrypted){
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
