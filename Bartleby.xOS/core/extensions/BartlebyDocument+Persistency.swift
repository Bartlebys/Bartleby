//
//  BartlebyDocument+Persistency.swift
//
//  This extension deals with:
//      1. data serialization ( collections, metadata)
//      2. bsfs blocks storages
//
//  This is a central piece of the Document Oriented architecture.
//  We provide a universal implementation with conditionnal compilation
//
//  The document stores references to Bartleby's style ManagedCollections.
//  This allow to use intensively bindings and distributed data automation.
//  With the mediation of standard Bindings approach with NSArrayControler
//
//  And the potential complexity masked.
//

import Foundation

#if os(OSX)
    import AppKit
#else
    import UIKit 
#endif

import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
    import ObjectMapper
#endif

extension BartlebyDocument{

    #if os(OSX)

    open override func read(from url: URL, ofType typeName: String) throws {
        let fileWrapper = try FileWrapper(url: url, options: FileWrapper.ReadingOptions.immediate)
        try self._read(from: fileWrapper)
    }

    open override func write(to url: URL, ofType typeName: String) throws {
        let fileWrapper = try self._updatedFileWrappers()
        try fileWrapper.write(to: url, options: FileWrapper.WritingOptions.atomic, originalContentsURL: nil)
    }

    #else

    // To Read content
    open override func load(fromContents contents: Any, ofType typeName: String?) throws {
    if let fileWrapper = contents as? FileWrapper{
    try self._read(from:fileWrapper)
    }else{
    throw DocumentError.fileWrapperNotFound(message:"on load")
    }
    }

    // To Write content
    override open func contents(forType typeName: String) throws -> Any {
    return try self._updatedFileWrappers()
    }

    #endif

    private func _read(from fileWrapper:FileWrapper) throws {
        if let fileWrappers=fileWrapper.fileWrappers {

            // ##############
            // # Metadata
            // ##############

            if let wrapper=fileWrappers[_metadataFileName] {
                if let metadataData=wrapper.regularFileContents {

                    // What is the proxy UID?
                    let proxyDocumentUID=self.UID

                    let metadata = try DocumentMetadata.fromCryptedData(metadataData)
                    self.metadata = metadata
                    self.metadata.currentUser?.referentDocument=self

                    // We load the sugar (if there is one in the bowl)
                    try? self.metadata.loadSugar()

                    // Replace the document proxy declared document UID
                    // By the persistent UID
                    Bartleby.sharedInstance.replaceDocumentUID(proxyDocumentUID, by: self.metadata.persistentUID)
                }
            } else {
                // ERROR
            }
            try self.loadCollectionData(from:fileWrappers)

            Async.main{
                self.documentDidLoad()
            }
        }
        // Store the reference
        self.documentFileWrapper=fileWrapper
    }



    open func loadCollectionData(from fileWrappers: [String : FileWrapper])throws{

        // We load the data if the sugar is defined
        if self.metadata.sugar != Default.NO_UID{

            // ##############
            // # BSFS DATA
            // ##############

            if let wrapper=fileWrappers[_bsfsDataFileName] {
                if var data=wrapper.regularFileContents {
                    data = try Bartleby.cryptoDelegate.decryptData(data,useKey:self.metadata.sugar)
                    try self.bsfs.restoreStateFrom(data: data)
                }
            } else {
                // ERROR
            }

            // ##############
            // # Collections
            // ##############

            for metadatum in self.metadata.collectionsMetadata {
                // MONOLITHIC STORAGE
                if metadatum.storage == CollectionMetadatum.Storage.monolithicFileStorage {
                    let names=self._collectionFileNames(metadatum)
                    if let wrapper=fileWrappers[names.crypted] ?? fileWrappers[names.notCrypted] {
                        let filename=wrapper.filename
                        if var collectionData=wrapper.regularFileContents {
                            if let proxy=self.collectionByName(metadatum.collectionName) {
                                if let path=filename {
                                    if let ext=path.components(separatedBy: ".").last {
                                        let pathExtension="."+ext
                                        if  pathExtension == BartlebyDocument.DATA_EXTENSION {
                                            // Use the faster possible approach.
                                            // The resulting data is not a valid String check CryptoDelegate for details.
                                            let collectionString = try Bartleby.cryptoDelegate.decryptStringFromData(collectionData,useKey:self.metadata.sugar)
                                            collectionData = collectionString.data(using:.utf8) ?? Data()
                                        }
                                    }
                                    let _ = try proxy.updateData(collectionData,provisionChanges: false)
                                }
                            } else {
                                throw DocumentError.attemptToLoadAnNonSupportedCollection(collectionName:metadatum.collectionName)
                            }
                        }
                    } else {
                        // ERROR
                    }
                } else {
                    // INCREMENTAL STORAGE CURRENTLY NOT SUPPORTED
                }
            }

            // # Optimization
            // We call the  proxy.propagate() after full deserialization.
            // It allows for example to reduce deferredOwnerships rebuilding
            for metadatum in self.metadata.collectionsMetadata {
                if let proxy=self.collectionByName(metadatum.collectionName) {
                    proxy.propagate()
                }
            }
        }else{
             self.log("Sugar is undefined", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
        }

    }





    private func _updatedFileWrappers()throws ->FileWrapper{
        self.documentWillSave()
        if self.metadata.sugar == Default.NO_UID{
            self.log("Sugar is undefined", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
        }
        if var fileWrappers=self.documentFileWrapper.fileWrappers {

            // ##############
            // # Metadata
            // ##############

            #if os(OSX)
                // Try to store a preferred filename
                self.metadata.preferredFileName=self.fileURL?.lastPathComponent
            #else
                // Try to store a preferred filename
                self.metadata.preferredFileName=self.fileURL.lastPathComponent
            #endif

            let metadataData=try self.metadata.toCryptedData()

            // Remove the previous metadata
            if let wrapper=fileWrappers[self._metadataFileName] {
                self.documentFileWrapper.removeFileWrapper(wrapper)
            }
            let metadataFileWrapper=FileWrapper(regularFileWithContents: metadataData)
            metadataFileWrapper.preferredFilename=self._metadataFileName
            self.documentFileWrapper.addFileWrapper(metadataFileWrapper)

            // ##############
            // # BSFS DATA
            // ##############

            if let wrapper=fileWrappers[self._bsfsDataFileName]{
                self.documentFileWrapper.removeFileWrapper(wrapper)
            }

            let data = try Bartleby.cryptoDelegate.encryptData(self.bsfs.saveState(),useKey:self.metadata.sugar)
            let bsfsFileWrapper=FileWrapper(regularFileWithContents:data)
            bsfsFileWrapper.preferredFilename=self._bsfsDataFileName
            self.documentFileWrapper.addFileWrapper(bsfsFileWrapper)


            // ##############
            // # Collections
            // ##############
            // We load the data if the sugar is defined

            if self.metadata.sugar != Default.NO_UID{

                for metadatum: CollectionMetadatum in self.metadata.collectionsMetadata {

                    if !metadatum.inMemory {
                        let collectionfileName=self._collectionFileNames(metadatum).crypted
                        // MONOLITHIC STORAGE
                        if metadatum.storage == CollectionMetadatum.Storage.monolithicFileStorage {

                            if var collection = self.collectionByName(metadatum.collectionName) as? CollectibleCollection {

                                if collection.shouldBeSaved{

                                    // We use multiple files
                                    // The resulting data is not a valid String check CryptoDelegate for details.
                                    let collectionString = collection.serializeToUFf8String()
                                    let collectionData = try Bartleby.cryptoDelegate.encryptStringToData(collectionString,useKey:self.metadata.sugar)

                                    // Remove the previous data
                                    if let wrapper=fileWrappers[collectionfileName] {
                                        self.documentFileWrapper.removeFileWrapper(wrapper)
                                    }

                                    let collectionFileWrapper=FileWrapper(regularFileWithContents: collectionData)
                                    collectionFileWrapper.preferredFilename=collectionfileName
                                    self.documentFileWrapper.addFileWrapper(collectionFileWrapper)

                                    // Reinitialize the flag
                                    collection.shouldBeSaved=false
                                }

                            } else {
                                // NO COLLECTION
                            }
                        } else {
                            // INCREMENTAL STORAGE CURRENTLY NOT SUPPORTED
                        }
                    }
                }
                
                // Bsfs blocks
                if  fileWrappers[self.blocksDirectoryWrapperName] == nil{
                    let blocksFileWrapper=FileWrapper(directoryWithFileWrappers: [:])
                    blocksFileWrapper.preferredFilename=self.blocksDirectoryWrapperName
                    self.documentFileWrapper.addFileWrapper(blocksFileWrapper)
                }
            }
        }
        
        return self.documentFileWrapper
    }
    
}
