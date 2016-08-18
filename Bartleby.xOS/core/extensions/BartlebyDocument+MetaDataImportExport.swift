//
//  Registry+MetadataExport.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 08/07/2016.
//
//

import Foundation

#if os(OSX)
    import AppKit
#else
    import UIKit
#endif

public extension BartlebyDocument{


    /**
     Export the metadata to a given path

     - parameter path: the path

     - parameter crypted : should the file be crypted? ( true is highly recommanded)

     */
    public func exportMetadataTo(path:String,crypted:Bool, handlers: Handlers) {
        do{
            let data = try self._getSerializedMetadata(crypted)
            Bartleby.fileManager.writeData(data, path: path, handlers: Handlers(completionHandler: { (dataWritten) in
                handlers.on(dataWritten)
            }))
        }catch{
            handlers.on(Completion.failureStateFromError(error))
        }

    }

    /**
     Imports the metadata from a given path

     - parameter path: the import path

     - parameter handlers: the handlers
     
     */
    public func importMetadataFrom(path:String,crypted:Bool,handlers: Handlers) {
        let readDataHandler=Handlers { (dataCompletion) in
            if var data=dataCompletion.data{
                do{
                    if crypted{
                        data = try Bartleby.cryptoDelegate.decryptData(data)
                    }
                    if let newRegistryMetadata=try Bartleby.defaultSerializer.deserialize(data) as? RegistryMetadata{
                        newRegistryMetadata.saveThePassword=false // Do not allow password bypassing on .bart import
                        self.dotBart=true// turn on the flag (the UI should ask for the password)
                        let previousUID=self.UID
                        Bartleby.sharedInstance.forget(previousUID)

                        // Disconnect from SSE
                        self._closeSSE()

                        // Reallocate the new registry Metadata
                        self.registryMetadata=newRegistryMetadata
                        Bartleby.sharedInstance.declare(self)
                        self.registryMetadata.currentUser?.document=self

                        // Reconnect to SSE
                        self._connectToSSE()

                        handlers.on(Completion.successState())
                    }else{
                        handlers.on(Completion.failureState("Deserialization of registry has failed", statusCode: StatusOfCompletion.Expectation_Failed))
                    }
                }catch{
                        handlers.on(Completion.failureStateFromError(error))
                }

            }else{
                handlers.on(dataCompletion)
            }
        }
        Bartleby.fileManager.readData(contentsOfFile:path, handlers: readDataHandler)
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