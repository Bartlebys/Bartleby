//
//  Registry.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 16/09/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation

#if os(OSX)
    import AppKit
#else
    import UIKit
#endif

public enum RegistryError: ErrorType {
    case DuplicatedCollectionName(collectionName:String)
    case AttemptToLoadAnNonSupportedCollection(collectionName:String)
    case UnExistingCollection(collectionName:String)
    case MissingCollectionProxy(collectionName:String)
    case CollectionProxyTypeError
    case RootObjectTypeMissMatch
}


// MARK: - Equatable

func ==(lhs: Registry, rhs: Registry) -> Bool {
    return lhs.spaceUID==rhs.spaceUID
}


// MARK -


/*

A Registry stores collections of Objects in memory for high performance read and write access
(future versions may implement incremental storage, a modified collection is actually globally serialized)
The registry can be used to developp apps that performs on and off line.
In a Document based app Each document have its own Registry.
Documents can be shared between iOS, tvOS and OSX.

*/
@objc public class Registry: BXDocument {


    // To insure **cross product deserialization** of Aliases you should set up to true.
    // Eg:  "_TtGC11BartlebyKit5AliasCS_3Tag_" or "_TtGC5bsync5AliasCS_3Tag_" are transformed to "Alias<Tag>"
    // Default is True
    static public var USE_UNIVERSAL_TYPES=true

    // A notification that is sent when the registry is fully loaded.
    static let REGISTRY_DID_LOAD_NOTIFICATION="registryDidLoad"

    // The file extension for crypted data
    static let DATA_EXTENSION: String=".data"

    // The metadata file name
    private let _metadataFileName="metadata".stringByAppendingString(Registry.DATA_EXTENSION)

    // By default the registry uses Json based implementations
    // JRegistryMetadata and JSerializer

    // We use a  JRegistryMetadata
    public var registryMetadata=JRegistryMetadata()

    // The spaceUID can be shared between multiple documents-registries
    // It defines a dataSpace where user can live.
    // A user can live in one data space only.
    public var spaceUID: String {
        get {
            return self.registryMetadata.spaceUID
        }
    }

    public var currentUser: User {
        get {
            if let currentUser=self.registryMetadata.currentUser {
                return currentUser
            } else {
                return User()
            }
        }
    }

    // Set to true when the data has been loaded once or more.
    public var hasBeenLoaded: Bool=false

    // Default Serializer
    internal var _serializer=JSerializer.sharedInstance

    // Read Only public accessor
    public var serializer: Serializer {
        return _serializer
    }


    /// The underlining storage hashed by collection name
    private var _collections=Array<Collectible>()
    // The indexes
    private var _indexes=Array<String>()

    /// We store the URL of the active security bookmarks
    internal var _activeSecurityBookmarks=[NSURL]()


    // MARK : - Universal Type Name management.

    private static var _associatedTypesMap=[String:String]()

    public static func addUniversalTypeForAlias<T: Collectible>(prototype: Alias<T>) {
        let name = prototype.universalTypeName()
        Registry._associatedTypesMap[name]=NSStringFromClass(prototype.dynamicType)
    }

    /**
     Bartleby associate the types to allow serializable translitterations.
     Multiple Apps can interchange and consume Bartleby's Dynamic / Distributed Object

     - parameter universalTypeName: the universal type (e.g Alias<Tag> for _<XX>AliasCS_3Tag_)

     - throws: UniversalSerializationTypMissmatch if the Type is not correctly associated

     - returns: the adapted type name
     */
    public static func resolveTypeName(from universalTypeName: String) throws -> String {
        if universalTypeName.contains("Alias") && Registry.USE_UNIVERSAL_TYPES {
            if let name = Registry._associatedTypesMap[universalTypeName] {
                return name
            } else {
                throw BartlebyError.UniversalSerializationTypMissmatch
            }
        } else {
            // We use the standard type name
            return universalTypeName
        }
    }






    //MARK: - Centralized ObjectList By UID

    // this centralized dictionary allows to access to any referenced object by its UID
    // to resolve aliases, cross reference, it simplify instance mobility from a registry to another, etc..
    // future implementation may include extension for lazy Storage

    private static var _instancesByUID=Dictionary<String, Collectible>()


    // The number of registred object
    public static var numberOfRegistredObject: Int {
        get {
            return _instancesByUID.count
        }
    }

    /**
     Registers an instance

     - parameter instance: the Identifiable instance
     */
    public static func register<T: Collectible>(instance: T) {
        self._instancesByUID[instance.UID]=instance
    }

    /**
     UnRegisters an instance

     - parameter instance: the collectible instance
     */
    public static func unRegister<T: Collectible>(instance: T) {
        self._instancesByUID.removeValueForKey(instance.UID)
    }

    /**
     Returns the registred instance of by UID

     - parameter UID:

     - returns: the instance
     */
    public static func registredObjectByUID<T: Collectible>(UID: String) -> T? {
        return self._instancesByUID[UID] as? T
    }


    /**
     Returns the instance by its UID

     - parameter UID: needle

     - returns: the instance
     */
    static public func collectibleInstanceByUID(UID: String) -> Collectible? {
        return self._instancesByUID[UID]
    }


    /**

     This method enumerates all the object of a given type.
     The members can come from different Registries if you have multiple document opened simultaneously

     - parameter block:           the enumeration block
     */
    public static func enumerateMembersFromRegistries<T>(block:((instance: T) -> ())?) -> [T] {
        var instances=[T]()
        for (_, instance) in self._instancesByUID {
            if let o=instance as? T {
                if let block=block {
                    block(instance:o)
                }
                instances.append(o)
            }
        }
        return instances
    }



    //MARK: - Initializers


    #if os(OSX)

    required public override init() {
        super.init()
        // Setup the spaceUID if necessary
        if (self.registryMetadata.spaceUID==Default.NO_UID) {
            self.registryMetadata.spaceUID=self.registryMetadata.UID
        }
        // Setup the default collaboration server
        self.registryMetadata.collaborationServerURL=Bartleby.configuration.API_BASE_URL

        // Configure the schemas
        self.configureSchema()

        //Declare the registry
        Bartleby.sharedInstance.declare(self)
    }
    #else

    public init() {
        super.init(fileURL: NSURL())
    }

    public init(fileUrl url: NSURL) {
        super.init(fileURL: url)
        self.configureSchema()
        // Setup the default collaboration server
        self.registryMetadata.collaborationServerURL=Bartleby.configuration.API_BASE_URL
        // First registration
        Bartleby.sharedInstance.declare(self)
    }

    #endif



    //MARK: - Preparations

    /**

    In this func you should :

    #1  Define the Schema
    #2  Register the collections (by calling registerCollections())
    #3  Replace the collections proxies (if you want to use cocoa bindings)

    */
    public func configureSchema() {

    }

    public func registerCollections() throws {
        for metadatum in self.registryMetadata.collectionsMetadata {
            if let proxy=metadatum.proxy {
                self._addCollection(proxy)
                if var proxy = proxy as? CollectibleCollection {
                    self._refreshIdentifier(&proxy)
                } else {
                    throw RegistryError.CollectionProxyTypeError
                }
            } else {
                throw RegistryError.MissingCollectionProxy(collectionName: metadatum.collectionName)
            }
        }
    }

    private func _refreshProxies()throws {
        for metadatum in self.registryMetadata.collectionsMetadata {
            if var proxy=self._collectionByName(metadatum.collectionName) as? CollectibleCollection {
                self._refreshIdentifier(&proxy)
            } else {
                throw RegistryError.MissingCollectionProxy(collectionName: metadatum.collectionName)
            }
        }
    }

    private func _refreshIdentifier(inout collectionProxy: CollectibleCollection) {
        collectionProxy.undoManager=self.undoManager
        collectionProxy.spaceUID=self.spaceUID
        // @bpds Possibly a core issue Check carefully
        collectionProxy.observableByUID=self.spaceUID
    }


    // MARK: - Collections Public API

    public func getCollection<T: IterableCollectibleCollection>  () throws -> T {
        guard var collection=self._collectionByName(T.collectionName) as? T else {
            throw RegistryError.UnExistingCollection(collectionName: T.collectionName)
        }
        collection.undoManager=self.undoManager
        return collection
    }

    // MARK: Private Collections Implementation
    // Weak Casting for internal behavior
    // Those dynamic method are only used internally

    internal func _addCollection(collection: Collectible) {
        let collectionName=collection.d_collectionName
        _collections.append(collection)
        _indexes.append(collectionName)
    }


    // Any call should always be casted to a CollectibleCollection
    func _collectionByName(name: String) -> Collectible? {
        if let i=_indexes.indexOf(name) {
            return _collections[i]
        }
        return nil
    }


    #if os(OSX)


    // MARK: - NSDocument serialization / deserialization


    // MARK: SAVE
    override public func fileWrapperOfType(typeName: String) throws -> NSFileWrapper {

        self.registryWillSave()
        let fileWrapper=NSFileWrapper(directoryWithFileWrappers:[:])
        if var fileWrappers=fileWrapper.fileWrappers {

            // #1 Metadata

            var metadataNSData=self.registryMetadata.serialize()
            metadataNSData = try Bartleby.cryptoDelegate.encryptData(metadataNSData)

            // Remove the previous metadata
            if let wrapper=fileWrappers[_metadataFileName] {
                fileWrapper.removeFileWrapper(wrapper)
            }
            let metadataFileWrapper=NSFileWrapper(regularFileWithContents: metadataNSData)
            metadataFileWrapper.preferredFilename=_metadataFileName
            fileWrapper.addFileWrapper(metadataFileWrapper)

            // 2# Collections

            for metadatum: JCollectionMetadatum in self.registryMetadata.collectionsMetadata {

                if !metadatum.inMemory {
                    let collectionfileName=self._collectionFileNames(metadatum).crypted
                    // MONOLITHIC STORAGE
                    if metadatum.storage == BaseCollectionMetadatum.Storage.MonolithicFileStorage {

                        if let collection = self._collectionByName(metadatum.collectionName) as? CollectibleCollection {

                            // We use multiple files

                            var collectionData = collection.serialize()
                            collectionData = try Bartleby.cryptoDelegate.encryptData(collectionData)


                            // Remove the previous data
                            // TODO: @bpds if collection data have changed only !

                            if let wrapper=fileWrappers[collectionfileName] {
                                fileWrapper.removeFileWrapper(wrapper)
                            }

                            let collectionFileWrapper=NSFileWrapper(regularFileWithContents: collectionData)
                            collectionFileWrapper.preferredFilename=collectionfileName
                            fileWrapper.addFileWrapper(collectionFileWrapper)
                        } else {
                            // NO COLLECTION
                        }
                    } else {
                        // SQLITE
                    }

                }
            }
        }
        return fileWrapper
    }

    // MARK: LOAD
    override public func readFromFileWrapper(fileWrapper: NSFileWrapper, ofType typeName: String) throws {
        if let fileWrappers=fileWrapper.fileWrappers {

            // #1 Metadata

            let registryProxyUID=self.spaceUID // May be a proxy

            if let wrapper=fileWrappers[_metadataFileName] {
                if var metadataNSData=wrapper.regularFileContents {
                    // We use a JSerializer not self.serializer that can be different.
                    metadataNSData = try Bartleby.cryptoDelegate.decryptData(metadataNSData)
                    let r=self.serializer.deserialize(metadataNSData)
                    if let registryMetadata=r as? JRegistryMetadata {
                        self.registryMetadata=registryMetadata
                    } else {
                        // There is an error
                        bprint("ERROR \(r)", file: #file, function: #function, line: #line)
                        return
                    }
                    // IMPORTANT we swap the UID
                    let newRegistryUID=self.registryMetadata.UID
                    Bartleby.sharedInstance.replace(registryProxyUID, by: newRegistryUID)
                }
            } else {
                // ERROR
            }

            // #2 Collections

            for metadatum in self.registryMetadata.collectionsMetadata {
                // MONOLITHIC STORAGE
                if metadatum.storage == BaseCollectionMetadatum.Storage.MonolithicFileStorage {
                    let names=self._collectionFileNames(metadatum)
                    if let wrapper=fileWrappers[names.crypted] ?? fileWrappers[names.notCrypted] {
                        let filename=wrapper.filename
                        if var collectionData=wrapper.regularFileContents {
                            if let proxy=self._collectionByName(metadatum.collectionName) {
                                if let path: NSString=filename {
                                    let pathExtension="."+path.pathExtension
                                    if  pathExtension == Registry.DATA_EXTENSION {
                                        collectionData = try Bartleby.cryptoDelegate.decryptData(collectionData)
                                    }
                                    proxy.updateData(collectionData)

                                }
                            } else {
                                throw RegistryError.AttemptToLoadAnNonSupportedCollection(collectionName:metadatum.d_collectionName)
                            }
                        }
                    } else {
                        // ERROR
                    }
                } else {
                    // SQLite
                }
            }
            do {
                try self._refreshProxies()
            } catch {
                bprint("Proxies refreshing failure \(error)", file: #file, function: #function, line: #line)
            }
            self.registryDidLoad()
        }
    }

    #else


    // MARK: - iOS UIDocument serialization / deserialization

    // TODO: @bpds(#IOS) UIDocument support

    // SAVE content
    override public func contentsForType(typeName: String) throws -> AnyObject {
    return ""
    }

    // READ content
    override public func loadFromContents(contents: AnyObject, ofType typeName: String?) throws {

    }

    #endif

    /**
     Returns the collection file name

     - parameter metadatum: the collectionMetadatim

     - returns: the crypted and the non crypted file name in a tupple.
     */
    private func _collectionFileNames(metadatum: JCollectionMetadatum) -> (notCrypted: String, crypted: String) {
        let cryptedExtension=Registry.DATA_EXTENSION
        let nonCryptedExtension=".\(self.serializer.fileExtension)"
        let cryptedFileName=metadatum.collectionName.stringByAppendingString(cryptedExtension)
        let nonCryptedFileName=metadatum.collectionName.stringByAppendingString(nonCryptedExtension)
        return (notCrypted:nonCryptedFileName, crypted:cryptedFileName)
    }



    /**
     Registry did load
     */
    public func registryDidLoad() {
        self.hasBeenLoaded=true
        NSNotificationCenter.defaultCenter().postNotificationName(Registry.REGISTRY_DID_LOAD_NOTIFICATION, object: nil, userInfo: ["UID" : self.registryMetadata.UID])

    }

    /**
     Registry will save
     */
    public func registryWillSave() {

    }



}