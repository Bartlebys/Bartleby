//
//  RegistryOfCollections.swift
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

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif


public enum RegistryOfCollectionsError: Error {
    case duplicatedCollectionName(collectionName:String)
    case attemptToLoadAnNonSupportedCollection(collectionName:String)
    case unExistingCollection(collectionName:String)
    case missingCollectionProxy(collectionName:String)
    case collectionProxyTypeError
    case collectionTypeError
    case rootObjectTypeMissMatch
    case instanceNotFound
    case instanceTypeMissMatch
    case attemptToSetUpRootObjectUIDMoreThanOnce
    case unSupportedFileType(typeName:String)
}


// MARK: - Equatable

func ==(lhs: RegistryOfCollections, rhs: RegistryOfCollections) -> Bool {
    return lhs.spaceUID==rhs.spaceUID
}


public protocol DocumentProvider {
    func getDocument() -> BartlebyDocument?
}

public protocol DocumentDependent {
    var documentProvider:DocumentProvider? { get set }
}


// MARK -


/*

 A RegistryOfCollections stores collections of Objects in memory for high performance read and write access
 (future versions may implement incremental storage, a modified collection is actually globally serialized)
 Documents can be shared between iOS, tvOS and OSX.

 */
@objc(RegistryOfCollections) open class RegistryOfCollections: BXDocument {

    // The file extension for crypted data
    open static var DATA_EXTENSION: String { return (Bartleby.cryptoDelegate is NoCrypto) ? ".json" : ".data" }

    // The metadata file name
    internal var _metadataFileName: String { return "metadata" + RegistryOfCollections.DATA_EXTENSION }

    // The Document Metadata
    dynamic open var metadata=DocumentMetadata(){
        didSet{
            metadata.document=self as? BartlebyDocument
        }
    }
    // Triggered Data is used to store data before data integration
    internal var _triggeredDataBuffer:[Trigger]=[Trigger]()


    // This is the RegistryOfCollections UID
    // We use the root object UID as observationUID
    // You should have set up the rootObjectUID before any trigger emitted.
    // The triggers are observable via this UID
    open var UID:String{
        get{
            return self.metadata.rootObjectUID
        }
    }

    // The spaceUID can be shared between multiple documents-registries
    // It defines a dataSpace in wich a user can perform operations.
    // A user can `live` in one data space only.
    open var spaceUID: String {
        get {
            return self.metadata.spaceUID
        }
    }


    /// The current document user
    open var currentUser: User {
        get {
            if let currentUser=self.metadata.currentUser {
                return currentUser
            } else {
                return User()
            }
        }
    }

    // Set to true when the data has been loaded once or more.
    open var hasBeenLoaded: Bool=false

    // An in memory flag to distinguish dotBart import case
    open var dotBart=false

    /// The underlining storage hashed by collection name
    internal var _collections=[String:BartlebyCollection]()

    /// We store the URL of the active security bookmarks
    internal var _activeSecurityBookmarks=[URL]()


    // MARK: Universal Type management.

    fileprivate static var _associatedTypesMap=[String:String]()

    // MARK: URI

    // The collection server base URL
    open dynamic lazy var baseURL:URL=Bartleby.sharedInstance.getCollaborationURL(self.UID)

    // Used by BartlebyDocument+Triggers to
    open var online:Bool=false


    // MARK:

    /**
     Sets the root object UID.
     The previsou

     - parameter UID: the UID

     - throws: throws value description
     */
    open func setRootObjectUID(_ UID:String) throws {
        if (self.metadata.rootObjectUID==Default.NO_UID){
            self.metadata.rootObjectUID=UID
            Bartleby.sharedInstance.replaceDocumentUID(Default.NO_UID, by: UID)
        }else{
            throw RegistryOfCollectionsError.attemptToSetUpRootObjectUIDMoreThanOnce
        }
    }



    open class func declareTypes() {
        /*
         RegistryOfCollections.declareCollectibleType(Object)
         RegistryOfCollections.declareCollectibleType(Alias<Object>)
         */
    }

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
     Eg:  "_TtGC11BartlebyKit5AliasCS_3Tag_" or "_TtGC5bsync5AliasCS_3Tag_" are transformed to "Alias<Tag>"

     To associate those disymetric type you can add the class declareTypes
     And implement typeName() and runTimeTypeName()

     ```
     public class func declareTypes() {
     RegistryOfCollections.declareCollectibleType(Object)
     RegistryOfCollections.declareCollectibleType(Alias<Object>)
     
     ```
     - parameter type: a Collectible type
     */
    open static func declareCollectibleType(_ type: Collectible.Type) {
        let prototype=type.init()
        let name = prototype.runTimeTypeName()
        RegistryOfCollections._associatedTypesMap[type(of: prototype).typeName()]=name
    }


    /**
     Bartleby is able to associate the types to allow translitterations

     - parameter universalTypeName: the universal typename

     - returns: the resolved type name
     */
    open static func resolveTypeName(from universalTypeName: String) -> String {
        if let name = RegistryOfCollections._associatedTypesMap[universalTypeName] {
            return name
        } else {
            return universalTypeName
        }
    }


    //MARK: - Initializers


    #if os(OSX)

    required public override init() {
        super.init()

        // Setup the spaceUID if necessary
        if (self.metadata.spaceUID==Default.NO_UID) {
            self.metadata.spaceUID=self.metadata.UID
        }
        // Setup the default collaboration server
        self.metadata.collaborationServerURL=Bartleby.configuration.API_BASE_URL

        // Configure the schemas
        self.configureSchema()

    }
    #else


    public override init(fileURL url: URL) {
        super.init(fileURL: url as URL)

        // Setup the spaceUID if necessary
        if (self.metadata.spaceUID==Default.NO_UID) {
            self.metadata.spaceUID=self.metadata.UID
        }

        // Setup the default collaboration server
        self.metadata.collaborationServerURL=Bartleby.configuration.API_BASE_URL

        // Configure the schemas
        self.configureSchema()
    }

    #endif


    //MARK: - Preparations

    /**

     In this func you should :

     #1  Define the Schema
     #2  Register the collections (by calling registerCollections())
     #3  Replace the collections proxies (if you want to use cocoa bindings)

     */
    open func configureSchema() {

    }

    open func registerCollections() throws {
        for metadatum in self.metadata.collectionsMetadata {
            if let proxy=metadatum.proxy {
                if var proxy = proxy as? BartlebyCollection {
                    self._addCollection(proxy)
                    self._refreshIdentifier(&proxy)
                } else {
                    throw RegistryOfCollectionsError.collectionProxyTypeError
                }
            } else {
                throw RegistryOfCollectionsError.missingCollectionProxy(collectionName: metadatum.collectionName)
            }
        }
    }

    internal func _refreshProxies()throws {
        for metadatum in self.metadata.collectionsMetadata {
            if var proxy=self.collectionByName(metadatum.collectionName) {
                self._refreshIdentifier(&proxy)
            } else {
                throw RegistryOfCollectionsError.missingCollectionProxy(collectionName: metadatum.collectionName)
            }
        }
    }

    fileprivate func _refreshIdentifier(_ collectionProxy: inout BartlebyCollection) {
        collectionProxy.undoManager=self.undoManager
        collectionProxy.document=self as? BartlebyDocument
    }


    // MARK: - Collections Public API

    open func getCollection<T: CollectibleCollection>  () throws -> T {
        guard var collection=self.collectionByName(T.collectionName) as? T else {
            throw RegistryOfCollectionsError.unExistingCollection(collectionName: T.collectionName)
        }
        collection.undoManager=self.undoManager
        return collection
    }



    /**
     Returns the collection Names.

     - returns: the names
     */
    open func getCollectionsNames()->[String]{
        return self._collections.map {$0.0}
    }

    // MARK: Private Collections Implementation
    // Weak Casting for internal behavior
    // Those dynamic method are only used internally

    internal func _addCollection(_ collection: BartlebyCollection) {
        let collectionName=collection.d_collectionName
        _collections[collectionName]=collection
    }


    // Any call should always be casted to a CollectibleCollection
    func collectionByName(_ name: String) -> BartlebyCollection? {
        if _collections.keys.contains(name){
            return _collections[name]
        }
        return nil
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
     Returns the collection file name

     - parameter metadatum: the collectionMetadatim

     - returns: the crypted and the non crypted file name in a tupple.
     */
    internal func _collectionFileNames(_ metadatum: CollectionMetadatum) -> (notCrypted: String, crypted: String) {
        let cryptedExtension=RegistryOfCollections.DATA_EXTENSION
        let nonCryptedExtension=".\(Bartleby.defaultSerializer.fileExtension)"
        let cryptedFileName=metadatum.collectionName + cryptedExtension
        let nonCryptedFileName=metadatum.collectionName + nonCryptedExtension
        return (notCrypted:nonCryptedFileName, crypted:cryptedFileName)
    }

    /**
     RegistryOfCollections did load
     */
    open func documentDidLoad() {
        self.hasBeenLoaded=true
    }

    /**
     RegistryOfCollections will save
     */
    open func documentWillSave() {

    }

}
