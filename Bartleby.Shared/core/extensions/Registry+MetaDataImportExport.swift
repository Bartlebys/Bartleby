//
//  Registry+MetadataExport.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 08/07/2016.
//
//

import Foundation

public extension Registry{


    /**
     Export the metadata to a given path

     - parameter path: the path

     - returns: true on success.
     */
    public func exportMetadataTo(path:String, handlers: Handlers) {
        let directoryCreationHandlers=Handlers { (created) in
            if created.success{
                 // !!! implement the export logic
            }else{
               handlers.on(created)
            }
        }
        Bartleby.fileManager.createDirectoryAtPath(path, handlers: directoryCreationHandlers)
    }

    /**
     Imports the metadata from a given path

     - parameter path: the import path

     - parameter path:      the import path
     - parameter handlers: the handlers
     */
    public func importMetadataFrom(path:String,handlers: Handlers) {
        let fileExistsHandlers=Handlers { (exists) in
            if exists.success{
                // !!! implement the import logic
            }else{
                handlers.on(exists)
            }
        }
        Bartleby.fileManager.fileExistsAtPath(path, handlers: fileExistsHandlers)
    }


    /**

     - parameter crypted: is set to true the metadata will be crypted (recommanded)

     - throws: serialization exceptions

     - returns: the NSData
     */
    private func _getSerializedMetadata(crypted:Bool=true) throws -> NSData{
        let serializedMetadata=self.registryMetadata.serialize()
        if crypted{
            return try Bartleby.cryptoDelegate.encryptData(serializedMetadata)
        }else{
            return serializedMetadata
        }
    }

    /**

     - parameter data: the serialized data

     - throws: deserialization exceptions
     */
    private func _useSerializedMetadata(data:NSData) throws {
        if let metadata = try Bartleby.defaultSerializer.deserialize(data) as? RegistryMetadata{
            self.registryMetadata=metadata
        }
    }


}