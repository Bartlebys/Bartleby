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

#if !USE_EMBEDDED_MODULES
    import Alamofire
#endif

extension BartlebyDocument {
    #if os(OSX)

        open override func read(from url: URL, ofType _: String) throws {
            let fileWrapper = try FileWrapper(url: url, options: FileWrapper.ReadingOptions.immediate)
            try _read(from: fileWrapper)
        }

        open override func write(to url: URL, ofType _: String) throws {
            let fileWrapper = try _updatedFileWrappers()
            try fileWrapper.write(to: url, options: [FileWrapper.WritingOptions.atomic, FileWrapper.WritingOptions.withNameUpdating], originalContentsURL: url)
            send(DocumentStates.documentDidSave)
        }

    #else

        // To Read content
        open override func load(fromContents contents: Any, ofType _: String?) throws {
            if let fileWrapper = contents as? FileWrapper {
                try _read(from: fileWrapper)
            } else {
                throw DocumentError.fileWrapperNotFound(message: "on load")
            }
        }

        // To Write content
        open override func contents(forType _: String) throws -> Any {
            // @todo on iOS
            let wrapper = try _updatedFileWrappers()
            /*
             try fileWrapper.write(to: url, options: [FileWrapper.WritingOptions.atomic,FileWrapper.WritingOptions.withNameUpdating], originalContentsURL: url)
             self.send(DocumentStates.documentDidSave)
             */
            return wrapper
        }

    #endif

    private func _read(from fileWrapper: FileWrapper) throws {
        do {
            if let fileWrappers = fileWrapper.fileWrappers {
                // ##############
                // # Metadata
                // ##############

                if let wrapper = fileWrappers[_metadataFileName] {
                    if let metadataData = wrapper.regularFileContents {
                        // What is the proxy UID?
                        let proxyDocumentUID = UID

                        let metadata = try DocumentMetadata.fromCryptedData(metadataData, document: self)
                        self.metadata = metadata
                        self.metadata.currentUser?.referentDocument = self

                        // We load the sugar (if there is one in the bowl)
                        try? self.metadata.loadSugar()

                        // Replace the document proxy declared document UID
                        // By the persistent UID
                        Bartleby.sharedInstance.replaceDocumentUID(proxyDocumentUID, by: self.metadata.persistentUID)
                    }
                } else {
                    // ERROR
                }
                try _loadCollectionData(from: fileWrappers)
                // Store the reference
                documentFileWrapper = fileWrapper
                syncOnMain {
                    self.send(DocumentStates.collectionsDataHasBeenDecrypted)
                }
            } else {
                // Store the reference
                documentFileWrapper = fileWrapper
            }
        } catch {
            throw error
        }
    }

    // This method is used when the sugar has been recovered to try to reload the collection data
    open func reloadCollectionData() throws {
        if let fileWrappers = self.documentFileWrapper.fileWrappers {
            try _loadCollectionData(from: fileWrappers)
        }
    }

    fileprivate func _loadCollectionData(from fileWrappers: [String: FileWrapper]) throws {
        do {
            // We load the data if the sugar is defined
            if metadata.sugar != Default.NO_SUGAR {
                // ##############
                // # BSFS DATA
                // ##############

                if let wrapper = fileWrappers[_bsfsDataFileName] {
                    if var data = wrapper.regularFileContents {
                        data = try Bartleby.cryptoDelegate.decryptData(data, useKey: metadata.sugar)
                        try bsfs.restoreStateFrom(data: data)
                    }
                } else {
                    // ERROR
                }

                // ##############
                // # Collections
                // ##############

                for metadatum in metadata.collectionsMetadata {
                    // MONOLITHIC STORAGE
                    if metadatum.storage == CollectionMetadatum.Storage.monolithicFileStorage {
                        let names = _collectionFileNames(metadatum)
                        if let wrapper = fileWrappers[names.crypted] ?? fileWrappers[names.notCrypted] {
                            let filename = wrapper.filename
                            if var collectionData = wrapper.regularFileContents {
                                if let proxy = self.collectionByName(metadatum.collectionName) {
                                    if let path = filename {
                                        if let ext = path.components(separatedBy: ".").last {
                                            let pathExtension = "." + ext
                                            if pathExtension == BartlebyDocument.DATA_EXTENSION {
                                                // Use the faster possible approach.
                                                // The resulting data is not a valid String check CryptoDelegate for details.
                                                let collectionString = try Bartleby.cryptoDelegate.decryptStringFromData(collectionData, useKey: metadata.sugar)
                                                collectionData = collectionString.data(using: .utf8) ?? Data()
                                            }
                                        }

                                        // Proxy update
                                        // We Update the proxy (that's required to preserve UI bindings)
                                        // We donnot register the instances that why we set `document` to `nil`
                                        /// When appending the content of the collection we set `commit`and `isUndoable` to false
                                        let typeName = type(of: proxy).typeName()
                                        let collection = try dynamics.deserialize(typeName: typeName, data: collectionData, document: nil)

                                        // We need to cast the dynamic type to ManagedModel & BartlebyCollection (BartlebyCollection alone is not enough)
                                        if let bartlebyCollection = collection as? ManagedModel & BartlebyCollection {
                                            proxy.replaceProxyData(bartlebyCollection.getItems())
                                        } else {
                                            throw DocumentError.collectionProxyTypeError
                                        }
                                    }
                                } else {
                                    log("attemptToLoadAnNonSupportedCollection: \(metadatum.collectionName)")
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
                for metadatum in metadata.collectionsMetadata {
                    if let proxy = self.collectionByName(metadatum.collectionName) {
                        proxy.propagate()
                    }
                }

            } else {
                log("Sugar is undefined", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
            }
        } catch {
            throw error
        }
    }

    private func _updatedFileWrappers() throws -> FileWrapper {
        send(DocumentStates.documentWillSave)
        if metadata.sugar == Default.NO_SUGAR {
            log("Sugar is undefined", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
        }
        if var fileWrappers = self.documentFileWrapper.fileWrappers {
            // ##############
            // # Metadata
            // ##############

            #if os(OSX)
                // Try to store a preferred filename
                metadata.preferredFileName = fileURL?.lastPathComponent
            #else
                // Try to store a preferred filename
                metadata.preferredFileName = fileURL.lastPathComponent
            #endif

            let metadataData = try metadata.toCryptedData()

            // Remove the previous metadata
            if let wrapper = fileWrappers[self._metadataFileName] {
                documentFileWrapper.removeFileWrapper(wrapper)
            }
            let metadataFileWrapper = FileWrapper(regularFileWithContents: metadataData)
            metadataFileWrapper.preferredFilename = _metadataFileName
            documentFileWrapper.addFileWrapper(metadataFileWrapper)

            // ##############
            // # BSFS DATA
            // ##############

            if let wrapper = fileWrappers[self._bsfsDataFileName] {
                documentFileWrapper.removeFileWrapper(wrapper)
            }

            let data = try Bartleby.cryptoDelegate.encryptData(bsfs.saveState(), useKey: metadata.sugar)
            let bsfsFileWrapper = FileWrapper(regularFileWithContents: data)
            bsfsFileWrapper.preferredFilename = _bsfsDataFileName
            documentFileWrapper.addFileWrapper(bsfsFileWrapper)

            // ##############
            // # Collections
            // ##############
            // We load the data if the sugar is defined

            if metadata.sugar != Default.NO_SUGAR {
                for metadatum: CollectionMetadatum in metadata.collectionsMetadata {
                    if !metadatum.inMemory {
                        let collectionfileName = _collectionFileNames(metadatum).crypted
                        // MONOLITHIC STORAGE
                        if metadatum.storage == CollectionMetadatum.Storage.monolithicFileStorage {
                            if var collection = self.collectionByName(metadatum.collectionName) {
                                log("\(collection.shouldBeSaved ? "Saving" : "No Need to save") \(metadatum.collectionName)")
                                if collection.shouldBeSaved {
                                    // We use multiple files
                                    // The resulting data is not a valid String check CryptoDelegate for details.
                                    let collectionString = collection.serializeToUFf8String()
                                    let collectionData = try Bartleby.cryptoDelegate.encryptStringToData(collectionString, useKey: metadata.sugar)

                                    // Remove the previous data
                                    if let wrapper = fileWrappers[collectionfileName] {
                                        documentFileWrapper.removeFileWrapper(wrapper)
                                    }

                                    let collectionFileWrapper = FileWrapper(regularFileWithContents: collectionData)
                                    collectionFileWrapper.preferredFilename = collectionfileName
                                    documentFileWrapper.addFileWrapper(collectionFileWrapper)

                                    // Reinitialize the flag
                                    collection.shouldBeSaved = false
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
                if fileWrappers[self.blocksDirectoryWrapperName] == nil {
                    let blocksFileWrapper = FileWrapper(directoryWithFileWrappers: [:])
                    blocksFileWrapper.preferredFilename = blocksDirectoryWrapperName
                    documentFileWrapper.addFileWrapper(blocksFileWrapper)
                }
            }
        }
        return documentFileWrapper
    }

    /// Returns the decrypted collection as a JSON String
    /// Can be used for debug purposes.
    ///
    /// - Returns: the Json String
    open func getCollectionsAsJSONString() -> String {
        var jsonString = ""
        jsonString += "\n{"
        for (idx, metadatum) in metadata.collectionsMetadata.enumerated() {
            if metadatum.storage == CollectionMetadatum.Storage.monolithicFileStorage {
                if let collection = self.collectionByName(metadatum.collectionName) {
                    let isLast = (idx == metadata.collectionsMetadata.count - 1)
                    let postFixedString = isLast ? "" : ",\n"
                    jsonString += "\"\(collection.d_collectionName)\" : \(collection.serializeToUFf8String())\(postFixedString)"
                }
            }
        }
        jsonString += "}\n"
        return jsonString
    }

    /// Returns invidually each entoty serialized to JSON
    ///
    /// - Returns: the collection of Entity
    open func getJSONSElements() -> [String: String] {
        var jsons = [String: String]()
        for metadatum in metadata.collectionsMetadata {
            if metadatum.storage == CollectionMetadatum.Storage.monolithicFileStorage {
                if let collection = self.collectionByName(metadatum.collectionName) {
                    for element in collection.getItems() {
                        jsons[metadatum.collectionName] = element.serializeToUFf8String()
                    }
                }
            }
        }
        return jsons
    }
}
