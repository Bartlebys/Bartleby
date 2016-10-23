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

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

//MARK: - Bartleby

// Bartleby's 1.0 approach is suitable for data set that can stored in memory.
@objc(Bartleby) open class Bartleby:NSObject {

    /// The standard singleton shared instance
    open static let sharedInstance: Bartleby = {
        let instance = Bartleby()
        return instance
    }()

    static let b_version = "1.0"
    static let b_release = "RC"

    /// The version string of Bartleby framework
    open static var versionString: String {
        get {
            return "\(self.b_version).\(self.b_release)"
        }
    }

    // A unique run identifier that changes each time Bartleby is launched
    open static let runUID: String=Bartleby.createUID()

    // The configuration
    static open var configuration: BartlebyConfiguration.Type=BartlebyDefaultConfiguration.self

    // The crypto delegate
    static open var cryptoDelegate: CryptoDelegate=NoCrypto()

    // The File manager
    static open var fileManager: BartlebyFileIO=BFileManager()

    static open var changesAreInspectables:Bool=configuration.CHANGES_ARE_INSPECTABLES_BY_DEFAULT

    //The default serializer
    static open var defaultSerializer: Serializer.Type=JSerializer.self

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
            Bartleby.cryptoDelegate=CryptoHelper(key: configuration.KEY, salt: configuration.SHARED_SALT)
        }

        // Store the configuration
        Bartleby.configuration=configuration

        // Ephemeral mode.
        Bartleby.ephemeral=configuration.EPHEMERAL_MODE

        glog("Bartleby Start time : \(Bartleby.startTime)", file:#file, function:#function, line:#line)

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
    static open func isValidKey(_ key: String) -> Bool {
        return key.characters.count >= 32
    }

    // MARK: - Registries

    // Each document is a stored separately
    // Multiple documents can be openned at the same time
    // and synchronized to different Servers.
    // Bartleby supports multi-authentication and multi documents

    /// Memory storage
    fileprivate var _documents: [String:BartlebyDocument] = [String:BartlebyDocument]()


    /**
     Returns a document by its UID ( == document.metadata.rootObjectUID)
     The SpaceUID is shared between multiple document.

     - parameter UID: the uid of the document

     - returns: the document
     */
    open func getDocumentByUID(_ UID:String) -> BartlebyDocument?{
        return self._documents[UID]
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
    open func forget(_ documentUID: String) {
        _documents.removeValue(forKey: documentUID)
    }

    /**
     Replaces the UID of a proxy Document

     - parameter documentProxyUID: the proxy UID
     - parameter documentUID:      the final UID
     */
    open func replaceDocumentUID(_ documentProxyUID: String, by documentUID: String) {
        if( documentProxyUID != documentUID) {
            if let document=self._documents[documentProxyUID] {
                self._documents[documentUID]=document
                self._documents.removeValue(forKey: documentProxyUID)
            }
        }
    }

    /**
     Defers a closure execution on main queue

     - parameter seconds: the delay in fraction of seconds
     - parameter closure: the closure
     */
    open static func executeAfter(_ seconds: Double,on queue:DispatchQueue=DispatchQueue.main,closure:@escaping ()->())->() {
        let delayInNanoSeconds = seconds * Double(NSEC_PER_SEC)
        let delayTime = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
        queue.asyncAfter(deadline: delayTime) {
            closure()
        }
    }

    /**
     An UID generator compliant with MONGODB primary IDS constraints

     - returns: the UID
     */
    open static func createUID() -> String {
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

    // OBJC relay (for Bsync to be deprecdated)
    open static func glog(_ message: Any, file: String, function: String, line: Int, category: String,decorative:Bool){
        glog(message, file: file, function: function, line: line, category: category, decorative: decorative)
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
            let length = UInt32 (signs.characters.count)
            let rand = Int(arc4random_uniform(length))
            let idx = signs.characters.index(signs.startIndex, offsetBy: rand, limitedBy:signs.endIndex)
            let c=signs.characters[idx!]
            randomString.append(c)
        }
        return randomString
    }



    // MARK: - Paths & URL

    /**
     Returns the url by the document collaborative server URL

     - parameter documentUID: the documentUID

     - returns: the
     */
    open func getCollaborationURL(_ documentUID: String) -> URL {
        if let document=self.getDocumentByUID(documentUID) {
            if let collaborationServerURL=document.metadata.collaborationServerURL {
                return collaborationServerURL as URL
            }
        }
        return Bartleby.configuration.API_BASE_URL as URL
    }



    /**
     Returns the search path directory

     - parameter searchPath: the search Path

     - returns: the path string
     */
    open static func getSearchPath(_ searchPath: FileManager.SearchPathDirectory) -> String? {
        let urls = FileManager.default.urls(for: searchPath, in: .userDomainMask)
        if urls.count>0 {
            let path = urls[0].path
            return path + "/"
        }
        return nil
    }

    // MARK: - Maintenance

    open func destroyLocalEphemeralInstances() {
        for (dataSpaceUID, document) in self._documents {
            document.log("Destroying EphemeralInstances on \(dataSpaceUID)", file:#file, function:#function, line:#line, category: Default.LOG_CATEGORY)
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
        self._instancesByUID[instance.UID]=instance
    }

    /**
     UnRegisters an instance

     - parameter instance: the collectible instance
     */
    open static func unRegister<T: Collectible>(_ instance: T) {
        self._instancesByUID.removeValue(forKey: instance.UID)
    }

    /**
     Returns the registred instance of by its UID

     - parameter UID:

     - returns: the instance
     */
    open static func registredObjectByUID<T: Collectible>(_ UID: String) throws-> T {
        if let instance=self._instancesByUID[UID] as? T {
            return instance
        }
        throw BartlebyDocumentError.instanceNotFound

    }



    /**
     Returns the instance by its UID

     - parameter UID: needle
     î
     - returns: the instance
     */
    static open func collectibleInstanceByUID(_ UID: String) -> Collectible? {
        return self._instancesByUID[UID]
    }


}
