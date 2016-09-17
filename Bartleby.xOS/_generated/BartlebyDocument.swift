//
//  BartlebyDocument.swift
//
//  The is the central piece of the Document oriented architecture.
//  We provide a universal implementation with conditionnal compilation
//
//  The document stores references to Bartleby's style CollectionControllers.
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

#if !USE_EMBEDDED_MODULES
import ObjectMapper
#endif



@objc(BartlebyDocument) open class BartlebyDocument : Registry {

    #if os(OSX)

    required public init() {
        super.init()
        BartlebyDocument.declareTypes()
    }

    #else

    private var _fileURL: URL

    override public init(fileURL url: URL) {
        self._fileURL = url
        super.init(fileURL: url)
        BartlebyDocument.declareTypes()
    }
    #endif


    // MARK  Universal Type Support

    override open class func declareTypes() {
        super.declareTypes()
    }


    // MARK: - Collection Controllers

    fileprivate var _KVOContext: Int = 0

    // The initial instances are proxies
    // On document deserialization the collection are populated.

	open dynamic var users=UsersCollectionController(){
		willSet{
			users.document=self
		}
	}
	
	open dynamic var lockers=LockersCollectionController(){
		willSet{
			lockers.document=self
		}
	}
	
	open dynamic var pushOperations=PushOperationsCollectionController(){
		willSet{
			pushOperations.document=self
		}
	}
	

    // MARK: - Array Controllers and automation (OSX)
 #if os(OSX) && !USE_EMBEDDED_MODULES


    // KVO
    // Those array controllers are Owned by their respective ViewControllers
    // Those view Controller are observed here to insure a consistent persitency


    open var usersArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            usersArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &self._KVOContext)
        }
        didSet{
            // Setup the Array Controller in the CollectionController
            self.users.arrayController=usersArrayController
            // Add observer
            usersArrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .new, context: &self._KVOContext)
            if let indexes=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedUsersIndexesKey] as? [Int]{
                let indexesSet = NSMutableIndexSet()
                indexes.forEach{ indexesSet.add($0) }
                self.usersArrayController?.setSelectionIndexes(indexesSet as IndexSet)
             }
        }
    }
        

    open var lockersArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            lockersArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &self._KVOContext)
        }
        didSet{
            // Setup the Array Controller in the CollectionController
            self.lockers.arrayController=lockersArrayController
            // Add observer
            lockersArrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .new, context: &self._KVOContext)
            if let indexes=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedLockersIndexesKey] as? [Int]{
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
            // Setup the Array Controller in the CollectionController
            self.pushOperations.arrayController=pushOperationsArrayController
            // Add observer
            pushOperationsArrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .new, context: &self._KVOContext)
            if let indexes=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedPushOperationsIndexesKey] as? [Int]{
                let indexesSet = NSMutableIndexSet()
                indexes.forEach{ indexesSet.add($0) }
                self.pushOperationsArrayController?.setSelectionIndexes(indexesSet as IndexSet)
             }
        }
    }
        



#endif

    // indexes persistency

    
    static open let kSelectedUsersIndexesKey="selectedUsersIndexesKey"
    static open let USERS_SELECTED_INDEXES_CHANGED_NOTIFICATION="USERS_SELECTED_INDEXES_CHANGED_NOTIFICATION"
    dynamic open var selectedUsers:[User]?{
        didSet{
            if let users = selectedUsers {
                 let indexes:[Int]=users.map({ (user) -> Int in
                    return self.users.index(where:{ return $0.UID == user.UID })!
                })
                self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedUsersIndexesKey]=indexes
                NotificationCenter.default.post(name:NSNotification.Name(rawValue:BartlebyDocument.USERS_SELECTED_INDEXES_CHANGED_NOTIFICATION), object: nil)
            }
        }
    }
    var firstSelectedUser:User? { return self.selectedUsers?.first }
        
        

    
    static open let kSelectedLockersIndexesKey="selectedLockersIndexesKey"
    static open let LOCKERS_SELECTED_INDEXES_CHANGED_NOTIFICATION="LOCKERS_SELECTED_INDEXES_CHANGED_NOTIFICATION"
    dynamic open var selectedLockers:[Locker]?{
        didSet{
            if let lockers = selectedLockers {
                 let indexes:[Int]=lockers.map({ (locker) -> Int in
                    return self.lockers.index(where:{ return $0.UID == locker.UID })!
                })
                self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedLockersIndexesKey]=indexes
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
                self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedPushOperationsIndexesKey]=indexes
                NotificationCenter.default.post(name:NSNotification.Name(rawValue:BartlebyDocument.PUSHOPERATIONS_SELECTED_INDEXES_CHANGED_NOTIFICATION), object: nil)
            }
        }
    }
    var firstSelectedPushOperation:PushOperation? { return self.selectedPushOperations?.first }
        
        




    // MARK: - Schemas

    /**

    In this func you should :

    #1  Define the Schema
    #2  Register the collections

    */
    override open func configureSchema(){

        // #1  Defines the Schema
        super.configureSchema()

        let userDefinition = CollectionMetadatum()
        userDefinition.proxy = self.users
        // By default we group the observation via the rootObjectUID
        userDefinition.collectionName = User.collectionName
        userDefinition.storage = CollectionMetadatum.Storage.monolithicFileStorage
        userDefinition.allowDistantPersistency = true
        userDefinition.inMemory = false
        

        let lockerDefinition = CollectionMetadatum()
        lockerDefinition.proxy = self.lockers
        // By default we group the observation via the rootObjectUID
        lockerDefinition.collectionName = Locker.collectionName
        lockerDefinition.storage = CollectionMetadatum.Storage.monolithicFileStorage
        lockerDefinition.allowDistantPersistency = true
        lockerDefinition.inMemory = false
        

        let pushOperationDefinition = CollectionMetadatum()
        pushOperationDefinition.proxy = self.pushOperations
        // By default we group the observation via the rootObjectUID
        pushOperationDefinition.collectionName = PushOperation.collectionName
        pushOperationDefinition.storage = CollectionMetadatum.Storage.monolithicFileStorage
        pushOperationDefinition.allowDistantPersistency = false
        pushOperationDefinition.inMemory = false
        


        // Proceed to configuration
        do{

			try self.registryMetadata.configureSchema(userDefinition)
			try self.registryMetadata.configureSchema(lockerDefinition)
			try self.registryMetadata.configureSchema(pushOperationDefinition)

        }catch RegistryError.duplicatedCollectionName(let collectionName){
            bprint("Multiple Attempt to add the Collection named \(collectionName)",file:#file,function:#function,line:#line)
        }catch {
            bprint("\(error)",file:#file,function:#function,line:#line)
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
            

        }

    }

    // MARK:  Delete currently selected items
    
    open func deleteSelectedUsers() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedUsers{
            for item in selected{
                 self.users.removeObject(item, commit:true)
            }
        }
    }
        

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
        


    #else


    #endif

    
   
    // MARK : new User facility 
    
    /**
    * Creates a new user
    * 
    * you should override this method to customize default (name, email, ...)
    * and call before returning :
    *   if(user.creatorUID != user.UID){
    *       // We don't want to add the current user to user list
    *       self.users.add(user, commit:true)
    *   }
    */
    open func newUser() -> User {
        let user=User()
        user.silentGroupedChanges {
            if let creator=self.registryMetadata.currentUser {
                user.creatorUID = creator.UID
            }else{
                // Autopoiesis.
                user.creatorUID = user.UID
            }
            user.spaceUID = self.registryMetadata.spaceUID
            user.document = self // Very important for the  document registry metadata current User
        }
        return user
    }
     
    // MARK: - Synchronization


    // The EventSource URL for Server Sent Events
    open dynamic lazy var sseURL:URL=URL(string: self.baseURL.absoluteString+"/SSETriggers?spaceUID=\(self.spaceUID)&observationUID=\(self.UID)&lastIndex=\(self.registryMetadata.lastIntegratedTriggerIndex)&runUID=\(Bartleby.runUID)&showDetails=false")!


    // The online flag is driving the "connection" process
    // It connects to the SSE and starts the supervisionLoop
    open var online:Bool=false{
        willSet{
            // Transition on line
            if newValue==true && online==false{
                self._connectToSSE()
            }
            // Transition off line
            if newValue==false && online==true{
                bprint("SSE is transitioning offline",file:#file,function:#function,line:#line,category: "SSE")
                self._closeSSE()
            }
            if newValue==online{
                bprint("Neutral online var setting",file:#file,function:#function,line:#line,category: "SSE")
            }
        }
        didSet{
            self.registryMetadata.online=online
            self.startSupervisionLoopIfNecessary()
        }
    }

    open var synchronizationHandlers:Handlers=Handlers.withoutCompletion()

    internal var _timer:Timer?


    // MARK: SSE

    // SSE server sent event source
    internal var _sse:EventSource?

    /**
     Connect to SSE
     */
    internal func _connectToSSE() {
        bprint("SSE is transitioning online",file:#file,function:#function,line:#line,category: "SSE")
        // The connection is restricted to identified users
        // `PERMISSION_BY_IDENTIFICATION` the current user must be in the dataspace.
        LoginUser.execute(self.currentUser, withPassword: self.currentUser.password, sucessHandler: {

            let headers=HTTPManager.httpHeadersWithToken(inRegistryWithUID: self.UID, withActionName: "SSETriggers")
            self._sse=EventSource(url:self.sseURL.absoluteString,headers:headers)

            bprint("Creating the event source instance: \(self.sseURL)",file:#file,function:#function,line:#line,category: "SSE")

            self._sse!.addEventListener("relay") { (id, event, data) in
                bprint("\(id) \(event) \(data)",file:#file,function:#function,line:#line,category: "SSE")

                // Parse the Data

                /*

                 ```
                 id: 1466684879     <- the Event ID
                 event: relay       <- the Event Name
                 data: {            <- the data

                 "i":1,                                                     <- the trigger index
                 "o":"MkY2NzA4MUYtRDFGQi00Qjk0LTgyNzctNDUwQThDRjZGMDU3",    <- The observation UID
                 "r":"MzY5MDA4OTYtMDUxNS00MzdFLTgzOEEtNTQ1QjU4RDc4MEY3",    <- The run UID
                 "s":"RjQ0QjU0NDMtMjE4OC00NEZBLUFFODgtRTA1MzlGN0FFMTVE",    <- The sender UID
                 "c":"users",                                               <- The collection name
                 "n":"CreateUser",                                          <- origin   : The action that have originated the trigger (optionnal)
                 "a":"ReadUserbyId",                                        <- action   : The action to be triggered
                 "u":"RjQ0QjU0NDMtMjE4OC00NEZBLUFFODgtRTA1MzlGN0FFMTVE"     <- the uids : The concerned UIDS

                 ```

                 */
                do {
                    if let dataFromString=data?.data(using: String.Encoding.utf8){
                        if let JSONDictionary = try JSONSerialization.jsonObject(with: dataFromString, options:.allowFragments) as? [String:AnyObject] {
                            if  let index:Int=JSONDictionary["i"] as? Int,
                                let observationUID:String=JSONDictionary["o"] as? String,
                                let action:String=JSONDictionary["a"] as? String,
                                let collectionName=JSONDictionary["c"] as? String,
                                let uids=JSONDictionary["u"] as? String {

                                let trigger=Trigger()
                                trigger.spaceUID=self.spaceUID

                                // Mandatory Trigger Data
                                trigger.index=index
                                trigger.observationUID=observationUID
                                trigger.action=action
                                trigger.targetCollectionName=collectionName
                                trigger.UIDS=uids

                                // Optional data
                                // That may be omitted on triggering

                                trigger.runUID=JSONDictionary["r"] as? String
                                trigger.senderUID=JSONDictionary["s"] as? String
                                trigger.origin=JSONDictionary["n"] as? String


                                var triggers=[Trigger]()
                                triggers.append(trigger)
                                // Uses BartlebyDocument+Triggers extension.
                                self._triggersHasBeenReceived(triggers)


                            }
                        }
                    }

                }catch{
                    bprint("Exception \(error) on \(id) \(event) \(data)",file:#file,function:#function,line:#line,category: "SSE")
                }
            }

        }) { (context) in
            bprint("Login failed \(context)",file:#file,function:#function,line:#line,category: "SSE")
            self.registryMetadata.online=false
        }

    }

    /**
     Closes the Server sent EventSource
     */
    internal func _closeSSE() {
        if let sse=self._sse{
            sse.close()
            self._sse=nil
        }
    }

    // MARK: triggered data buffer serialization support

    // To insure persistency of non integrated data.

    fileprivate func _dataFrom_triggeredDataBuffer()->Data?{
        // We use a super dictionary to store the Trigger as JSON as key
        // and the collectible items as value
        var superDictionary=[String:[[String : Any]]]()
        for (trigger,dictionary) in self._triggeredDataBuffer{
            if let k=trigger.toJSONString(){
                superDictionary[k]=dictionary
            }
        }
        do{
            let data = try JSONSerialization.data(withJSONObject: superDictionary, options:[])
            return data
        }catch{
            bprint("Serialization exception \(error)", file: #file, function: #function, line: #line, category: bprintCategoryFor(Trigger.self), decorative: false)
            return nil                                                                                                                   
        }
    }

    fileprivate func _setUp_triggeredDataBuffer(from:Data?){
        if let data=from{
            do{
                if let superDictionary:[String:[[String : Any]]] = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:[[String : Any]]]{
                    for (jsonTrigger,dictionary) in superDictionary{
                        if let trigger:Trigger = Mapper<Trigger>().map(jsonTrigger){
                            self._triggeredDataBuffer[trigger]=dictionary
                        }else{
                            bprint("Trigger json mapping issue \(jsonTrigger)", file: #file, function: #function, line: #line, category: bprintCategoryFor(Trigger.self), decorative: false)
                        }
                    }
                }
            }catch{
                bprint("Deserialization exception \(error)", file: #file, function: #function, line: #line, category: bprintCategoryFor(Trigger.self), decorative: false)
            }
        }
    }

    /**

     - returns: a bunch information on the current Buffer.
     */
    open func getTriggerBufferInformations()->String{

        var informations="#Triggers to be integrated \(self._triggeredDataBuffer.count)\n"

        // Data buffer
        for (trigger,dictionary) in self._triggeredDataBuffer {
            let s = try?JSONSerialization.data(withJSONObject: dictionary, options: [])
            let n = (s?.count ?? 0)
            informations += "\(trigger.index) \(trigger.action) \(trigger.origin ?? "" ) \(trigger.UIDS)  \(n)\n"
        }

        // Missing
        let missing=self.missingContiguousTriggersIndexes()
        informations += missing.reduce("Missing indexes (\(missing.count)): ", { (string, index) -> String in
            return "\(string) \(index)"
        })
        informations += "\n"

        // TriggerIndexes
        let triggersIndexes=self.registryMetadata.triggersIndexes

        informations += "Trigger Indexes (\(triggersIndexes.count)): "
        informations += triggersIndexes.reduce("", { (string, index) -> String in
            return "\(string) \(index)"
        })
        informations += "\n"

        // Owned Indexes
        let ownedTriggersIndexes=self.registryMetadata.ownedTriggersIndexes

        informations += "Owned Indexes (\(ownedTriggersIndexes.count)): "
        informations += ownedTriggersIndexes.reduce("", { (string, index) -> String in
            return "\(string) \(index)"
        })
        informations += "\n"
        informations += "Last integrated trigger Index = \(self.registryMetadata.lastIntegratedTriggerIndex)\n"


        return informations
    }




    // MARK: - Local Persistency

    #if os(OSX)


    // MARK:  NSDocument

    // MARK: Serialization
     override open func fileWrapper(ofType typeName: String) throws -> FileWrapper {

        self.registryWillSave()
        let fileWrapper=FileWrapper(directoryWithFileWrappers:[:])
        if var fileWrappers=fileWrapper.fileWrappers {

            // ##############
            // #1 Metadata
            // ##############

            // Try to store a preferred filename
            self.registryMetadata.preferredFileName=self.fileURL?.lastPathComponent
            // Save the triggered Data Buffer
            self.registryMetadata.triggeredDataBuffer=self._dataFrom_triggeredDataBuffer()
            var metadataData=self.registryMetadata.serialize()

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

            for metadatum: CollectionMetadatum in self.registryMetadata.collectionsMetadata {

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
                    if let registryMetadata=r as? RegistryMetadata {
                        self.registryMetadata=registryMetadata
                    } else {
                        // There is an error
                        bprint("ERROR \(r)", file: #file, function: #function, line: #line)
                        return
                    }
                    let registryUID=self.registryMetadata.rootObjectUID
                    Bartleby.sharedInstance.replaceRegistryUID(Default.NO_UID, by: registryUID)
                    self.registryMetadata.currentUser?.document=self

                    // Setup the triggered data buffer
                    self._setUp_triggeredDataBuffer(from:self.registryMetadata.triggeredDataBuffer)
                }
            } else {
                // ERROR
            }


            // ##############
            // #2 Collections
            // ##############

            for metadatum in self.registryMetadata.collectionsMetadata {
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
                                        if  pathExtension == Registry.DATA_EXTENSION {
                                            collectionData = try Bartleby.cryptoDelegate.decryptData(collectionData)
                                        }
                                    }
                                  let _ = try proxy.updateData(collectionData,provisionChanges: false)
                                }
                            } else {
                                throw RegistryError.attemptToLoadAnNonSupportedCollection(collectionName:metadatum.d_collectionName)
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
           
            DispatchQueue.main.async(execute: {
                self.registryDidLoad()
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
 
}
