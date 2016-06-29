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

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif


public enum RegistryError: ErrorType {
    case DuplicatedCollectionName(collectionName:String)
    case AttemptToLoadAnNonSupportedCollection(collectionName:String)
    case UnExistingCollection(collectionName:String)
    case MissingCollectionProxy(collectionName:String)
    case CollectionProxyTypeError
    case CollectionTypeError
    case RootObjectTypeMissMatch
    case InstanceNotFound
    case InstanceTypeMissMatch
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
public class Registry: BXDocument {


    // The file extension for crypted data
    static var DATA_EXTENSION: String { return (Bartleby.cryptoDelegate is NoCrypto) ? ".json" : ".data" }

    // The metadata file name
    private var _metadataFileName: String { return "metadata".stringByAppendingString(Registry.DATA_EXTENSION) }

    // By default the registry uses Json based implementations
    // JRegistryMetadata and JSerializer

    // We use a  JRegistryMetadata
    public var registryMetadata=RegistryMetadata()

    // Triggered Data is used to store data before data integration
    // If the trigger is destructive the collectible collection is set to nil
    // The key Trigger and the value any Collectible entity serialized to a dictionary representation
    internal var _triggeredDataBuffer:[Trigger:[[String : AnyObject]]]=[Trigger:[[String : AnyObject]]]()

    // The spaceUID can be shared between multiple documents-registries
    // It defines a dataSpace where user can live.
    // A user can live in one data space only.
    public var spaceUID: String {
        get {
            return self.registryMetadata.spaceUID
        }
    }

    // We use the root object UID as observationUID
    // You should have set up the rootObjectUID before any trigger emitted.
    // The triggers are observable via this UID
    public var observationUID:String{
        get{
            return self.registryMetadata.rootObjectUID
        }
    }

    /// The current document user
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

    private let _logsFileName="logs.txt"
    private var _logs:String=""

    /// The underlining storage hashed by collection name
    internal var _collections=[String:Collection]()

    /// We store the URL of the active security bookmarks
    internal var _activeSecurityBookmarks=[NSURL]()


    // MARK: Universal Type management.

    private static var _associatedTypesMap=[String:String]()

    // MARK: URI

    // The collection server base URL
    public dynamic lazy var baseURL:NSURL=Bartleby.sharedInstance.getCollaborationURLForSpaceUID(self.spaceUID)

    // The EventSource URL for Server Sent Events
    public dynamic lazy var sseURL:NSURL=NSURL(string: self.baseURL.absoluteString+"/SSETriggers?spaceUID=\(self.spaceUID)&observationUID=\(self.observationUID)&lastIndex=\(self.registryMetadata.lastIntegratedTriggerIndex)&runUID=\(Bartleby.runUID)&showDetails=false")!

    // MARK:




    /**
     Declares a collectible type with disymetric runTimeTypeName() and typeName()
     Check [JDocument] (JDocument.swift) declareTypes() for more detailled explanations.

     - parameter type: a Collectible type
     */
    public static func declareCollectibleType(type: Collectible.Type) {
        let prototype=type.init()
        let name = prototype.runTimeTypeName()
        Registry._associatedTypesMap[prototype.dynamicType.typeName()]=name
    }


    /**
     Bartleby is able to associate the types to allow translitterations

     - parameter universalTypeName: the universal typename

     - returns: the resolved type name
     */
    public static func resolveTypeName(from universalTypeName: String) -> String {
        if let name = Registry._associatedTypesMap[universalTypeName] {
            return name
        } else {
            return universalTypeName
        }
    }


    //MARK: - Centralized ObjectList By UID

    // this centralized dictionary allows to access to any referenced object by its UID
    // to resolve externalReferences, cross reference, it simplify instance mobility from a registry to another, etc..
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
     Returns the registred instance of by its UID

     - parameter UID:

     - returns: the instance
     */
    public static func registredObjectByUID<T: Collectible>(UID: String) throws-> T {
        if let instance=self._instancesByUID[UID] as? T {
            return instance
        }
        throw RegistryError.InstanceNotFound

    }



    /**
     Returns the instance by its UID

     - parameter UID: needle

     - returns: the instance
     */
    static public func collectibleInstanceByUID(UID: String) -> Collectible? {
        return self._instancesByUID[UID]
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
                if var proxy = proxy as? Collection {
                    self._addCollection(proxy)
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
            if var proxy=self._collectionByName(metadatum.collectionName) {
                self._refreshIdentifier(&proxy)
            } else {
                throw RegistryError.MissingCollectionProxy(collectionName: metadatum.collectionName)
            }
        }
    }

    private func _refreshIdentifier(inout collectionProxy: Collection) {
        collectionProxy.undoManager=self.undoManager
        collectionProxy.spaceUID=self.spaceUID
    }


    // MARK: - Collections Public API

    public func getCollection<T: CollectibleCollection>  () throws -> T {
        guard var collection=self._collectionByName(T.collectionName) as? T else {
            throw RegistryError.UnExistingCollection(collectionName: T.collectionName)
        }
        collection.undoManager=self.undoManager
        return collection
    }

    // MARK: Private Collections Implementation
    // Weak Casting for internal behavior
    // Those dynamic method are only used internally

    internal func _addCollection(collection: Collection) {
        let collectionName=collection.d_collectionName
        _collections[collectionName]=collection
    }


    // Any call should always be casted to a CollectibleCollection
    func _collectionByName(name: String) -> Collection? {
        return _collections[name]
    }


    #if os(OSX)


    // MARK: - NSDocument serialization / deserialization


    // MARK: SAVE
    override public func fileWrapperOfType(typeName: String) throws -> NSFileWrapper {

        self.registryWillSave()
        let fileWrapper=NSFileWrapper(directoryWithFileWrappers:[:])
        if var fileWrappers=fileWrapper.fileWrappers {

            // #1 Metadata
            self.registryMetadata.triggeredDataBuffer=self._dataFrom_triggeredDataBuffer() // Save the triggered Data Buffer
            var metadataNSData=self.registryMetadata.serialize()

            metadataNSData = try Bartleby.cryptoDelegate.encryptData(metadataNSData)

            // Remove the previous metadata
            if let wrapper=fileWrappers[self._metadataFileName] {
                fileWrapper.removeFileWrapper(wrapper)
            }
            let metadataFileWrapper=NSFileWrapper(regularFileWithContents: metadataNSData)
            metadataFileWrapper.preferredFilename=self._metadataFileName
            fileWrapper.addFileWrapper(metadataFileWrapper)

            // 2# Collections

            for metadatum: CollectionMetadatum in self.registryMetadata.collectionsMetadata {

                if !metadatum.inMemory {
                    let collectionfileName=self._collectionFileNames(metadatum).crypted
                    // MONOLITHIC STORAGE
                    if metadatum.storage == CollectionMetadatum.Storage.MonolithicFileStorage {

                        if let collection = self._collectionByName(metadatum.collectionName) as? CollectibleCollection {

                            // We use multiple files

                            var collectionData = collection.serialize()
                            collectionData = try Bartleby.cryptoDelegate.encryptData(collectionData)

                            // Remove the previous data
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


            // Stores the last logs in a file.

            self._logs += "{\"runUID\":\"\(Bartleby.runUID)\",\"date\":\"\(NSDate())\"}\(Bartleby.logSectionSeparator)"
            self._logs += Bartleby.bprintCollection.toJSONString() ?? ""
            let logs=NSFileWrapper(regularFileWithContents: self._logs.dataUsingEncoding(NSUTF8StringEncoding)!)
            logs.preferredFilename=self._logsFileName
            fileWrapper.addFileWrapper(logs)


        }
        return fileWrapper
    }

    // MARK: LOAD
    override public func readFromFileWrapper(fileWrapper: NSFileWrapper, ofType typeName: String) throws {
        if let fileWrappers=fileWrapper.fileWrappers {

            let registryProxyUID=self.spaceUID // May be a proxy

            // #1 Metadata

            if let wrapper=fileWrappers[_metadataFileName] {
                if var metadataNSData=wrapper.regularFileContents {
                    // We use a JSerializer not self.serializer that can be different.
                    metadataNSData = try Bartleby.cryptoDelegate.decryptData(metadataNSData)
                    let r = try Bartleby.defaultSerializer.deserialize(metadataNSData)
                    if let registryMetadata=r as? RegistryMetadata {
                        self.registryMetadata=registryMetadata
                    } else {
                        // There is an error
                        bprint("ERROR \(r)", file: #file, function: #function, line: #line)
                        return
                    }
                    // IMPORTANT we swap the UID
                    let newRegistryUID=self.registryMetadata.UID
                    Bartleby.sharedInstance.replace(registryProxyUID, by: newRegistryUID)

                    // Setup the triggered data buffer
                    self._setUp_triggeredDataBuffer(self.registryMetadata.triggeredDataBuffer)
                }
            } else {
                // ERROR
            }


            // #2 Collections

            for metadatum in self.registryMetadata.collectionsMetadata {
                // MONOLITHIC STORAGE
                if metadatum.storage == CollectionMetadatum.Storage.MonolithicFileStorage {
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
                                    try proxy.updateData(collectionData)
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

            // 3 Logs 

            if let wrapper=fileWrappers[self._logsFileName] {
                if let logsData=wrapper.regularFileContents {
                    self._logs=String(data: logsData,encoding: NSUTF8StringEncoding) ?? ""
                }
            } else {
                // ERROR
            }
            
            dispatch_async(GlobalQueue.Main.get(), {
                self.registryDidLoad()
            })
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
    private func _collectionFileNames(metadatum: CollectionMetadatum) -> (notCrypted: String, crypted: String) {
        let cryptedExtension=Registry.DATA_EXTENSION
        let nonCryptedExtension=".\(Bartleby.defaultSerializer.fileExtension)"
        let cryptedFileName=metadatum.collectionName.stringByAppendingString(cryptedExtension)
        let nonCryptedFileName=metadatum.collectionName.stringByAppendingString(nonCryptedExtension)
        return (notCrypted:nonCryptedFileName, crypted:cryptedFileName)
    }

    /**
     Registry did load
     */
    public func registryDidLoad() {
        self.hasBeenLoaded=true
    }

    /**
     Registry will save
     */
    public func registryWillSave() {
    }

    // MARK: - SSE

    // SSE server sent event source
    internal var _sse:EventSource?

    /// The online flag is driving the SSE connection process.
    public var online:Bool=false{
        willSet{
            // Transition on line
            if newValue==true && online==false{
                bprint("SSE is transitioning online",file:#file,function:#function,line:#line,category: "SSE")
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
        }
    }


    /**
     Connect to SSE
     */
    private func _connectToSSE() {
        // The connection is restricted to identified users
        // `PERMISSION_BY_IDENTIFICATION` the current user must be in the dataspace.
        LoginUser.execute(self.currentUser, withPassword: self.currentUser.password, sucessHandler: {

            let headers=HTTPManager.httpHeadersWithToken(inDataSpace: self.spaceUID, withActionName: "SSETriggers")
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
                    if let dataFromString=data?.dataUsingEncoding(NSUTF8StringEncoding){
                        if let JSONDictionary = try NSJSONSerialization.JSONObjectWithData(dataFromString, options:NSJSONReadingOptions.AllowFragments) as? [String:AnyObject] {
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

                                if let documentSelf=self as? BartlebyDocument{
                                    var triggers=[Trigger]()
                                    triggers.append(trigger)
                                    // Uses BartlebyDocument+Triggers extension.
                                    documentSelf._triggersHasBeenReceived(triggers)
                                }else{
                                    bprint("Registry is not a BartlebyDocument",file:#file,function:#function,line:#line,category: "SSE")
                                }
                                
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
    private  func _closeSSE() {
        if let sse=self._sse{
            sse.close()
            self._sse=nil
        }
    }

    // MARK: triggered data buffer serialization support 

    // To insure persistency of non integrated data.    

    private func _dataFrom_triggeredDataBuffer()->NSData?{
        // We use a super dictionary to store the Trigger as JSON as key
        // and the collectible items as value
        var superDictionary=[String:[[String : AnyObject]]]()
        for (trigger,dictionary) in self._triggeredDataBuffer{
            if let k=trigger.toJSONString(){
                superDictionary[k]=dictionary
            }
        }
        do{
            let data = try NSJSONSerialization.dataWithJSONObject(superDictionary, options:[])
            return data
        }catch{
            bprint("Serialization exception \(error)", file: #file, function: #function, line: #line, category: bprintCategoryFor(Trigger), decorative: false)
            return nil
        }
    }

    private func _setUp_triggeredDataBuffer(from:NSData?){
        if let data=from{
            do{
                if let superDictionary:[String:[[String : AnyObject]]] = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String:[[String : AnyObject]]]{
                    for (jsonTrigger,dictionary) in superDictionary{
                        if let trigger:Trigger = Mapper<Trigger>().map(jsonTrigger){
                            self._triggeredDataBuffer[trigger]=dictionary
                        }else{
                             bprint("Trigger json mapping issue \(jsonTrigger)", file: #file, function: #function, line: #line, category: bprintCategoryFor(Trigger), decorative: false)
                        }
                    }
                }
            }catch{
                bprint("Deserialization exception \(error)", file: #file, function: #function, line: #line, category: bprintCategoryFor(Trigger), decorative: false)
            }
        }
    }

    /**

     - returns: a bunch information on the current Buffer.
     */
    public func getTriggerBufferInformations()->String{

        var informations="#Triggers to be integrated \(self._triggeredDataBuffer.count)\n"
        if let document=self as? BartlebyDocument{
            // Data buffer
            for (trigger,dictionary) in self._triggeredDataBuffer {
                let s = try?NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
                let n = (s?.length ?? 0)
                informations += "\(trigger.index) \(trigger.action) \(trigger.origin ?? "" ) \(trigger.UIDS)  \(n)\n"
            }

            // Missing
            let missing=document.missingContiguousTriggersIndexes()
            informations += missing.reduce("Missing indexes (\(missing.count)): ", combine: { (string, index) -> String in
                 return "\(string) \(index)"
            })
            informations += "\n"

            // TriggerIndexes
            let triggersIndexes=self.registryMetadata.triggersIndexes

            informations += "Trigger Indexes (\(triggersIndexes.count)): "
            informations += triggersIndexes.reduce("", combine: { (string, index) -> String in
                return "\(string) \(index)"
            })
            informations += "\n"

            // Owned Indexes
            let ownedTriggersIndexes=self.registryMetadata.ownedTriggersIndexes

            informations += "Owned Indexes (\(ownedTriggersIndexes.count)): "
            informations += ownedTriggersIndexes.reduce("", combine: { (string, index) -> String in
                return "\(string) \(index)"
            })
            informations += "\n"
            informations += "Last integrated trigger Index = \(self.registryMetadata.lastIntegratedTriggerIndex)\n"

        }

        return informations
    }

}