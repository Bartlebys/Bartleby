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

   // Keep a reference to the document file Wrapper
    open var documentFileWrapper:FileWrapper=FileWrapper(directoryWithFileWrappers:[:])

    // The Document Metadata
    dynamic open var metadata=DocumentMetadata()

    // Bartleby's Synchronized File System for this document.
    open lazy var bsfs:BSFS=BSFS(in:self)

    // Hook the triggers
    public var triggerHooks=[TriggerHook]()

    // Triggered Data is used to store data before data integration
    internal var _triggeredDataBuffer:[Trigger]=[Trigger]()

    // Set to true when the data has been loaded once or more.
    open var hasBeenLoaded: Bool=false

    // An in memory flag to distinguish dotBart import case
    open var dotBart=false

    /// The underlining storage hashed by collection name
    internal var _collections=[String:BartlebyCollection]()

    /// We store the URL of the active security bookmarks
    internal var _activeSecurityBookmarks=[URL]()

    // Reachability Manager
    internal var _reachabilityManager:NetworkReachabilityManager?

    // MARK: Universal Type management.

    internal static var _associatedTypesMap=[String:String]()

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
    open dynamic lazy var sseURL:URL=URL(string: self.baseURL.absoluteString+"/SSETriggers?spaceUID=\(self.spaceUID)&observationUID=\(self.UID)&lastIndex=\(self.metadata.lastIntegratedTriggerIndex)&runUID=\(Bartleby.runUID)&showDetails=false")!

    open var synchronizationHandlers:Handlers=Handlers.withoutCompletion()

    internal var _timer:Timer?

    // MARK: - Metrics

    open dynamic var metrics=[Metrics]()

    // MARK: - Logs

    open var enableLog: Bool=true

    open var printLogsToTheConsole: Bool=false

    open var logs=[LogEntry]()

    open var logsObservers=[LogEntriesObserver]()

    // MARK: - Consignation

    /// The display duration of volatile messages
    static open let VOLATILE_DISPLAY_DURATION: Double=3

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
    }    // MARK  Universal Type Support

     open class func declareTypes() {
    }

    // MARK: - Collection Controllers

    // The initial instances are proxies
    // On document deserialization the collection are populated.

	open dynamic var blocks=BlocksManagedCollection()

	open dynamic var boxes=BoxesManagedCollection()

	open dynamic var lockers=LockersManagedCollection()

	open dynamic var nodes=NodesManagedCollection()

	open dynamic var pushOperations=PushOperationsManagedCollection()

	open dynamic var users=UsersManagedCollection()


    // MARK: - Schemas


    /**

    In this func you should :

    #1  Define the Schema
    #2  Register the collections (by calling registerCollections())
    #3  Replace the collections proxies (if you want to use cocoa bindings)

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
			try self.metadata.configureSchema(lockerDefinition)
			try self.metadata.configureSchema(nodeDefinition)
			try self.metadata.configureSchema(pushOperationDefinition)
			try self.metadata.configureSchema(userDefinition)

        }catch DocumentError.duplicatedCollectionName(let collectionName){
            self.log("Multiple Attempt to add the Collection named \(collectionName)",file:#file,function:#function,line:#line,category: Default.LOG_DEVELOPER_CATEGORY)
        }catch {
            self.log("\(error)",file:#file,function:#function,line:#line,category: Default.LOG_DEVELOPER_CATEGORY)
        }

        // #2 Registers the collections
        do{
            try self.registerCollections()
        }catch{
        }
    }



    
    // MARK: -  Entities factories

    /**
    * Creates a new user
    *
    * you should override this method to customize default (name, email, ...)
    */
    open func newUser() -> User {
        let user=User()
        user.quietChanges {
            user.password=Bartleby.randomStringWithLength(8,signs:Bartleby.configuration.PASSWORD_CHAR_CART)
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

    /**
     * Creates a new Block
     * you can override this method to customize the properties
     */
    open func newBlock() -> Block {
        let block=Block()
        block.quietChanges {
            if let creator=self.metadata.currentUser {
                block.creatorUID = creator.UID
            }
            // Become managed
            self.blocks.add(block, commit:false)
        }
        block.commitRequired() // We defer the commit to allow to take account of overriden possible changes.
        return  block
    }

    /**
     * Creates a new Box
     * you can override this method to customize the properties
     */
    open func newBox() -> Box {
        let box=Box()
        box.quietChanges {
            if let creator=self.metadata.currentUser {
                box.creatorUID = creator.UID
            }
            // Become managed
            self.boxes.add(box, commit:false)
        }
        box.commitRequired() // We defer the commit to allow to take account of overriden possible changes.
        return  box
    }

    /**
     * Creates a new Locker
     * you can override this method to customize the properties
     */
    open func newLocker() -> Locker {
        let locker=Locker()
        locker.quietChanges {
            if let creator=self.metadata.currentUser {
                locker.creatorUID = creator.UID
            }
            // Become managed
            self.lockers.add(locker, commit:false)
        }
        locker.commitRequired() // We defer the commit to allow to take account of overriden possible changes.
        return  locker
    }

    /**
     * Creates a new Node
     * you can override this method to customize the properties
     */
    open func newNode() -> Node {
        let node=Node()
        node.quietChanges {
            if let creator=self.metadata.currentUser {
                node.creatorUID = creator.UID
            }
            // Become managed
            self.nodes.add(node, commit:false)
        }
        node.commitRequired() // We defer the commit to allow to take account of overriden possible changes.
        return  node
    }

}
