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


    /**
     Sets the root object UID

     - parameter UID: the UID

     - throws: throws value description
     */
    open func setRootObjectUID(_ UID:String) throws {
        if (self.metadata.rootObjectUID==Default.NO_UID){
            self.metadata.rootObjectUID=UID
            Bartleby.sharedInstance.replaceDocumentUID(Default.NO_UID, by: UID)
        }else{
            throw DocumentError.attemptToSetUpRootObjectUIDMoreThanOnce
        }
    }


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
        BartlebyDocument.declareTypes()
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

    // MARK: - Types resolution

    /**
     Declares a collectible type with disymetric runTimeTypeName() and typeName()

     You can associate disymetric Type name
     For example if you create an Alias class that uses Generics
     runTimeTypeName() & typeName() can diverges.

     **IMPORTANT** You Cannot use NSecureCoding for diverging classes

     The role of declareTypes() is to declare diverging members.
     Or to produce an adaptation layer (from a type to another)

     ## Let's take an advanced example:

     ```
     public class Alias<T:Collectible>:BartlebyObject {

     override public class func typeName() -> String {
     return "Alias<\(T.typeName())>"
     }

     ```
     Let's say we instantiate an Alias<Tag>

     To insure **cross product deserialization**
     Eg:  "_TtGC11BartlebyKit5AliasCS_3Tag_" or "_TtGC5DDD5AliasCS_3Tag_" are transformed to "Alias<Tag>"

     To associate those disymetric type you can add the class declareTypes
     And implement typeName() and runTimeTypeName()

     ```
     public class func declareTypes() {
     BartlebyDocument.declareCollectibleType(Object)
     BartlebyDocument.declareCollectibleType(Alias<Object>)

     ```
     - parameter type: a Collectible type
     */
    open static func declareCollectibleType(_ type: Collectible.Type) {
        let prototype=type.init()
        let name = prototype.runTimeTypeName()
        BartlebyDocument._associatedTypesMap[type(of: prototype).typeName()]=name
    }


    /**
     Bartleby is able to associate the types to allow translitterations

     - parameter universalTypeName: the universal typename

     - returns: the resolved type name
     */
    open static func resolveTypeName(from universalTypeName: String) -> String {
        if let name = BartlebyDocument._associatedTypesMap[universalTypeName] {
            return name
        } else {
            return universalTypeName
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
