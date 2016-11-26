//
//  BartlebyDocument+Preparation.swift
//  bartleby
//
//  Created by Benoit Pereira da silva on 25/11/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

#if os(OSX)
    import AppKit
#else
    import UIKit
#endif

extension BartlebyDocument{


    // Essential document preparation
    internal func _configure(){

        // Declare the document
        Bartleby.sharedInstance.declare(self)

        // Add the document to globals logs observer
        addGlobalLogsObserver(self)

        // Remap the document
        self.metadata.document=self
        self.metadata.currentUser?.document=self

        // Configure the schemas
        self.configureSchema()

        // We want to be able to write blocks even on Document drafts.
        if  self.documentFileWrapper.fileWrappers?[self._blocksDirectoryWrapperName] == nil{
            let blocksFileWrapper=FileWrapper(directoryWithFileWrappers: [:])
            blocksFileWrapper.preferredFilename=self._blocksDirectoryWrapperName
            documentFileWrapper.addFileWrapper(blocksFileWrapper)
        }
    }


    /// Registers the collections into the document
    open func registerCollections() throws {
        for metadatum in self.metadata.collectionsMetadata {
            if let proxy=metadatum.proxy {
                if var proxy = proxy as? BartlebyCollection {
                    self._addCollection(proxy)
                    proxy.undoManager=self.undoManager
                    proxy.document=self
                } else {
                    throw DocumentError.collectionProxyTypeError
                }
            } else {
                throw DocumentError.missingCollectionProxy(collectionName: metadatum.collectionName)
            }
        }
    }

    // Injects into the collections proxie the document and undoManager.
    internal func _refreshCollectionsProxies()throws {
        for metadatum in self.metadata.collectionsMetadata {
            if var proxy=self.collectionByName(metadatum.collectionName) {
                proxy.undoManager=self.undoManager
                proxy.document=self
            } else {
                throw DocumentError.missingCollectionProxy(collectionName: metadatum.collectionName)
            }
        }
    }


    /**
     Universal change
     */
    open func hasChanged() -> () {
        #if os(OSX)
            self.updateChangeCount(NSDocumentChangeType.changeDone)
        #else
            self.updateChangeCount(UIDocumentChangeKind.done)
        #endif
    }

    /**
     BartlebyDocument did load
     */
    open func documentDidLoad() {
        self.hasBeenLoaded=true
    }

    /**
     BartlebyDocument will save
     */
    open func documentWillSave() {
        
    }

}
