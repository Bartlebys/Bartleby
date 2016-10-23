//
//  BartlebyDocument.swift
//
//  The is the central piece of the Document oriented architecture.
//  We provide a universal implementation with conditionnal compilation
//
//  The document stores references to Bartleby's style ManagedCollections.
//  This allow to use intensively bindings and distributed data automation.
//  With the mediation of standard Bindings approach with NSArrayControler
//
//  We prefer to centralize the complexity of data handling in the document.
//  Thats why for example we implement projectBindingsArrayController.didSet with an CGD dispatching
//  We could have set the binding programmatically in the WindowController
//  But we consider for clarity that the Storyboarded Bindings Settings should be as exhaustive as possible.
//  And the potential complexity masked.
//
//  Generated by flexions
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

@objc(BartlebyDocument) open class BartlebyDocument : BXDocument {



    //MARK: - Initializers


    #if os(OSX)

    required public override init() {
        super.init()

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

    }
    #else


    public override init(fileURL url: URL) {
        super.init(fileURL: url as URL)

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
    }

    #endif


    // The file extension for crypted data
    open static var DATA_EXTENSION: String { return (Bartleby.cryptoDelegate is NoCrypto) ? ".json" : ".data" }

    // The metadata file name
    internal var _metadataFileName: String { return "metadata" + BartlebyDocument.DATA_EXTENSION }

    // The Document Metadata
    dynamic open var metadata=DocumentMetadata()

    // Triggered Data is used to store data before data integration
    internal var _triggeredDataBuffer:[Trigger]=[Trigger]()


    // This is the BartlebyDocument UID
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

    // The online flag is driving the "connection" process
    // It connects to the SSE and starts the pushLoop
    open var online:Bool=false{
        willSet{
            // Transition on line
            if newValue==true && online==false{
                self._connectToSSE()
            }
            // Transition off line
            if newValue==false && online==true{
                self.log("SSE is transitioning offline",file:#file,function:#function,line:#line,category: "SSE")
                self._closeSSE()
            }
            if newValue==online{
                self.log("Neutral online var setting",file:#file,function:#function,line:#line,category: "SSE")
            }
        }
        didSet{
            self.metadata.online=online
            self.startPushLoopIfNecessary()
        }
    }

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
            throw BartlebyDocumentError.attemptToSetUpRootObjectUIDMoreThanOnce
        }
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

    //MARK: - Preparations


    open func registerCollections() throws {
        for metadatum in self.metadata.collectionsMetadata {
            if let proxy=metadatum.proxy {
                if var proxy = proxy as? BartlebyCollection {
                    self._addCollection(proxy)
                    self._refreshIdentifier(&proxy)
                } else {
                    throw BartlebyDocumentError.collectionProxyTypeError
                }
            } else {
                throw BartlebyDocumentError.missingCollectionProxy(collectionName: metadatum.collectionName)
            }
        }
    }

    internal func _refreshProxies()throws {
        for metadatum in self.metadata.collectionsMetadata {
            if var proxy=self.collectionByName(metadatum.collectionName) {
                self._refreshIdentifier(&proxy)
            } else {
                throw BartlebyDocumentError.missingCollectionProxy(collectionName: metadatum.collectionName)
            }
        }
    }

    fileprivate func _refreshIdentifier(_ collectionProxy: inout BartlebyCollection) {
        collectionProxy.undoManager=self.undoManager
        collectionProxy.document=self
    }


    // MARK: - Collections Public API

    open func getCollection<T: CollectibleCollection>  () throws -> T {
        guard var collection=self.collectionByName(T.collectionName) as? T else {
            throw BartlebyDocumentError.unExistingCollection(collectionName: T.collectionName)
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
        let cryptedExtension=BartlebyDocument.DATA_EXTENSION
        let nonCryptedExtension=".\(Bartleby.defaultSerializer.fileExtension)"
        let cryptedFileName=metadatum.collectionName + cryptedExtension
        let nonCryptedFileName=metadatum.collectionName + nonCryptedExtension
        return (notCrypted:nonCryptedFileName, crypted:cryptedFileName)
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


    // MARK : new User facility

    /**
    * Creates a new user
    *
    * you should override this method to customize default (name, email, ...)
    */
    open func newUser() -> User {
        let user=User()
        user.silentGroupedChanges {
            if let creator=self.metadata.currentUser {
                user.creatorUID = creator.UID
            }else{
                // Autopoiesis.
                user.creatorUID = user.UID
            }
            user.spaceUID = self.metadata.spaceUID
            if(user.creatorUID != user.UID){
                // We don't want to add the Document's current user
                self.users.add(user, commit:false)
            }else{
                user.document = self
            }
        }
        user.commitRequired()// We defer the commit to allow to take account of overriden possible changes.
        return user
    }

    // MARK: - Synchronization

    // SSE server sent event source
    internal var _sse:EventSource?

    // The EventSource URL for Server Sent Events
    open dynamic lazy var sseURL:URL=URL(string: self.baseURL.absoluteString+"/SSETriggers?spaceUID=\(self.spaceUID)&observationUID=\(self.UID)&lastIndex=\(self.metadata.lastIntegratedTriggerIndex)&runUID=\(Bartleby.runUID)&showDetails=false")!

    open var synchronizationHandlers:Handlers=Handlers.withoutCompletion()

    internal var _timer:Timer?

    // MARK: - Local Persistency

#if os(OSX)


    // MARK:  NSDocument

    // MARK: Serialization
     override open func fileWrapper(ofType typeName: String) throws -> FileWrapper {

        self.documentWillSave()
        let fileWrapper=FileWrapper(directoryWithFileWrappers:[:])
        if var fileWrappers=fileWrapper.fileWrappers {

            // ##############
            // #1 Metadata
            // ##############

            // Try to store a preferred filename
            self.metadata.preferredFileName=self.fileURL?.lastPathComponent
            var metadataData=self.metadata.serialize()

            metadataData = try Bartleby.cryptoDelegate.encryptData(metadataData)

            // Remove the previous metadata
            if let wrapper=fileWrappers[self._metadataFileName] {
                fileWrapper.removeFileWrapper(wrapper)
            }
            let metadataFileWrapper=FileWrapper(regularFileWithContents: metadataData)
            metadataFileWrapper.preferredFilename=self._metadataFileName
            fileWrapper.addFileWrapper(metadataFileWrapper)

            // ##############
            // #2 Collections
            // ##############

            for metadatum: CollectionMetadatum in self.metadata.collectionsMetadata {

                if !metadatum.inMemory {
                    let collectionfileName=self._collectionFileNames(metadatum).crypted
                    // MONOLITHIC STORAGE
                    if metadatum.storage == CollectionMetadatum.Storage.monolithicFileStorage {

                        if let collection = self.collectionByName(metadatum.collectionName) as? CollectibleCollection {

                            // We use multiple files

                            var collectionData = collection.serialize()
                            collectionData = try Bartleby.cryptoDelegate.encryptData(collectionData)

                            // Remove the previous data
                            if let wrapper=fileWrappers[collectionfileName] {
                                fileWrapper.removeFileWrapper(wrapper)
                            }

                            let collectionFileWrapper=FileWrapper(regularFileWithContents: collectionData)
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

    // MARK: Deserialization


    /**
     Standard Bundles loading

     - parameter fileWrapper: the file wrapper
     - parameter typeName:    the type name

     - throws: misc exceptions
     */
    override open func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
        if let fileWrappers=fileWrapper.fileWrappers {

            // ##############
            // #1 Metadata
            // ##############

            if let wrapper=fileWrappers[_metadataFileName] {
                if var metadataData=wrapper.regularFileContents {
                    metadataData = try Bartleby.cryptoDelegate.decryptData(metadataData)
                    let r = try Bartleby.defaultSerializer.deserialize(metadataData)
                    if let metadata=r as? DocumentMetadata {
                        self.metadata=metadata
                    } else {
                        // There is an error
                        self.log("ERROR \(r)", file: #file, function: #function, line: #line)
                        return
                    }
                    let documentUID=self.metadata.rootObjectUID
                    Bartleby.sharedInstance.replaceDocumentUID(Default.NO_UID, by: documentUID)
                    self.metadata.currentUser?.document=self
                }
            } else {
                // ERROR
            }


            // ##############
            // #2 Collections
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
                                            collectionData = try Bartleby.cryptoDelegate.decryptData(collectionData)
                                        }
                                    }
                                  let _ = try proxy.updateData(collectionData,provisionChanges: false)
                                }
                            } else {
                                throw BartlebyDocumentError.attemptToLoadAnNonSupportedCollection(collectionName:metadatum.d_collectionName)
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
                self.log("Proxies refreshing failure \(error)", file: #file, function: #function, line: #line)
            }

            DispatchQueue.main.async(execute: {
                self.documentDidLoad()
            })
        }
    }

#else

    // MARK: iOS UIDocument serialization / deserialization

    // TODO: @bpds(#IOS) UIDocument support

    // SAVE content
    override open func contents(forType typeName: String) throws -> Any {
        return ""
    }

    // READ content
    open override func load(fromContents contents: Any, ofType typeName: String?) throws {

    }

#endif

    // MARK: - Consignation

    /// The display duration of volatile messages
    static open let VOLATILE_DISPLAY_DURATION: Double=3

    // MARK:  Simple stack management

    open var trackingIsEnabled: Bool=false

    open var glogTrackedEntries: Bool=false

    open var trackingStack=[(result:Any?, context:Consignable)]()
    // MARK  Universal Type Support

     open class func declareTypes() {
    }


	// MARK: Logs
	open var enableLog: Bool=true
	open var printLogsToTheConsole: Bool=false
	open var logs=[LogEntry]()
	open var logsObservers=[LogEntriesObserver]()

    // MARK: - Collection Controllers

    fileprivate var _KVOContext: Int = 0

    // The initial instances are proxies
    // On document deserialization the collection are populated.

	open dynamic var lockers=LockersManagedCollection(){
		willSet{
			lockers.document=self
		}
	}
	
	open dynamic var pushOperations=PushOperationsManagedCollection(){
		willSet{
			pushOperations.document=self
		}
	}
	
	open dynamic var users=UsersManagedCollection(){
		willSet{
			users.document=self
		}
	}
	
    // MARK: - Array Controllers and automation (OSX)
 #if os(OSX) && !USE_EMBEDDED_MODULES


    // KVO
    // Those array controllers are Owned by their respective ViewControllers
    // Those view Controller are observed here to insure a consistent persitency


    open var lockersArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            lockersArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &self._KVOContext)
        }
        didSet{
            // Setup the Array Controller in the ManagedCollection
            self.lockers.arrayController=lockersArrayController
            // Add observer
            lockersArrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .new, context: &self._KVOContext)
            if let indexes=self.metadata.stateDictionary[BartlebyDocument.kSelectedLockersIndexesKey] as? [Int]{
                let indexesSet = NSMutableIndexSet()
                indexes.forEach{ indexesSet.add($0) }
                self.lockersArrayController?.setSelectionIndexes(indexesSet as IndexSet)
             }
        }
    }
        
    open var pushOperationsArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            pushOperationsArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &self._KVOContext)
        }
        didSet{
            // Setup the Array Controller in the ManagedCollection
            self.pushOperations.arrayController=pushOperationsArrayController
            // Add observer
            pushOperationsArrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .new, context: &self._KVOContext)
            if let indexes=self.metadata.stateDictionary[BartlebyDocument.kSelectedPushOperationsIndexesKey] as? [Int]{
                let indexesSet = NSMutableIndexSet()
                indexes.forEach{ indexesSet.add($0) }
                self.pushOperationsArrayController?.setSelectionIndexes(indexesSet as IndexSet)
             }
        }
    }
        
    open var usersArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            usersArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &self._KVOContext)
        }
        didSet{
            // Setup the Array Controller in the ManagedCollection
            self.users.arrayController=usersArrayController
            // Add observer
            usersArrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .new, context: &self._KVOContext)
            if let indexes=self.metadata.stateDictionary[BartlebyDocument.kSelectedUsersIndexesKey] as? [Int]{
                let indexesSet = NSMutableIndexSet()
                indexes.forEach{ indexesSet.add($0) }
                self.usersArrayController?.setSelectionIndexes(indexesSet as IndexSet)
             }
        }
    }
        


#endif

    // indexes persistency

    
    static open let kSelectedLockersIndexesKey="selectedLockersIndexesKey"
    static open let LOCKERS_SELECTED_INDEXES_CHANGED_NOTIFICATION="LOCKERS_SELECTED_INDEXES_CHANGED_NOTIFICATION"
    dynamic open var selectedLockers:[Locker]?{
        didSet{
            if let lockers = selectedLockers {
                 let indexes:[Int]=lockers.map({ (locker) -> Int in
                    return self.lockers.index(where:{ return $0.UID == locker.UID })!
                })
                self.metadata.stateDictionary[BartlebyDocument.kSelectedLockersIndexesKey]=indexes
                NotificationCenter.default.post(name:NSNotification.Name(rawValue:BartlebyDocument.LOCKERS_SELECTED_INDEXES_CHANGED_NOTIFICATION), object: nil)
            }
        }
    }
    var firstSelectedLocker:Locker? { return self.selectedLockers?.first }
        
        
    
    static open let kSelectedPushOperationsIndexesKey="selectedPushOperationsIndexesKey"
    static open let PUSHOPERATIONS_SELECTED_INDEXES_CHANGED_NOTIFICATION="PUSHOPERATIONS_SELECTED_INDEXES_CHANGED_NOTIFICATION"
    dynamic open var selectedPushOperations:[PushOperation]?{
        didSet{
            if let pushOperations = selectedPushOperations {
                 let indexes:[Int]=pushOperations.map({ (pushOperation) -> Int in
                    return self.pushOperations.index(where:{ return $0.UID == pushOperation.UID })!
                })
                self.metadata.stateDictionary[BartlebyDocument.kSelectedPushOperationsIndexesKey]=indexes
                NotificationCenter.default.post(name:NSNotification.Name(rawValue:BartlebyDocument.PUSHOPERATIONS_SELECTED_INDEXES_CHANGED_NOTIFICATION), object: nil)
            }
        }
    }
    var firstSelectedPushOperation:PushOperation? { return self.selectedPushOperations?.first }
        
        
    
    static open let kSelectedUsersIndexesKey="selectedUsersIndexesKey"
    static open let USERS_SELECTED_INDEXES_CHANGED_NOTIFICATION="USERS_SELECTED_INDEXES_CHANGED_NOTIFICATION"
    dynamic open var selectedUsers:[User]?{
        didSet{
            if let users = selectedUsers {
                 let indexes:[Int]=users.map({ (user) -> Int in
                    return self.users.index(where:{ return $0.UID == user.UID })!
                })
                self.metadata.stateDictionary[BartlebyDocument.kSelectedUsersIndexesKey]=indexes
                NotificationCenter.default.post(name:NSNotification.Name(rawValue:BartlebyDocument.USERS_SELECTED_INDEXES_CHANGED_NOTIFICATION), object: nil)
            }
        }
    }
    var firstSelectedUser:User? { return self.selectedUsers?.first }
        
        
    // MARK: - Schemas


    /**

    In this func you should :

    #1  Define the Schema
    #2  Register the collections (by calling registerCollections())
    #3  Replace the collections proxies (if you want to use cocoa bindings)

    */
	open func configureSchema(){
        let lockerDefinition = CollectionMetadatum()
        lockerDefinition.proxy = self.lockers
        // By default we group the observation via the rootObjectUID
        lockerDefinition.collectionName = Locker.collectionName
        lockerDefinition.storage = CollectionMetadatum.Storage.monolithicFileStorage
        lockerDefinition.persistsDistantly = true
        lockerDefinition.inMemory = false
        
        let pushOperationDefinition = CollectionMetadatum()
        pushOperationDefinition.proxy = self.pushOperations
        // By default we group the observation via the rootObjectUID
        pushOperationDefinition.collectionName = PushOperation.collectionName
        pushOperationDefinition.storage = CollectionMetadatum.Storage.monolithicFileStorage
        pushOperationDefinition.persistsDistantly = false
        pushOperationDefinition.inMemory = false
        
        let userDefinition = CollectionMetadatum()
        userDefinition.proxy = self.users
        // By default we group the observation via the rootObjectUID
        userDefinition.collectionName = User.collectionName
        userDefinition.storage = CollectionMetadatum.Storage.monolithicFileStorage
        userDefinition.persistsDistantly = true
        userDefinition.inMemory = false
        

        // Proceed to configuration
        do{

			try self.metadata.configureSchema(lockerDefinition)
			try self.metadata.configureSchema(pushOperationDefinition)
			try self.metadata.configureSchema(userDefinition)

        }catch BartlebyDocumentError.duplicatedCollectionName(let collectionName){
            self.log("Multiple Attempt to add the Collection named \(collectionName)",file:#file,function:#function,line:#line)
        }catch {
            self.log("\(error)",file:#file,function:#function,line:#line)
        }

        // #2 Registers the collections
        do{
            try self.registerCollections()
        }catch{
        }
    }

    // MARK: - OSX specific

 #if os(OSX) && !USE_EMBEDDED_MODULES

    // MARK: KVO


    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &_KVOContext else {
            // If the context does not match, this message
            // must be intended for our superclass.
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        // We prefer to centralize the KVO for selection indexes at the top level
        if let keyPath = keyPath, let object = object {

                    
            if keyPath=="selectionIndexes" && self.lockersArrayController == object as? NSArrayController {
                if let lockers = self.lockersArrayController?.selectedObjects as? [Locker] {
                     if let selectedLocker = self.selectedLockers{
                        if selectedLocker == lockers{
                            return // No changes
                        }
                     }
                    self.selectedLockers=lockers
                }
                return
            }
            
            
            if keyPath=="selectionIndexes" && self.pushOperationsArrayController == object as? NSArrayController {
                if let pushOperations = self.pushOperationsArrayController?.selectedObjects as? [PushOperation] {
                     if let selectedPushOperation = self.selectedPushOperations{
                        if selectedPushOperation == pushOperations{
                            return // No changes
                        }
                     }
                    self.selectedPushOperations=pushOperations
                }
                return
            }
            
            
            if keyPath=="selectionIndexes" && self.usersArrayController == object as? NSArrayController {
                if let users = self.usersArrayController?.selectedObjects as? [User] {
                     if let selectedUser = self.selectedUsers{
                        if selectedUser == users{
                            return // No changes
                        }
                     }
                    self.selectedUsers=users
                }
                return
            }
            
        }

    }

    // MARK:  Delete currently selected items
        open func deleteSelectedLockers() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedLockers{
            for item in selected{
                 self.lockers.removeObject(item, commit:true)
            }
        }
    }
        
    open func deleteSelectedPushOperations() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedPushOperations{
            for item in selected{
                 self.pushOperations.removeObject(item, commit:true)
            }
        }
    }
        
    open func deleteSelectedUsers() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedUsers{
            for item in selected{
                 self.users.removeObject(item, commit:true)
            }
        }
    }
        
#else


#endif

    
    /**
     * Creates a new Locker
     * you can override this method to customize the properties
     */
    open func newLocker() -> Locker {
        let locker=Locker()
        locker.silentGroupedChanges {
            if let creator=self.metadata.currentUser {
                locker.creatorUID = creator.UID
            }
            // Become managed
            self.lockers.add(locker, commit:false)
        }
        locker.commitRequired() // We defer the commit to allow to take account of overriden possible changes.
        return  locker
    }

}
