//
//  Bartleby.swift
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


//MARK: - Bartleby


// Bartleby's 1.0 approach is suitable for data set that can stored in memory.
open class Bartleby:NSObject,AliasResolution {

    /// The standard singleton shared instance
    open static let sharedInstance: Bartleby = {
        let instance = Bartleby()
        return instance
    }()

    static let b_version = "1.0"
    static let b_release = "0"

    open static let defaultLanguageCode = I18N.defaultLanguageCode

    /// The version string of Bartleby framework
    open static var versionString: String {
        get {
            return "\(self.b_version).\(self.b_release)"
        }
    }

    // A unique run identifier that changes each time Bartleby is launched
    open static let runUID: String=Bartleby.createUID()

    // The configuration
    public static var configuration: BartlebyConfiguration.Type=BartlebyDefaultConfiguration.self

    // The crypto delegate
    public static var cryptoDelegate: CryptoDelegate=NoCrypto()

    // The File manager
    // #TODO REMOVE BartlebyFileIO (simplification)
    public static var fileManager: BartlebyFileIO=BFileManager()

    /**
     This method should be only used to cleanup in core unit test
     */
    open func hardCoreCleanupForUnitTests() {
        self._documents=[String:BartlebyDocument]()
    }

    /**
     * When using ephemeralMode on registration Instance are marked ephemeral
     */
    open static var ephemeral=false

    open static var requestCounter=0

    /**
     Should be called on Init of the Document.
     */
    open func configureWith(_ configuration: BartlebyConfiguration.Type) {

        if configuration.DISABLE_DATA_CRYPTO {
            // Use NoCrypto a neutral crypto delegate
            Bartleby.cryptoDelegate=NoCrypto()
        } else {
            //Initialize the crypto delegate with the valid KEY & SALT
            Bartleby.cryptoDelegate=CryptoHelper(salt: configuration.SHARED_SALT,keySize:configuration.KEY_SIZE)
        }

        // Store the configuration
        Bartleby.configuration=configuration

        // Ephemeral mode.
        Bartleby.ephemeral=configuration.EPHEMERAL_MODE

        // Configure the HTTP Manager
        HTTPManager.configure()
    }

    override init() {
        super.init()
    }

    // Bartleby's favourite
    open static func please(_ message: String) -> String {
        return "I would prefer not to!"
    }

    // MARK: -
    // TODO: @md #crypto Check crypto key requirement
    public static func isValidKey(_ key: String) -> Bool {
        return key.count >= 32
    }

    // MARK: - Registries

    // Each document is a stored separately
    // Multiple documents can be openned at the same time
    // and synchronized to different Servers.
    // Bartleby supports multi-authentication and multi documents

    /// Memory storage
    fileprivate var _documents: [String:BartlebyDocument] = [String:BartlebyDocument]()


    /**
     Returns a document by its UID ( == document.metadata.persistentUID)
     The SpaceUID is shared between multiple document.

     - parameter UID: the uid of the document

     - returns: the document
     */
    open func getDocumentByUID(_ UID:UID) -> BartlebyDocument?{
        if let document = self._documents[UID]{
            return document
        }
        return nil
    }
    /**
     Registers a document

     - parameter document: the document
     */
    open func declare(_ document: BartlebyDocument) {
        self._documents[document.UID]=document
    }

    /**
     Unloads the collections

     - parameter documentUID: the target document UID
     */
    open func forget(_ documentUID: UID) {
        self._documents.removeValue(forKey: documentUID)
    }

    /**
     Replaces the UID of a proxy Document
     The proxy document is an instance that is created before to deserialize asynchronously the document Data
     Should be exclusively used when re-openning an existing document.

     - parameter documentProxyUID: the proxy UID
     - parameter documentUID:      the final UID
     */
    open func replaceDocumentUID(_ documentProxyUID: UID, by documentUID: UID) {
        if( documentProxyUID != documentUID) {
            if let document=self._documents[documentProxyUID] {
                self._documents[documentUID]=document
                self._documents.removeValue(forKey: documentProxyUID)
            }
        }
    }

    /**
     An UID generator compliant with MONGODB primary IDS constraints

     - returns: the UID
     */
    open static func createUID() -> UID {
        // (!) NSUUID are not suitable for MONGODB as Primary Ids.
        // We need to encode them we have choosen base64
        let uid=UUID().uuidString
        let utf8str = uid.data(using: Default.STRING_ENCODING)
        return utf8str!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue:0))
    }

    open static let startTime=CFAbsoluteTimeGetCurrent()

    open static var elapsedTime:Double {
        return CFAbsoluteTimeGetCurrent()-Bartleby.startTime
    }


    /**
     Returns a random string of a given size.

     - parameter len: the length
     - parameter signs: the possible signs By default We exclude possibily confusing signs "oOiI01" to make random strings less ambiguous

     - returns: the string
     */
    open static func randomStringWithLength (_ len: UInt, signs: String="abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ23456789") -> String {
        var randomString = ""
        for _ in (0 ..< len) {
            let length = UInt32 (signs.count)
            let rand = Int(arc4random_uniform(length))
            let idx = signs.index(signs.startIndex, offsetBy: rand, limitedBy:signs.endIndex)
            let c=signs[idx!]
            randomString.append(c)
        }
        return randomString
    }



    // MARK: - Paths & URL

    /**
     Returns the search path directory

     - parameter searchPath: the search Path

     - returns: the path string
     */
    open static func getSearchPath(_ searchPath: FileManager.SearchPathDirectory) -> String? {
        let urls = FileManager.default.urls(for: searchPath, in: .userDomainMask)
        if urls.count>0 {
            let path = urls[0].path
            return path
        }
        return nil
    }

    // MARK: - Maintenance

    open func destroyLocalEphemeralInstances() {
        for (dataSpaceUID, document) in self._documents {
            document.log("Destroying EphemeralInstances on \(dataSpaceUID)", file:#file, function:#function, line:#line, category: Default.LOG_DEFAULT)
            document.superIterate({ (element) in
                if element.ephemeral {
                    document.delete(element)
                }
            })
        }
    }


    //MARK: - Centralized ObjectList By UID

    // this centralized dictionary allows to access to any referenced object by its UID
    // to resolve externalReferences, cross reference, it simplify instance mobility from a Document to another, etc..
    // future implementation may include extension for lazy Storage

    fileprivate static var _instancesByUID=Dictionary<String, Collectible>()


    // The number of registred object
    open static var numberOfRegistredObject: Int {
        get {
            return _instancesByUID.count
        }
    }

    /**
     Registers an instance

     - parameter instance: the Identifiable instance
     */
    open static func register<T: Collectible>(_ instance: T) {

        // Store the instance by its UID
        self._instancesByUID[instance.UID]=instance

        // Check if some deferred Ownership has been recorded
        if let owneesUIDS = self._deferredOwnerships[instance.UID] {
            /// This situation occurs for example
            /// when the ownee has been triggered but not the owner
            // or the deserialization of the ownee preceeds the owner
            if let o=instance as? ManagedModel{
                for owneeUID in  owneesUIDS{
                    if let _ = Bartleby.registredManagedModelByUID(owneeUID){
                        // Add the owns entry
                        if !o.owns.contains(owneeUID){
                            o.owns.append(owneeUID)
                        }else{
                            print("### !")
                        }
                    }else{
                        print("----")
                        glog("Deferred ownership has failed to found \(owneeUID) for \(o.UID)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
                    }
                }
            }
            self._deferredOwnerships.removeValue(forKey: instance.UID)
        }
    }


    /**
     UnRegisters an instance

     - parameter instance: the collectible instance
     */
    open static func unRegister(_ instance: Collectible) {
        self._instancesByUID.removeValue(forKey: instance.UID)
    }

    /**
     UnRegisters an instance

     - parameter instance: the collectible instance
     */
    open static func unRegister(_ instances: [Collectible]) {
        for instance in instances{
            self._instancesByUID.removeValue(forKey: instance.UID)
        }
    }




    /**
     Returns the registred instance of by its UID

     - parameter UID:

     - returns: the instance
     */
    open static func registredObjectByUID<T: Collectible>(_ UID: UID) throws-> T {
        if let instance=self._instancesByUID[UID]{
            if let casted=instance as? T{
                return casted
            }else{
                throw DocumentError.instanceTypeMissMatch(found: instance.runTimeTypeName())
            }
        }
        throw DocumentError.instanceNotFound
    }


    /// Returns a ManagedModel by its UID
    /// Those instance are not casted.
    /// You should most of the time use : `registredObjectByUID<T: Collectible>(_ UID: String) throws-> T`
    /// - parameter UID:
    /// - returns: the instance
    open static func registredManagedModelByUID(_ UID: UID)-> ManagedModel? {
        return try? Bartleby.registredObjectByUID(UID)
    }


    /// Returns a collection of ManagedModel by UIDs
    /// Those instance are not casted.
    /// You should most of the time use : `registredObjectByUID<T: Collectible>(_ UID: String) throws-> T`
    /// - parameter UID:
    /// - returns: the instance
    open static func registredManagedModelByUIDs(_ UIDs: [UID])-> [ManagedModel]? {
        return try? Bartleby.registredObjectsByUIDs(UIDs)
    }


    ///  Returns the registred instance of by UIDs
    ///
    /// - Parameter UIDs: the UIDs
    /// - Returns: the registred Instances
    open static func registredObjectsByUIDs<T: Collectible>(_ UIDs: [UID]) throws-> [T] {
        var items=[T]()
        for UID in UIDs{
            items.append(try Bartleby.registredObjectByUID(UID))
        }
        return items
    }



    /**
     Returns the instance by its UID

     - parameter UID: needle
     î
     - returns: the instance
     */
    open static func collectibleInstanceByUID(_ UID: UID) -> Collectible? {
        return self._instancesByUID[UID]
    }


    /// Resolve the alias
    ///
    /// - Parameter alias: the alias
    /// - Returns: the reference
    open static func instance(from alias:Alias)->Aliasable?{
        return registredManagedModelByUID(alias.UID)
    }


    // MARK: - Deferred Ownwerships

    /// If we receive a Instance that refers to an unexisting Owner
    /// We store its missing entry is the deferredOwnerships dictionary
    /// For future resolution (on registration)
    /// [notAvailableOwnerUID][relatedOwnedUIDS]
    fileprivate static var _deferredOwnerships=[UID:[UID]]()



    /// Stores the ownee when the owner is not already available
    /// This situation may occur on collection deserialization
    /// when the owner is deserialized before the ownee.
    ///
    /// - Parameters:
    ///   - ownee: the ownee
    ///   - ownerUID: the currently unavailable owner UID
    open static func appendToDeferredOwnershipsList(_ ownee:Collectible,ownerUID:UID){
        if self._deferredOwnerships.keys.contains(ownerUID) {
            self._deferredOwnerships[ownerUID]!.append(ownee.UID)
        }else{
            self._deferredOwnerships[ownerUID]=[ownee.UID]
        }
    }


    // MARK: - Report


    /// Report the metrics to general endpoint calls (not clearly attached to a specific document)
    ///
    /// - parameter metrics: the metrics
    /// - parameter forURL:  the concerned URL
    open func report(_ metrics:Metrics,forURL:URL){
        for( _ , document) in self._documents{
            let s=document.baseURL.absoluteString
            let us=forURL.absoluteString
            if us.contains(s){
                document.report(metrics)
            }
        }
    }


    // MARK: - Commit / Push Distribution (dynamic)


    open static func markCommitted(_ instanceUID:UID){
        if let instance=Bartleby.collectibleInstanceByUID(instanceUID){
            instance.hasBeenCommitted()
        }else{
            glog("\(instanceUID) not found", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
        }
    }
}
