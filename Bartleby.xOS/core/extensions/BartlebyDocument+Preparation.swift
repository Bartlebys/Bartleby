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

    internal func _refreshProxies()throws {
        for metadatum in self.metadata.collectionsMetadata {
            if var proxy=self.collectionByName(metadatum.collectionName) {
                proxy.undoManager=self.undoManager
                proxy.document=self
            } else {
                throw DocumentError.missingCollectionProxy(collectionName: metadatum.collectionName)
            }
        }
    }


    internal func _configure(){
        Bartleby.sharedInstance.declare(self)
        addGlobalLogsObserver(self) // Add the document to globals logs observer
        self.metadata.document=self
        // Setup the spaceUID if necessary
        if (self.metadata.spaceUID==Default.NO_UID) {
            self.metadata.spaceUID=self.metadata.UID
        }

        // Setup the default collaboration server
        self.metadata.collaborationServerURL=Bartleby.configuration.API_BASE_URL

        // Configure the schemas
        self.configureSchema()

        // We want to be able to write blocks even on Document drafts.
        if  self.documentFileWrapper.fileWrappers?[self._blocksDirectoryWrapperName] == nil{
            let blocksFileWrapper=FileWrapper(directoryWithFileWrappers: [:])
            blocksFileWrapper.preferredFilename=self._blocksDirectoryWrapperName
            documentFileWrapper.addFileWrapper(blocksFileWrapper)
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
