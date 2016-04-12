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
    @objc public class UniversalDocument:NSDocument{}
#else
    import UIKit
    @objc public class UniversalDocument:UIDocument{}
#endif

public enum RegistryError:ErrorType{
    case DuplicatedCollectionName(collectionName:String)
    case AttemptToLoadAnNonSupportedCollection(collectionName:String)
    case UnExistingCollection(collectionName:String)
    case MissingCollectionProxy(collectionName:String)
    case CollectionProxyTypeError
    case RootObjectTypeMissMatch
}



public enum SecurityScopedBookMarkError:ErrorType {
    // Bookmarking
    case BookMarkFailed(message:String)
    // Scoped URL
    case GetScopedURLRessourceFailed(message:String)
    case BookMarkIsStale
}



// MARK: - Equatable

func ==(lhs: Registry, rhs: Registry) -> Bool{
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
@objc public class Registry:UniversalDocument{
    
    // Should always be true
    static public var encryptedMetadata:Bool=true
    
    // Should always be true
    public var collectionsDataShouldBeCrypted:Bool=true
    
    // The standard text encoding
    private let _textEncoding=NSUTF8StringEncoding
    
    // A notification that is sent when the registry is fully loaded.
    static let REGISTRY_DID_LOAD_NOTIFICATION="registryDidLoad"

    // The file extension for crypted data
    static let CRYPTED_EXTENSION:String=".data"
    
    // The metadata file name
    private let _metadataFileName="metadata".stringByAppendingString(Registry.encryptedMetadata ? Registry.CRYPTED_EXTENSION : ".json" )
    
    // By default the registry uses Json based implementations
    // JRegistryMetadata and JSerializer
    
    // We use a  JRegistryMetadata
    public var registryMetadata=JRegistryMetadata()

    // The spaceUID can be shared between multiple documents-registries
    // It defines a dataSpace where user can live.
    // A user can live in one data space only.
    public var spaceUID:String{
        get{
            return self.registryMetadata.spaceUID
        }
    }
    
    // Set to true when the data has been loaded once or more.
    public var hasBeenLoaded:Bool=false
    
    // Default Serializer
    internal var serializer=JSerializer()
    
    /// The underlining storage hashed by collection name
    private var _collections=Array<Collectible>()
    // The indexes
    private var _indexes=Array<String>()
    
    /// We store the URL of the active security bookmarks
    private var _activeSecurityBookmarks=[NSURL]()
    
    
    //MARK: - Centralized ObjectList By UID
    
    // this centralized dictionary allows to access to any referenced object by its UID
    // to resolve aliases, cross reference, it simplify instance mobility from a registry to another, etc..
    // future implementation may include extension for lazy Storage
    
    private static var _objectByUID=Dictionary<String,Any>()
    
    /**
     Registers an instance
     
     - parameter instance: the Identifiable instance
     */
    public static func register<T:Identifiable>(instance:T){
        _objectByUID[instance.UID]=instance
    }
    
    /**
     UnRegisters an instance
     
     - parameter instance: the collectible instance
     */
    public static func unRegister<T:Identifiable>(instance:T){
        _objectByUID.removeValueForKey(instance.UID)
    }
    
    /**
     Returns the registred instance of by UID
     
     - parameter UID:
     
     - returns: the instance
     */
    public static func registredObjectByUID<T:Collectible>(UID:String)->T?{
        return _objectByUID[UID] as? T
    }
    
    /**
     Returns a descriptive string.
     
     - returns: the string
     */
    public static func dumpObjectByUID()->String{
        var result=""
        for (UID,instance) in _objectByUID{
            if let JO=instance as? JObject{
                result += "\(JO.referenceName)->\(UID)\n"
            }
        }
        return result
    }
    
    
    /**
     
     This method enumerates all the object of a given type.
     The members can come from different Registries if you have multiple document opened simultaneously
     
     - parameter block:           the enumeration block
     */
    public static func enumerateMembersFromRegistries<T>(block:((instance:T)->())?)->[T]{
        var instances=[T]()
        for (_,instance) in _objectByUID{
            if let o=instance as? T{
                if let block=block{
                    block(instance:o)
                }
                instances.append(o)
            }
        }
        return instances
    }
    
    
    
    //MARK: - Initializers
    
    
    #if os(OSX)
    
    required public override init(){
        super.init()
        // Setup the spaceUID if necessary
        if (self.registryMetadata.spaceUID==Default.NO_UID){
            self.registryMetadata.spaceUID=self.registryMetadata.UID
        }
        // Setup the default collaboration server
        self.registryMetadata.collaborationServerURL=Bartleby.DEFAULT_API_BASE_URL
        
        // Configure the schemas
        self.configureSchema()
        
        //Declare the registry
        Bartleby.sharedInstance.declare(self);
    }
    #else

    public init() {
        super.init(fileURL: NSURL())
    }
    
    public init(fileUrl url:NSURL){
        super.init(fileURL: url)
        self.configureSchema()
        // Setup the default collaboration server
        self.registryMetadata.collaborationServerURL=Bartleby.DEFAULT_API_BASE_URL
        // First registration
        Bartleby.sharedInstance.register(self);
    }
    
    #endif
    
    
    
    //MARK: - Preparations
    
    /**
    
    In this func you should :
    
    #1  Define the Schema
    #2  Register the collections (by calling registerCollections())
    #3  Replace the collections proxies (if you want to use cocoa bindings)
    
    */
    public func configureSchema(){
        
    }
    
    public func registerCollections() throws {
        for metadatum in self.registryMetadata.collectionsMetadata {
            if let proxy=metadatum.proxy{
                self._addCollection(proxy)
                if var proxy = proxy as? CollectibleCollection{
                    self._refreshIdentifier(&proxy)
                }else{
                    throw RegistryError.CollectionProxyTypeError
                }
            }else{
                throw RegistryError.MissingCollectionProxy(collectionName: metadatum.collectionName)
            }
        }
    }
    
    private func _refreshProxies()throws {
        for metadatum in self.registryMetadata.collectionsMetadata {
            if var proxy=self._collectionByName(metadatum.collectionName) as? CollectibleCollection{
                self._refreshIdentifier(&proxy)
            }else{
                throw RegistryError.MissingCollectionProxy(collectionName: metadatum.collectionName)
            }
        }
    }
    
    private func _refreshIdentifier(inout collectionProxy:CollectibleCollection){
        collectionProxy.undoManager=self.undoManager
        collectionProxy.spaceUID=self.spaceUID
        collectionProxy.observableByUID=self.spaceUID
    }
    
    
    // MARK: - Collections Public API
    
    public func getCollection<T:IterableCollectibleCollection>  () throws -> T  {
        guard var collection=self._collectionByName(T.collectionName) as? T else{
            throw RegistryError.UnExistingCollection(collectionName: T.collectionName)
        }
        collection.undoManager=self.undoManager
        return collection
    }
    
    // MARK: Private Collections Implementation
    // Weak Casting for internal behavior
    // Those dynamic method are only used internally !!!
    
    internal func _addCollection(collection:Collectible) {
        let collectionName=collection.d_collectionName
        _collections.append(collection)
        _indexes.append(collectionName)
        //Bartleby.bprint("Proxy->Adding \(collectionName) collection using \(collection.referenceName)")
    }
    
    
    // Any call should always be casted to a CollectibleCollection
    func _collectionByName(name:String)->Collectible?{
        if let i=_indexes.indexOf(name){
            return _collections[i]
        }
        return nil
    }
    
    // MARK:- Local Instance(s) URD(s) +
    
    // MARK: upsert
    
    public func upsert(instance:Collectible)->Bool{
        if let collection=self._collectionByName(instance.d_collectionName) as? CollectibleCollection {
            collection.add(instance)
            return true
        }
        return false
    }
    
    public func upsert(instances:[Collectible])->Bool{
        var result=true
        for instance in instances{
            result=result&&self.upsert(instance)
        }
        return result
    }
    
    // MARK: read
    
    
    /*
    public func readById(instanceUID:String,fromCollectionWithName:String)->Collectible?{
    if let collection=self._collectionByName(fromCollectionWithName) as? SequenceType{
    for instance in collection{
    if instance.UID==instanceUID{
    return instance
    }
    }
    }
    return nil
    }
    */
    public func readById<C:SequenceType>(instanceUID:String,fromCollection collection:C)->Collectible?{
        for instance in collection{
            if let collectible = instance as? Collectible{
                if collectible.UID==instanceUID{
                    return collectible
                }
            }
        }
        return nil
        
    }
    
    /*
    public func readByIds(instancesUIDs:[String],fromCollectionWithName:String)->[Collectible]?{
    var result=[Collectible]()
    if let collection=self._collectionByName(fromCollectionWithName) as? SequenceType{
    for instance in collection{
    if instancesUIDs.contains(instance.UID){
    result.append(instance)
    }
    }
    }
    return result
    }
    */
    
    // MARK: delete
    
    public func delete(instance:Collectible)->Bool{
        if let collection=self._collectionByName(instance.d_collectionName) as? CollectibleCollection {
            return collection.removeObject(instance)
        }
        return false
    }
    
    
    public func deleteById(instanceUID:String,fromCollectionWithName:String)->Bool{
        if let collection=self._collectionByName(fromCollectionWithName) as? CollectibleCollection {
            return collection.removeObjectWithID(instanceUID)
        }
        return false
    }
    
    public func delete(instances:[Collectible])->Bool{
        var result=true
        for instance in instances{
            result=result&&self.delete(instance)
        }
        return result
    }
    
    public func deleteByIds(instancesUIDs:[String],fromCollectionWithName:String)->Bool{
        var result=true
        for instanceUID in instancesUIDs{
            result=result&&self.deleteById(instanceUID, fromCollectionWithName: fromCollectionWithName)
        }
        return result
    }
    
    // MARK: markAsDistributed
    
    public func markAsDistributed<T:Collectible>(inout instance:T){
        instance.distributed=true
    }
    
    public func markAsDistributed<T:Collectible>(inout instances:[T]){
        for var instance in instances{
            instance.distributed=true
        }
    }
    
    // MARK: - Operations
    
    
    /**
    Pushes the operation
    
    - parameter operations: the provionned operations
    - parameter iterator:   the iteraror reference for recursive calls.
    */
    public func pushChainedOperation(operations:[Operation],inout iterator:IndexingGenerator<[Operation]>){
        if let currentOperation=iterator.next(){
            self.pushOperation(currentOperation, sucessHandler: { (context) -> () in
                if let operationDictionary=currentOperation.data{
                    if let referenceName=operationDictionary[Default.REFERENCE_NAME_KEY],
                        uid=operationDictionary[Default.UID_KEY]{
                            self.delete(currentOperation)
                            do{
                                let ic:OperationsCollectionController = try self.getCollection()
                                Bartleby.bprint("\(ic.UID)->OPCOUNT_AFTER_EXEC=\(ic.items.count) \(referenceName) \(uid)")
                            }catch{
                                Bartleby.bprint("OperationsCollectionController getCollection \(error)")
                            }
                    }
                }
                Bartleby.executeAfter(Bartleby.delayBetweenOperationsInSeconds, closure: { 
                    self.pushChainedOperation(operations, iterator: &iterator)
                })
                }, failureHandler: { (context) -> () in
                    // Stop the chain
            })
        }
    }
    
    /**
     Pushes the operations
     Is a wrapper that pushes chained operations
     - parameter operations: the operations
     */
    public func pushOperations(operations:[Operation]) {
        var iterator=operations.generate()
        self.pushChainedOperation(operations, iterator: &iterator)
    }
    
    
    
    /**
     Pushes a unique operation
     On success the operation is deleted.
     - parameter operation: the operation
     */
    public func pushOperation(operation:Operation){
        self.pushOperation(operation, sucessHandler: { (context) -> () in
            self.delete(operation)
            }) { (context) -> () in
                
        }
    }
    
    /**
     Pushes an operation with success and failure handlers
     
     - parameter operation: the operation
     - parameter success:   the success handler
     - parameter failure:   the failure handler
     */
    public func pushOperation(operation:Operation,sucessHandler success:(context:HTTPResponse)->(),failureHandler failure:(context:HTTPResponse)->()){
        if let serialized=operation.data{
            if let command=self.serializer.deserializeFromDictionary(serialized) as? JHTTPCommand{
                command.push(sucessHandler:success, failureHandler:failure)
            }else{
                //TODO: what should be done
            }
        }
    }
    
    
    /**
     
     Deletes, aggregates and generates operations to reduce the push and subscribe load.
     
     - parameter operations: the operations
     
     - returns: the reduced operations + a trigger
     */
    public func optimizeOperations(operations:[Operation])->[Operation]{
        /*
        var toBeDeleted=[Operation]()
        var groups=[String:[Operation]]()
        for operation in operations{
        
        }*/
        
        // TODO: Append a Trigger
        
        return operations
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
            if Registry.encryptedMetadata {
                metadataNSData = try Bartleby.cryptoDelegate.encryptData(metadataNSData)
            }
            // Remove the previous metadata
            if let wrapper=fileWrappers[_metadataFileName]{
                fileWrapper.removeFileWrapper(wrapper)
            }
            let metadataFileWrapper=NSFileWrapper(regularFileWithContents: metadataNSData)
            metadataFileWrapper.preferredFilename=_metadataFileName
            fileWrapper.addFileWrapper(metadataFileWrapper)
            
            
            // 2# Collections
            
            
            for metadatum:JCollectionMetadatum in self.registryMetadata.collectionsMetadata{
                
                if !metadatum.inMemory{
                    var collectionfileName:String=""
                    if self.collectionsDataShouldBeCrypted {
                        collectionfileName=self._collectionFileNames(metadatum).crypted
                    }else{
                        collectionfileName=self._collectionFileNames(metadatum).notCrypted
                    }
                    
                    // MONOLITHIC STORAGE
                    if metadatum.storage == BaseCollectionMetadatum.Storage.MonolithicFileStorage {
                        
                        if let collection = self._collectionByName(metadatum.collectionName) as? CollectibleCollection {
                            
                            //Bartleby.bprint("\(collection.UID)->Serializing \(collectionfileName)")
                            
                            // We use multiple files
                            
                            var collectionData = collection.serialize()
                            if collectionsDataShouldBeCrypted {
                                collectionData = try Bartleby.cryptoDelegate.encryptData(collectionData)
                            }
                            
                            // Remove the previous data
                            // TODO: if collection data have changed only !
                            
                            if let wrapper=fileWrappers[collectionfileName] {
                                fileWrapper.removeFileWrapper(wrapper)
                            }
                            
                            let collectionFileWrapper=NSFileWrapper(regularFileWithContents: collectionData)
                            collectionFileWrapper.preferredFilename=collectionfileName
                            fileWrapper.addFileWrapper(collectionFileWrapper)
                        }else{
                            // NO COLLECTION
                        }
                    }else {
                        // SQLITE
                    }

                }
                
            }
        }
        return fileWrapper
    }
    
    
    
    
    
    // MARK: LOAD
    override public func readFromFileWrapper(fileWrapper: NSFileWrapper, ofType typeName: String) throws {
        if let fileWrappers=fileWrapper.fileWrappers{
            
            
            // #1 Metadata
            
            let registryProxyUID=self.spaceUID // May be a proxy
            
            if let wrapper=fileWrappers[_metadataFileName] {
                if var metadataNSData=wrapper.regularFileContents{
                    // We use a JSerializer not self.serializer that can be different.
                    if Registry.encryptedMetadata {
                        metadataNSData = try Bartleby.cryptoDelegate.decryptData(metadataNSData)
                    }
                    let r=JSerializer.deserialize(metadataNSData)
                    if let registryMetadata=r as? JRegistryMetadata{
                        self.registryMetadata=registryMetadata
                    }else{
                        // There is an error
                        Bartleby.bprint("\(r)")
                        return
                    }
                    // IMPORTANT we swap the UID
                    let newRegistryUID=self.registryMetadata.UID
                    Bartleby.sharedInstance.replace(registryProxyUID, by: newRegistryUID)
                }
            }else{
                // ERROR
            }
            
            
            
            // #2 Collection.
            for metadatum in self.registryMetadata.collectionsMetadata {
                // MONOLITHIC STORAGE
                if metadatum.storage == BaseCollectionMetadatum.Storage.MonolithicFileStorage {
                    let names=self._collectionFileNames(metadatum)
                    if let wrapper=fileWrappers[names.crypted] ?? fileWrappers[names.notCrypted] {
                        let filename=wrapper.filename
                        if var collectionData=wrapper.regularFileContents{
                            if let proxy=self._collectionByName(metadatum.collectionName){
                                if let path:NSString=filename {
                                    let pathExtension="."+path.pathExtension
                                    if  pathExtension == Registry.CRYPTED_EXTENSION {
                                        collectionData = try Bartleby.cryptoDelegate.decryptData(collectionData)
                                    }
                                    proxy.patchWithSerializedData(collectionData)
                                    //Bartleby.bprint("\(proxy.UID)->Deserialized \(metadatum.collectionName)")
                                    
                                }
                            }else{
                                throw RegistryError.AttemptToLoadAnNonSupportedCollection(collectionName:metadatum.d_collectionName)
                            }
                        }
                    }else{
                        // ERROR
                    }
                }else{
                    // SQLite
                }
            }
            do{
                try self._refreshProxies()
            }catch{
                Bartleby.bprint("Proxies refreshing failure \(error)")
            }
            self.registryDidLoad()
        }
    }
    
    #else
    
    
    // MARK: - iOS UIDocument serialization / deserialization

    // TODO:UIDocument support
    
    // SAVE content
    override public func contentsForType(typeName: String) throws -> AnyObject{
    return ""
    }
    
    // READ content
    override public func loadFromContents(contents: AnyObject, ofType typeName: String?) throws{
    
    }
    
    #endif
    
    // MARK: - SANDBOXING
    // MARK: Security-Scoped Bookmarks support
    
    
    // https://developer.apple.com/library/mac/documentation/Security/Conceptual/AppSandboxDesignGuide/AppSandboxInDepth/AppSandboxInDepth.html#//apple_ref/doc/uid/TP40011183-CH3-SW16
    
    // After an explicit user intent
    // #1 scopedURL=getSecurizedURL(url, ... )
    // #2 startAccessingToSecurityScopedResourceAtURL(scopedURL)
    // ... use the resource
    // #3 stopAccessingToSecurityScopedResourceAtURL(scopedURL)
    
    
    /**
     
     Returns the securized URL
     If the Securirty scoped Bookmark do not exists, it creates one.
     You must call this method after a user explicit intent (NSOpenPanel ...)
     You cannot get security scoped bookmark for an arbritrary NSURL.
     
     NOTE : Don't forget that you must call startAccessingToSecurityScopedResourceAtURL(scopedURL) as soon as you use the URL, and stopAccessingToSecurityScopedResourceAtURL(scopedURL) as soon as you can release the resource.
     
     
     
     - parameter url:             the URL to be accessed
     - parameter appScoped:       appScoped description
     - parameter documentfileURL: documentfileURL description
     
     - throws: throws various exception (on creation, and or resolution)
     
     - returns: the securized URL
     */
    public func getSecurizedURL(url:NSURL,appScoped:Bool=false,documentfileURL:NSURL?=nil) throws ->NSURL{
        if self.securityScopedBookmarkExits(url, appScoped: false,documentfileURL:nil)==false{
            return try self.bookmarkURL(url, appScoped: false,documentfileURL:nil)
        }else{
            return try self.getSecurityScopedURLFrom(url, appScoped: false,documentfileURL:nil)
        }
    }
    
    /**
     Deletes a security scoped bookmark (e.g : when you delete a resource)
     
     - parameter url:             url description
     - parameter appScoped:       appScoped description
     - parameter documentfileURL: documentfileURL description
     */
    public func deleteSecurityScopedBookmark(url:NSURL,appScoped:Bool=false,documentfileURL:NSURL?=nil){
        if let _=url.path{
            let key=_getBookMarkKeyFor(url, appScoped: appScoped, documentfileURL: documentfileURL)
            self.registryMetadata.URLBookmarkData.removeValueForKey(key)
        }
    }
    
    /**
     Starts acessing to the securityScopedResource
     
     - parameter scopedUrl: the scopedUrl
     */
    public func startAccessingToSecurityScopedResourceAtURL(scopedUrl:NSURL){
        scopedUrl.startAccessingSecurityScopedResource()
        if _activeSecurityBookmarks.indexOf(scopedUrl)==nil{
            _activeSecurityBookmarks.append(scopedUrl)
        }
    }
    
    
    /**
     Stops to access to securityScopedResource
     
     - parameter url: the url
     */
    public func stopAccessingToSecurityScopedResourceAtURL(scopedUrl:NSURL){
        scopedUrl.stopAccessingSecurityScopedResource()
        if let idx=_activeSecurityBookmarks.indexOf(scopedUrl){
            _activeSecurityBookmarks.removeAtIndex(idx)
        }
        
    }
    
    
    
    /**
     Stops to access to all the security Scoped Resources
     */
    public func stopAccessingAllSecurityScopedResources(){
        while  let key = _activeSecurityBookmarks.first {
            stopAccessingToSecurityScopedResourceAtURL(key)
        }
    }
    
    
    //MARK: Advanced interface (can be used in special context)
    
    /**
     Creates and store for future usage a security scoped bookmark.
     
     - parameter url:       the url
     - parameter appScoped: if set to true it is an app-scoped bookmark else a document-scoped bookmark
     - parameter documentfileURL :  the document file URL if not app scoped (you can create a bookmark for another document)
     
     - returns: return the security scoped resource URL
     */
    public func bookmarkURL(url:NSURL,appScoped:Bool=false,documentfileURL:NSURL?=nil) throws -> NSURL{
        if let _=url.path{
            var shareData = try self._createDataFromBookmarkForURL(url,appScoped:appScoped,documentfileURL:documentfileURL)
            // Encode the bookmark data as a Base64 string.
            shareData=shareData.base64EncodedDataWithOptions(.EncodingEndLineWithCarriageReturn)
            let stringifyedData=String(data: shareData,encoding:NSUTF8StringEncoding)
            let key=_getBookMarkKeyFor(url, appScoped: appScoped, documentfileURL: documentfileURL)
            self.registryMetadata.URLBookmarkData[key]=stringifyedData

            #if os(OSX)
            self.updateChangeCount(NSDocumentChangeType.ChangeDone)
            #else
            self.updateChangeCount(UIDocumentChangeKind.Done)
            #endif
            return try getSecurityScopedURLFrom(url)
        }
        throw SecurityScopedBookMarkError.BookMarkFailed(message: "Invalid path Error for \(url)")
    }
    
    private func _getBookMarkKeyFor(url:NSURL,appScoped:Bool=false,documentfileURL:NSURL?=nil)->String{
        if let path=url.path{
            return "\(path)-\((appScoped ? "YES" : "NO" ))-\(documentfileURL?.path ?? Default.NO_PATH ))"
        }else{
            return Default.NO_KEY
        }
    }
    
    
    /**
     Returns the URL on success
     
     - parameter url:             the url
     - parameter appScoped:       is it appScoped?
     - parameter documentfileURL: the document file URL if not app scoped
     
     - throws: throws value description
     
     - returns: the securized URL
     */
    public func getSecurityScopedURLFrom(url:NSURL,appScoped:Bool=false,documentfileURL:NSURL?=nil)throws -> NSURL{
        if let _=url.path{
            let key=_getBookMarkKeyFor(url, appScoped: appScoped, documentfileURL: documentfileURL)
            if let stringifyedData=self.registryMetadata.URLBookmarkData[key] as? String{
                if let base64EncodedData=stringifyedData.dataUsingEncoding(NSUTF8StringEncoding){
                    if let data=NSData(base64EncodedData: base64EncodedData, options: [.IgnoreUnknownCharacters]){
                        var bookmarkIsStale:ObjCBool = false;
                        do {
                            #if os(OSX)
                            let securizedURL = try NSURL(byResolvingBookmarkData: data,
                                                         options: NSURLBookmarkResolutionOptions.WithSecurityScope, relativeToURL:  appScoped ? nil : (documentfileURL ?? self.fileURL),
                                                         bookmarkDataIsStale: &bookmarkIsStale)
                            #else
                            // (!) TODO to be qualified
                            let securizedURL = try NSURL(byResolvingBookmarkData: data,
                                                         options: NSURLBookmarkResolutionOptions.WithoutUI, relativeToURL:  appScoped ? nil : (documentfileURL ?? self.fileURL),
                                                         bookmarkDataIsStale: &bookmarkIsStale)
                        #endif
                            if (!bookmarkIsStale){
                                return securizedURL
                            }else{
                                throw SecurityScopedBookMarkError.BookMarkIsStale
                            }
                        }catch{
                            throw SecurityScopedBookMarkError.GetScopedURLRessourceFailed(message: "Error \(error)")
                        }
                    }else{
                        throw SecurityScopedBookMarkError.GetScopedURLRessourceFailed(message:"Bookmark data Base64 decoding error")
                    }
                }else{
                    throw SecurityScopedBookMarkError.GetScopedURLRessourceFailed(message:"Bookmark data deserialization error")
                }
            }else{
                throw SecurityScopedBookMarkError.GetScopedURLRessourceFailed(message:"Unable to resolve bookmark for \(url) Did you bookmark that url?")
            }
        }else{
            throw SecurityScopedBookMarkError.GetScopedURLRessourceFailed(message:"Invalid path Error for \(url)")
        }
    }
    
    
    public func securityScopedBookmarkExits(url:NSURL,appScoped:Bool=false,documentfileURL:NSURL?=nil)->Bool{
        if let _=url.path{
            let key=_getBookMarkKeyFor(url, appScoped: appScoped, documentfileURL: documentfileURL)
            let result=self.registryMetadata.URLBookmarkData.keys.contains(key)
            return result
        }
        return false
        
    }
    
    
    
    
    
    
    private func _createDataFromBookmarkForURL(fileURL:NSURL,appScoped:Bool=false,documentfileURL:NSURL?) throws -> NSData{
        do{
            #if os(OSX)
            let data = try fileURL.bookmarkDataWithOptions(NSURLBookmarkCreationOptions.WithSecurityScope,
                                                           includingResourceValuesForKeys:nil,
                                                           relativeToURL: appScoped ? nil : ( documentfileURL ?? self.fileURL ) )
            #else
            // (!) TODO to be qualified
            let data = try fileURL.bookmarkDataWithOptions(NSURLBookmarkCreationOptions.SuitableForBookmarkFile,
                                                           includingResourceValuesForKeys: nil,
                                                           relativeToURL: appScoped ? nil : ( documentfileURL ?? self.fileURL ) )

            #endif
            // Extract of : https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSURL_Class/index.html#//apple_ref/occ/instm/NSURL/bookmarkDataWithOptions:includingResourceValuesForKeys:relativeToURL:error:
            // The URL that the bookmark data will be relative to.
            // If you are creating a security-scoped bookmark to support App Sandbox, use this parameter as follows:
            //To create an app-scoped bookmark, use a value of nil.
            // To create a document-scoped bookmark, use the absolute path (despite this parameter’s name) to the document file that is to own the new security-scoped bookmark.
            return data;
        }catch{
            throw SecurityScopedBookMarkError.BookMarkFailed(message: "\(error)")
        }
    }

    
    /**
     Returns the collection file name
     
     - parameter metadatum: the collectionMetadatim
     
     - returns: the crypted and the non crypted file name in a tupple.
     */
    private func _collectionFileNames(metadatum:JCollectionMetadatum) -> (notCrypted:String,crypted:String){
        let cryptedExtension=Registry.CRYPTED_EXTENSION
        let nonCryptedExtension=".\(self.serializer.fileExtension)"
        let cryptedFileName=metadatum.collectionName.stringByAppendingString(cryptedExtension)
        let nonCryptedFileName=metadatum.collectionName.stringByAppendingString(nonCryptedExtension)
        return (notCrypted:nonCryptedFileName,crypted:cryptedFileName)
    }
    
    
    
    /**
     Registry did load
     */
    public func registryDidLoad(){
        self.hasBeenLoaded=true
        NSNotificationCenter.defaultCenter().postNotificationName(Registry.REGISTRY_DID_LOAD_NOTIFICATION, object: nil, userInfo: ["UID" : self.registryMetadata.UID])
        
    }
    
    /**
     Registry will save
     */
    public func registryWillSave(){
        
    }
    
    
    
}