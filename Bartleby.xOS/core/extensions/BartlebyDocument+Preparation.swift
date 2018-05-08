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

extension BartlebyDocument {
    // Essential document preparation
    internal func _configure() {
        // Declare the document
        Bartleby.sharedInstance.declare(self)

        // Add the document to globals logs observer
        addGlobalLogsObserver(self)
        metadata.currentUser?.referentDocument = self

        // Configure the schemas
        configureSchema()

        // We want to be able to write blocks even on Document drafts.
        if documentFileWrapper.fileWrappers?[self.blocksDirectoryWrapperName] == nil {
            let blocksFileWrapper = FileWrapper(directoryWithFileWrappers: [:])
            blocksFileWrapper.preferredFilename = blocksDirectoryWrapperName
            documentFileWrapper.addFileWrapper(blocksFileWrapper)
        }
    }

    open func setUpDefaultMetadata() {
        // Set up the default values.
        metadata.secondaryAuthFactorRequired = !Bartleby.configuration.SECOND_AUTHENTICATION_FACTOR_IS_DISABLED
        metadata.changesAreInspectables = Bartleby.configuration.CHANGES_ARE_INSPECTABLES_BY_DEFAULT
        metadata.shouldBeOnline = Bartleby.configuration.ONLINE_BY_DEFAULT
        metadata.online = Bartleby.configuration.ONLINE_BY_DEFAULT
        metadata.pushOnChanges = Bartleby.configuration.ONLINE_BY_DEFAULT
        metadata.saveThePassword = Bartleby.configuration.SAVE_PASSWORD_BY_DEFAULT
    }

    /// Registers the collections into the document
    open func registerCollections() throws {
        for metadatum in metadata.collectionsMetadata {
            if let proxy = metadatum.proxy {
                if let proxy = proxy as? BartlebyCollection {
                    // Reference the document
                    if let object = proxy as? ManagedModel {
                        object.referentDocument = self
                    }
                    _addCollection(proxy)
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
    open func hasChanged() {
        #if os(OSX)
            updateChangeCount(NSDocument.ChangeType.changeDone)
        #else
            updateChangeCount(UIDocumentChangeKind.done)
        #endif
    }
}
