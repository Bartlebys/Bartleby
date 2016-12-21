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

        self.metadata.referentDocument = self
        self.metadata.currentUser?.referentDocument = self

        // Configure the schemas
        self.configureSchema()

        // We want to be able to write blocks even on Document drafts.
        if  self.documentFileWrapper.fileWrappers?[self.blocksDirectoryWrapperName] == nil{
            let blocksFileWrapper=FileWrapper(directoryWithFileWrappers: [:])
            blocksFileWrapper.preferredFilename=self.blocksDirectoryWrapperName
            documentFileWrapper.addFileWrapper(blocksFileWrapper)
        }
    }


    /// Registers the collections into the document
    open func registerCollections() throws {
        for metadatum in self.metadata.collectionsMetadata {
            if let proxy=metadatum.proxy {
                if let proxy = proxy as? BartlebyCollection {
                    // Reference the document
                    if let object = proxy as? ManagedModel{
                        object.referentDocument=self
                    }
                    self._addCollection(proxy)
                } else {
                    throw DocumentError.collectionProxyTypeError
                }
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
