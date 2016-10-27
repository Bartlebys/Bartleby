//
//  BartlebyDocument+MetaDataImportExport.swift
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
    public func exportMetadataTo(_ path:String,crypted:Bool, handlers: Handlers) {
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
    public func importMetadataFrom(_ path:String,crypted:Bool,handlers: Handlers) {
        let readDataHandler=Handlers { (dataCompletion) in
            if var data=dataCompletion.data{
                do{
                    if crypted{
                        data = try Bartleby.cryptoDelegate.decryptData(data)
                    }
                    if let newDocumentMetadata=try Bartleby.defaultSerializer.deserialize(data) as? DocumentMetadata{
                        newDocumentMetadata.saveThePassword=false // Do not allow password bypassing on .bart import
                        self.dotBart=true// turn on the flag (the UI should ask for the password)
                        let previousUID=self.UID
                        Bartleby.sharedInstance.forget(previousUID)

                        // Disconnect from SSE
                        self._closeSSE()

                        // Reallocate the new  Metadata
                        self.metadata=newDocumentMetadata
                        Bartleby.sharedInstance.declare(self)
                        self.metadata.currentUser?.document=self

                        // Reconnect to SSE
                        self._connectToSSE()

                        handlers.on(Completion.successState())
                    }else{
                        handlers.on(Completion.failureState("Deserialization of document has failed", statusCode: StatusOfCompletion.expectation_Failed))
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
    fileprivate func _getSerializedMetadata(_ crypted:Bool=true) throws -> Data{
        let serializedMetadata=self.metadata.serialize()
        if crypted{
            return try Bartleby.cryptoDelegate.encryptData(serializedMetadata)
        }else{
            return serializedMetadata as Data
        }
    }

    /**

     - parameter data: the serialized data

     - throws: deserialization exceptions
     */
    fileprivate func _useSerializedMetadata(_ data:Data) throws {
        if let metadata = try Bartleby.defaultSerializer.deserialize(data) as? DocumentMetadata{
            self.metadata=metadata
        }
    }

}
