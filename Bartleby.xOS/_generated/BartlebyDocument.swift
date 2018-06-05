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
#endif

@objc(BartlebyDocument) open class BartlebyDocument : BXDocument,BoxDelegate {

    //MARK: - Initializers

    #if os(OSX)

    required public override init() {
        super.init()
        self._configure()
    }

    #else


    public override init(fileURL url: URL) {
        super.init(fileURL: url as URL)
        self._configure()
    }

    #endif


    // Perform cleanUp when closing a document
    public func cleanUp(){
        syncOnMain{

            self.send(DocumentStates.cleanUp)

            // Transition off line
            self.online=false

            // Boxes
            if self.metadata.cleanupBoxesWhenClosingDocument{
                self.bsfs.unMountAllBoxes()
            }

            // Security scoped urls
            self.releaseAllSecurizedURLS()

            // Unregister the instances.
            for (_ , collection) in self._collections{
                collection.superIterate({ o in
                    Bartleby.unRegister(o)
                })
            }
        }
    }

    // The document shared Serializer
    open lazy var serializer:Serializer = JSONSerializer(document: self)

    // This deserializer is replaced by your `AppDynamics` in app contexts.
    open var dynamics:Dynamics = BartlebysDynamics()

    // Keep a reference to the document file Wrapper
    open var documentFileWrapper:FileWrapper = FileWrapper(directoryWithFileWrappers:[:])

    // The Document Metadata
    @objc dynamic open var metadata = DocumentMetadata()

    // Bartleby's Synchronized File System for this document.
    public var bsfs:BSFS{
        if self._bsfs == nil{
            self._bsfs=BSFS(in:self)
        }
        return self._bsfs!
    }

    internal var _bsfs:BSFS?

    // Hook the triggers
    public var triggerHooks=[TriggerHook]()

    // Triggered Data is used to store data before data integration
    internal var _triggeredDataBuffer:[Trigger]=[Trigger]()

    // An in memory flag to distinguish dotBart import case
    open var dotBart=false

    /// The underlining storage hashed by collection name
    internal var _collections=[String:BartlebyCollection]()

    /// We store the URL of the active security bookmarks
    internal var _activeSecurityBookmarks=[String:URL]()

    // Reachability Manager
    internal var _reachabilityManager:NetworkReachabilityManager?

    // MARK: URI

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

    // MARK: - Synchronization

    // SSE server sent event source
    internal var _sse:EventSource?

    // The EventSource URL for Server Sent Events
    @objc open dynamic lazy var sseURL:URL=URL(string: self.baseURL.absoluteString+"/SSETriggers?spaceUID=\(self.spaceUID)&observationUID=\(self.UID)&lastIndex=\(self.metadata.lastIntegratedTriggerIndex)&runUID=\(Bartleby.runUID)&showDetails=false")!

    open var synchronizationHandlers:Handlers=Handlers.withoutCompletion()

    internal var _timer:Timer?

    // MARK: - Metrics

    @objc open dynamic var metrics=[Metrics]()

    // MARK: - Logs

    open var enableLog: Bool=true

    open var printLogsToTheConsole: Bool=false

    open var logs=[LogEntry]()

    open var logsObservers=[LogEntriesObserver]()

    // MARK: - Consignation

    /// The display duration of volatile messages
    public static let VOLATILE_DISPLAY_DURATION: Double=3

    // MARK:  Simple stack management

    open var trackingIsEnabled: Bool=false

    open var glogTrackedEntries: Bool=false

    open var trackingStack=[(result:Any?, context:Consignable)]()

    // MARK: - BSFS: BoxDelegate

    /// BSFS sends to BoxDelegate
    /// The delegate invokes proceed asynchronously giving the time to perform required actions
    ///
    /// - Parameter node: the node that will be moved or copied
    open func moveIsReady(node:Node,to destinationPath:String,proceed:()->()){
        // If necessary we can wait
        proceed()
    }


    /// BSFS sends to BoxDelegate
    /// The delegate invokes proceed asynchronously giving the time to perform required actions
    ///
    /// - Parameter node: the node that will be moved or copied
    open func copyIsReady(node:Node,to destinationPath:String,proceed:()->()){
        // If necessary we can wait
        proceed()
    }

    /// BSFS sends to BoxDelegate
    /// The delegate invokes proceed asynchronously giving the time to perform required actions
    ///
    /// - Parameter node: the node that will be Updated
    open func deletionIsReady(node:Node,proceed:()->()){
        // If necessary we can wait
        proceed()
    }

    /// BSFS sends to BoxDelegate
    /// The delegate invokes proceed asynchronously giving the time to perform required actions
    ///
    /// - Parameter node: the node that will be Created or Updated
    open func nodeIsReady(node: Node, proceed: () -> ()) {
        proceed()
    }

    /// Should we allow the replacement of content node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - path: the path
    ///   - accessor: the accessor
    /// - Returns: true if allowed
    open func allowReplaceContent(of node:Node, withContentAt path:String, by accessor:NodeAccessor)->Bool{
        return false // Return false by default
    }

    // MARK: - Document Messages Listeners

    fileprivate var _messageListeners=[MessageListener]()

    open func send<T:StateMessage>(_ message:T){
        for listener in self._messageListeners{
            listener.handle(message: message)
        }
    }

    open func addDocumentMessagesListener(_ listener:MessageListener){
        if !self._messageListeners.contains(where: { (l) -> Bool in
             return listener.UID == l.UID
        }){
            self._messageListeners.append(listener)
        }
    }

    open func removeDocumentMessagesListener(_ listener:MessageListener){
        if let idx = self._messageListeners.index(where: { (l) -> Bool in
            return listener.UID == l.UID
        }){
            self._messageListeners.remove(at: idx)
        }
    }

    // MARK: - Collection Controllers

    // The initial instances are proxies
    // On document deserialization the collection are populated.

	@objc open dynamic var blocks=ManagedBlocks()
	@objc open dynamic var boxes=ManagedBoxes()
	@objc open dynamic var localizedData=ManagedLocalizedData()
	@objc open dynamic var lockers=ManagedLockers()
	@objc open dynamic var nodes=ManagedNodes()
	@objc open dynamic var pushOperations=ManagedPushOperations()
	@objc open dynamic var users=ManagedUsers()

    // MARK: - Schemas

    /**

    In this func you should :

    #1  Define the Schema
    #2  Register the collections (by calling registerCollections())

    */
	open func configureSchema(){
        let blockDefinition = CollectionMetadatum()
        blockDefinition.proxy = self.blocks
        blockDefinition.collectionName = Block.collectionName
        blockDefinition.storage = CollectionMetadatum.Storage.monolithicFileStorage
        blockDefinition.persistsDistantly = true
        blockDefinition.inMemory = false
        
        let boxDefinition = CollectionMetadatum()
        boxDefinition.proxy = self.boxes
        boxDefinition.collectionName = Box.collectionName
        boxDefinition.storage = CollectionMetadatum.Storage.monolithicFileStorage
        boxDefinition.persistsDistantly = true
        boxDefinition.inMemory = false
        
        let localizedDatumDefinition = CollectionMetadatum()
        localizedDatumDefinition.proxy = self.localizedData
        localizedDatumDefinition.collectionName = LocalizedDatum.collectionName
        localizedDatumDefinition.storage = CollectionMetadatum.Storage.monolithicFileStorage
        localizedDatumDefinition.persistsDistantly = true
        localizedDatumDefinition.inMemory = false
        
        let lockerDefinition = CollectionMetadatum()
        lockerDefinition.proxy = self.lockers
        lockerDefinition.collectionName = Locker.collectionName
        lockerDefinition.storage = CollectionMetadatum.Storage.monolithicFileStorage
        lockerDefinition.persistsDistantly = true
        lockerDefinition.inMemory = false
        
        let nodeDefinition = CollectionMetadatum()
        nodeDefinition.proxy = self.nodes
        nodeDefinition.collectionName = Node.collectionName
        nodeDefinition.storage = CollectionMetadatum.Storage.monolithicFileStorage
        nodeDefinition.persistsDistantly = true
        nodeDefinition.inMemory = false
        
        let pushOperationDefinition = CollectionMetadatum()
        pushOperationDefinition.proxy = self.pushOperations
        pushOperationDefinition.collectionName = PushOperation.collectionName
        pushOperationDefinition.storage = CollectionMetadatum.Storage.monolithicFileStorage
        pushOperationDefinition.persistsDistantly = false
        pushOperationDefinition.inMemory = false
        
        let userDefinition = CollectionMetadatum()
        userDefinition.proxy = self.users
        userDefinition.collectionName = User.collectionName
        userDefinition.storage = CollectionMetadatum.Storage.monolithicFileStorage
        userDefinition.persistsDistantly = true
        userDefinition.inMemory = false
        

        // Proceed to configuration
        do{

			try self.metadata.configureSchema(blockDefinition)
			try self.metadata.configureSchema(boxDefinition)
			try self.metadata.configureSchema(localizedDatumDefinition)
			try self.metadata.configureSchema(lockerDefinition)
			try self.metadata.configureSchema(nodeDefinition)
			try self.metadata.configureSchema(pushOperationDefinition)
			try self.metadata.configureSchema(userDefinition)

        }catch DocumentError.duplicatedCollectionName(let collectionName){
            self.log("Multiple Attempt to add the Collection named \(collectionName)",file:#file,function:#function,line:#line,category: Default.LOG_WARNING)
        }catch {
            self.log("\(error)",file:#file,function:#function,line:#line,category: Default.LOG_WARNING)
        }

        // #2 Registers the collections
        do{
            try self.registerCollections()
        }catch{
        }
    }
    
    // MARK: -  Entities factories


    /// Model Factory
    /// Usage:
    /// let user=document.newManagedModel() a
    /// - Parameters
    ///     commit: should we commit the entity ?
    ///     isUndoable: is that creation undoable  ?
    /// - Returns: a Collectible Model
    open func newManagedModel<T:Collectible>(commit:Bool=true, isUndoable:Bool=true)->T{

        // User factory relies on as a special Method
        if T.typeName()=="User"{
            return self._newUser(commit:commit,isUndoable: isUndoable) as! T
        }
        // Generated UnaManaged and ManagedModel are supported
        // We prefer to crash if some tries to inject another collectible
        var instance = try! self.dynamics.newInstanceOf(T.typeName()) as! T
        self.register(instance: &instance, commit: commit, isUndoable: isUndoable)
        return  instance
    }


    ///  You can register a instance that has been created out of the Document
    ///
    /// - Parameters:
    ///   - instance: the instance
    ///   - commit: should we commit the entity ?
    ///   - isUndoable:  is that creation undoable  ?
    open func register<T:Collectible>(instance:inout T,commit:Bool=true, isUndoable:Bool=true){
        instance.quietChanges{
            instance.UID = Bartleby.createUID()
            // Do we have a collection ?
            if let collection=self.collectionByName(instance.d_collectionName){
                collection.add(instance, commit: false, isUndoable:isUndoable)
            }

            // Set up the creator
            instance.creatorUID = self.metadata.currentUserUID

            // We defer the commit to the next synchronization loop
            // to allow post instantiation modification
            if commit{
                instance.needsToBeCommitted()
            }
        }
        self.didCreate(instance)
    }


    /// The user factory
    ///
    /// - Parameters:
    ///   - commit: should we commit the user?
    ///   - isUndoable: is its creation undoable?
    /// - Returns: the created user
    internal func _newUser(commit:Bool=true,isUndoable:Bool) -> User {
        let user=User()
        user.quietChanges {
            user._id = Bartleby.createUID()
            user.password=Bartleby.randomStringWithLength(8,signs:Bartleby.configuration.PASSWORD_CHAR_CART)
            if let creator=self.metadata.currentUser {
                user.creatorUID = creator.UID
            }else{
                // Autopoiesis.
                user.creatorUID = user.UID
            }
            user.spaceUID = self.metadata.spaceUID
            self.users.add(user, commit:false,isUndoable:isUndoable )
        }
        if commit{
            user.needsToBeCommitted()
        }
        self.didCreate(user)
        return user
    }

    /// Called just after Factory Method
    /// Override this method in your document instance
    /// to perform instance customization
    ///
    /// - Parameter instance: the fresh instance
    open func didCreate(_ instance:Collectible){

    }

    /// Called just before to Erase a Collectible
    /// Related object are cleaned by the Relational logic
    /// But you may want to clean up or perform something before Erasure.
    /// Override this method in your document instance
    /// to perform associated cleaning before erasure
    ///
    /// - Parameter instance: the fresh instance
    open func willErase(_ instance:Collectible){
        if let o = instance as? Box {
            self.bsfs.unMount(boxUID: o.UID, completed: { (completed) in })
        }else if let _ = instance as? Node{
            // Cancel any pending operation
        }else if let o = instance as? Block {
            self.bsfs.deleteBlockFile(o)
        }
    }
}
