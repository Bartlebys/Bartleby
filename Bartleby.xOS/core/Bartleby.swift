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
open class  Bartleby: Consignee {

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
        self._registries=[String:Registry]()
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

        self.trackingIsEnabled=configuration.API_CALL_TRACKING_IS_ENABLED
        self.glogTrackedEntries=configuration.BPRINT_API_TRACKED_CALLS

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

    // Each document is a stored in it own registry
    // Multiple documents can be openned at the same time
    // and synchronized to different Servers.
    // Bartleby supports multi-authentication and multi documents


    /// Memory storage
    fileprivate var _registries: [String:Registry] = [String:Registry]()


    /**
     Returns a document by its UID ( == document.registryMetadata.rootObjectUID)
     The SpaceUID is shared between multiple document.

     - parameter UID: the uid of the document

     - returns: the document
     */
    open func getDocumentByUID(_ UID:String) -> BartlebyDocument?{
        return self._registries[UID] as? BartlebyDocument
    }
    /**
     Register a registry (each document has its own registry)

     - parameter registry: the registry
     */
    open func declare(_ registry: Registry) {
        self._registries[registry.UID]=registry
    }

    /**
     Unload the collections

     - parameter registryUID: the target registry UID
     */
    open func forget(_ registryUID: String) {
        _registries.removeValue(forKey: registryUID)
    }

    /**
     Replace the UID of a proxy Registry

     - parameter registryProxyUID: the proxy UID
     - parameter registryUID:      the final UID
     */
    open func replaceRegistryUID(_ registryProxyUID: String, by registryUID: String) {
        if( registryProxyUID != registryUID) {
            if let registry=self._registries[registryProxyUID] {
                self._registries[registryUID]=registry
                _registries.removeValue(forKey: registryProxyUID)
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
     Reacts to a todo

     - parameter title:   the title of the todo
     - parameter message: its message
     */
    open static func todo(_ title: String, message: String) {
        Bartleby.sharedInstance.presentVolatileMessage(title, body:message)
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
     Returns the url by the Registry UID

     - parameter registryUID: the registryUID

     - returns: the
     */
    open func getCollaborationURL(_ registryUID: String) -> URL {
        if let registry=self.getDocumentByUID(registryUID) {
            if let collaborationServerURL=registry.registryMetadata.collaborationServerURL {
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
        for (dataSpaceUID, registry) in _registries {
            if  let document = registry as? BartlebyDocument{
                document.log("Destroying EphemeralInstances on \(dataSpaceUID)", file:#file, function:#function, line:#line, category: Default.LOG_CATEGORY)
                document.superIterate({ (element) in
                    if element.ephemeral {
                        document.delete(element)
                    }
                })
            }
        }
    }

}
