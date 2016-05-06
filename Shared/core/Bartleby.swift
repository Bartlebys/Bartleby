//
//  Bartleby.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 16/09/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation

//MARK: - Bartleby

// Bartleby's 1.0 approach is suitable for data set that can stored in memory.
// Bartleby 2.0 will implement storage layers for larger data set, and distant aliases

@objc(Bartleby) public class  Bartleby: Consignee {

    // The configuration
    static public var configuration: BartlebyConfiguration.Type=BartlebyDefaultConfiguration.self

    // The crypto delegate
    static public var cryptoDelegate: CryptoDelegate=NoCrypto()

    // The File manager
    static public var fileManager: BartlebyFileIO=BFileManager()

    // The task Scheduler
    static public var scheduler: TasksScheduler=TasksScheduler()


    /// The standard singleton shared instance
    public static let sharedInstance: Bartleby = {
        let instance = Bartleby()
        return instance
    }()

    static let b_version = "1.0"
    static let b_release = "beta1"
    private static var _enableBPrint: Bool=false

    /// The version string of Bartleby framework
    public static var versionString: String {
        get {
            return "\(self.b_version).\(self.b_release)"
        }
    }

    /**
     Should be called on Init of the Document.
     */
    public func configureWith(configuration: BartlebyConfiguration.Type) {

        //Initialize the crypto delegate with the valid KEY & SALT
        Bartleby.cryptoDelegate=CryptoHelper(key: configuration.KEY, salt: configuration.SHARED_SALT)

        // Store the configuration
        Bartleby.configuration=configuration

        // Enable Bprint?
        Bartleby._enableBPrint=configuration.ENABLE_BPRINT
        self.trackingIsEnabled=configuration.API_CALL_TRACKING_IS_ENABLED
        self.bprintTrackedEntries=configuration.BPRINT_API_TRACKED_CALLS

        bprint("Bartleby Start time : \(Bartleby._startTime)", file:#file, function:#function, line:#line)

        // Configure the HTTP Manager
        HTTPManager.configure()
    }


    override init() {
        super.init()
    }


    // MARK: -
    // TODO: @md Check crypto key requirement
    static public func isValidKey(key: String) -> Bool {
        return key.characters.count >= 32
    }

    // MARK: - Registries

    // Each document is a stored in it own registry
    // Multiple documents can be openned at the same time
    // and synchronized to different Servers.
    // Bartleby supports multi-authentication and multi documents


    /// Memory storage
    private var _registries: [String:Registry]! = [String:Registry]()

    /**
     Returns the registry if found

     - parameter UID: the registry UID

     - returns: the registry or Nil
     */
    public func getRegistryByUID(UID: String) -> Registry? {
        return _registries[UID]
    }


    /**
     Register a registry (each document has its own registry)

     - parameter registry: the registry
     */
    public func declare(registry: Registry) {
        _registries[registry.spaceUID]=registry
    }

    /**
     Unload the collections

     - parameter registryUID: the target registry UID
     */
    public func forget(registryUID: String) {
        _registries.removeValueForKey(registryUID)
    }

    /**
     Replace the UID of a proxy Registry

     - parameter registryProxyUID: the proxy UID
     - parameter registryUID:      the final UID
     */
    public func replace(registryProxyUID: String, by registryUID: String) {
        if( registryProxyUID != registryUID) {
            if let registry=_registries[registryProxyUID] {
                _registries[registryUID]=registry
                _registries.removeValueForKey(registryProxyUID)
            }
        }
    }

    /**
     Defers a closure execution on main queue

     - parameter seconds: the delay in fraction of seconds
     - parameter closure: the closure
     */
    public static func executeAfter(seconds: Double, closure:()->())->() {
        let delayInNanoSeconds = seconds * Double(NSEC_PER_SEC)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInNanoSeconds))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            closure()

        }
    }

    /**
     An UID generator compliant with MONGODB primary IDS constraints

     - returns: the UID
     */
    public static func createUID() -> String {
        // (!) NSUUID are not suitable for MONGODB as Primary Ids.
        // We need to encode them we have choosen base64
        let uid=NSUUID().UUIDString
        let utf8str = uid.dataUsingEncoding(Default.TEXT_ENCODING)
        return utf8str!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue:0))
    }


    private static var _printCounter: Int=0
    private static let _startTime=CFAbsoluteTimeGetCurrent()

    /**
     Print indirection with guided contextual info
     Usage : bprint("<Message>",file:#file,function:#function,line:#line")
     You can create code snippet

     - parameter items: the items to print
     - parameter file:  the file
     - parameter line:  the line
     - parameter function : the function name
     - parameter context: a contextual string
     */
    public static func bprint(message: AnyObject?, file: String = "", function: String = "", line: Int = -1) {
        if(self._enableBPrint) {
            if let message=message {
                func padded<T>(number: T, _ numberOfDigit: Int, _ char: String=" ", _ left: Bool=true) -> String {
                    var s="\(number)"
                    while s.characters.count < numberOfDigit {
                        if left {
                            s=char+s
                        } else {
                            s=s+char
                        }
                    }
                    return s
                }
                func extractFileName(s: String) -> String {
                    let components=s.componentsSeparatedByString("/")
                    if components.count>0 {
                        return components.last!
                    }
                    return ""
                }
                Bartleby._printCounter += 1
                let elapsed=CFAbsoluteTimeGetCurrent()-_startTime
                let ft: Int=Int(floor(elapsed))
                let micro=Int((elapsed-Double(ft))*1000)
                print("\(padded(Bartleby._printCounter, 6)) | \(padded(ft, 4)):\(padded( micro, 3, "0", false)) : \(message)  {\(extractFileName(file))(\(line)).\(function)}")
            }
        }
    }

    /**
     Reacts to a todo

     - parameter title:   the title of the todo
     - parameter message: its message
     */
    public static func todo(title: String, message: String) {
        Bartleby.sharedInstance.presentVolatileMessage(title, body:message)
    }



    /**
     Returns a random string of a given size.

     - parameter len: the length
     - parameter signs: the possible signs By default We exclude possibily confusing signs "oOiI01" to make random strings less ambiguous

     - returns: the string
     */
    public static func randomStringWithLength (len: UInt, signs: String="abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ23456789") -> String {
        var randomString = ""
        for _ in (0 ..< len) {
            let length = UInt32 (signs.characters.count)
            let rand = arc4random_uniform(length)
            let idx = signs.startIndex.advancedBy(Int(rand))
            let c=signs.characters[idx]
            randomString.append(c)
        }
        return randomString
    }



    // MARK: - Paths & URL


    /**
     Call

     - parameter spaceUID: the spaceUID

     - returns: the
     */
    public func getCollaborationURLForSpaceUID(spaceUID: String) -> NSURL {
        if let registry=Bartleby.sharedInstance.getRegistryByUID(spaceUID) {
            if let collaborationServerURL=registry.registryMetadata.collaborationServerURL {
                return collaborationServerURL
            }
        }
        return Bartleby.configuration.API_BASE_URL
    }

    /**
     Returns a storage

     - parameter spaceUID: the spaceUID

     - returns: the Application folder URL
     */
    public func getApplicationDataFolderPath(spaceUID: String) -> String {
        let folder=Bartleby.getSearchPath(.ApplicationSupportDirectory)!
        return folder + "Bartleby/\(spaceUID)/"
    }


    /**
     Returns the search path directory

     - parameter searchPath: the search Path

     - returns: the path string
     */
    public static func getSearchPath(searchPath: NSSearchPathDirectory) -> String? {
        let urls = NSFileManager.defaultManager().URLsForDirectory(searchPath, inDomains: .UserDomainMask)
        if urls.count>0 {
            if let path = urls[0].path {
                return path + "/"
            }
        }
        return nil
    }

}
