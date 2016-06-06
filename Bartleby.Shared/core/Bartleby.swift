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
// Bartleby 2.0 will implement storage layers for larger data set, and distant external references
public class  Bartleby: Consignee {

    // The configuration
    static public var configuration: BartlebyConfiguration.Type=BartlebyDefaultConfiguration.self

    // The crypto delegate
    static public var cryptoDelegate: CryptoDelegate=NoCrypto()

    // The File manager
    static public var fileManager: BartlebyFileIO=BFileManager()


    static private var _scheduler: TasksScheduler=TasksScheduler()

    // The task Scheduler
    static public var scheduler: TasksScheduler {
        get {
            return _scheduler
        }
    }

    //The default serializer
    static public var defaultSerializer: Serializer.Type=JSerializer.self


    /// The standard singleton shared instance
    public static let sharedInstance: Bartleby = {
        let instance = Bartleby()
        return instance
    }()

    static let b_version = "1.0"
    static let b_release = "beta2"



    /// The version string of Bartleby framework
    public static var versionString: String {
        get {
            return "\(self.b_version).\(self.b_release)"
        }
    }



    #if os(OSX)
    /// The unique device identifier. We use Eth0 on OSX
    public static let deviceIdentifier: String = Bartleby._MACAddressEN0()
    #else
     /// The unique device identifier. We use the Identifier for vendor on iOS
    public static let deviceIdentifier: String = UIDevice.currentDevice().identifierForVendor.UUIDString ?? Bartleby.createUID()
    #endif

    // A unique run identifier that changes each time Bartleby is launched
    public static let runUID: String=Bartleby.createUID()


    /**
     This method should be only used to cleanup in core unit test
     */
    public func hardCoreCleanupForUnitTests() {
        Bartleby._scheduler=TasksScheduler()
        self._registries=[String:Registry]()
    }

    /**
     * When using ephemeralMode on registration Instance are marked ephemeral
     */
    public static var ephemeral=false

    /**
     Should be called on Init of the Document.
     */
    public func configureWith(configuration: BartlebyConfiguration.Type) {

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

        // Enable Bprint?
        Bartleby._enableBPrint=configuration.ENABLE_BPRINT
        self.trackingIsEnabled=configuration.API_CALL_TRACKING_IS_ENABLED
        self.bprintTrackedEntries=configuration.BPRINT_API_TRACKED_CALLS

        bprint("Bartleby Start time : \(Bartleby.startTime)", file:#file, function:#function, line:#line)

        // Configure the HTTP Manager
        HTTPManager.configure()
    }

    override init() {
        super.init()
    }

    // Bartleby's favourite
    public static func please(message: String) -> String {
        return "I would prefer not to!"
    }



    // MARK: -
    // TODO: @md #crypto Check crypto key requirement
    static public func isValidKey(key: String) -> Bool {
        return key.characters.count >= 32
    }

    // MARK: - Registries

    // Each document is a stored in it own registry
    // Multiple documents can be openned at the same time
    // and synchronized to different Servers.
    // Bartleby supports multi-authentication and multi documents


    /// Memory storage
    private var _registries: [String:Registry] = [String:Registry]()

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
        let utf8str = uid.dataUsingEncoding(Default.STRING_ENCODING)
        return utf8str!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue:0))
    }


    // MARK: - bprint
    private static var _enableBPrint: Bool=false
    public static let startTime=CFAbsoluteTimeGetCurrent()
    private static var _bufferingBprint=false
    private static var _printingBuffer=[String]()

    public static var bprintEntries=[BprintEntry]()



    public static func startBufferingBprint() {
        _bufferingBprint=true
        _printingBuffer=[String]()
        print("# Buffering Bprint calls...")
    }

    public static func stopBufferingBprint() {
        if _bufferingBprint==true {
            print("# Bprint dump")
            _bufferingBprint=false
            for s in _printingBuffer {
                print (s)
            }
            _printingBuffer=[String]()
        }
    }



    /**
     Print indirection with guided contextual info
     Usage : bprint("<Message>",file:#file,function:#function,line:#line,category:DEFAULT.BPRINT_CATEGORY")
     You can create code snippet

     - parameter message: the message
     - parameter file:  the file
     - parameter line:  the line
     - parameter function : the function name
     - parameter category: a categorizer string
     */
    public static func bprint(message: AnyObject, file: String, function: String, line: Int, category: String) {
        if(self._enableBPrint) {
                let elapsed=CFAbsoluteTimeGetCurrent()-Bartleby.startTime
                let entry=BprintEntry(counter: Bartleby.bprintEntries.count+1, message: message, file: file, function: function, line: line, category: category,elapsed:elapsed)
                Bartleby.bprintEntries.append(entry)
                if _bufferingBprint {
                    _printingBuffer.append(entry.description)
                } else {
                    print(entry.description)
                }
        }

    }


    /**
     Returns a printable string for the bprint entries matching a specific criteria

     - parameter matching: the filter closure

     - returns: a dump of the entries
     */
    public static func bprintEntries(@noescape matching:(entry: BprintEntry) -> Bool )->String{
        let entries=Bartleby.bprintEntries.filter { (entry) -> Bool in
            return matching(entry: entry)
        }
        var infos=""
        for entry in entries{
            infos += "\(entry)\n"
        }
        return infos
    }


    /**
     Cleans uo all the entries
     */
    public static func cleanUpBprintEntries(){
        Bartleby.bprintEntries.removeAll()
    }

    /**
     Dumps the bprint entries to a file.

     - parameter matching: the filter closure
     */
    public static func dumpBprintEntries(@noescape matching:(entry: BprintEntry) -> Bool){
        let log=Bartleby.bprintEntries(matching)
        let folderPath=Bartleby.getSearchPath(NSSearchPathDirectory.ApplicationSupportDirectory)!.stringByAppendingString("Bartleby/logs/")
        let filePath=folderPath+"\(CFAbsoluteTimeGetCurrent()).txt"

        let fileCreationHandler=Handlers { (folderCreation) in
            if folderCreation.success {
                Bartleby.fileManager.writeString(log, path:filePath, handlers: Handlers.withoutCompletion())
            }
        }

        Bartleby.fileManager.createDirectoryAtPath(folderPath, handlers:fileCreationHandler)
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



    // MARK: -


    private static var __MACAddressEN0: String?

    private static func _MACAddressEN0() -> String {
        if __MACAddressEN0==nil {
            __MACAddressEN0=_MACAddressForBSD("en0")
        }
        if __MACAddressEN0==nil {
            __MACAddressEN0=createUID()
        }
        return __MACAddressEN0!
    }


    private static func _MACAddressForBSD(bsd: String) -> String? {
        let MAC_ADDRESS_LENGTH = 6
        let separator = ":"
        var length: size_t = 0
        var buffer: [CChar]
        let BSDIndex = Int32(if_nametoindex(bsd))
        if BSDIndex == 0 {
            bprint("Error: could not find index for bsd name \(bsd)", file:#file, function:#function, line:#line, category: Default.BPRINT_CATEGORY)
            return nil
        }
        let bsdData = bsd.dataUsingEncoding(NSUTF8StringEncoding)!
        var managementInfoBase = [CTL_NET, AF_ROUTE, 0, AF_LINK, NET_RT_IFLIST, BSDIndex]
        if sysctl(&managementInfoBase, 6, nil, &length, nil, 0) < 0 {
            bprint("Error: could not determine length of info data structure", file:#file, function:#function, line:#line, category: Default.BPRINT_CATEGORY)
            return nil
        }
        buffer = [CChar](count: length, repeatedValue: 0)
        if sysctl(&managementInfoBase, 6, &buffer, &length, nil, 0) < 0 {
            bprint("Error: could not read info data structure", file:#file, function:#function, line:#line, category: Default.BPRINT_CATEGORY)
            return nil
        }
        let infoData = NSData(bytes: buffer, length: length)
        var interfaceMsgStruct = if_msghdr()
        infoData.getBytes(&interfaceMsgStruct, length: sizeof(if_msghdr))
        let socketStructStart = sizeof(if_msghdr) + 1
        let socketStructData = infoData.subdataWithRange(NSMakeRange(socketStructStart, length - socketStructStart))
        let rangeOfToken = socketStructData.rangeOfData(bsdData, options: NSDataSearchOptions(rawValue:0), range: NSMakeRange(0, socketStructData.length))
        let macAddressData = socketStructData.subdataWithRange(NSMakeRange(rangeOfToken.location + 3, MAC_ADDRESS_LENGTH))
        var macAddressDataBytes = [UInt8](count: MAC_ADDRESS_LENGTH, repeatedValue: 0)
        macAddressData.getBytes(&macAddressDataBytes, length: MAC_ADDRESS_LENGTH)
        let addressBytes = macAddressDataBytes.map({ String(format:"%02x", $0) })
        return addressBytes.joinWithSeparator(separator)
    }


    // MARK: - Maintenance


    public func destroyLocalEphemeralInstances() {
        for (dataSpaceUID, registry) in _registries {
            bprint("Destroying EphemeralInstances on \(dataSpaceUID)", file:#file, function:#function, line:#line, category: Default.BPRINT_CATEGORY)
            registry.superIterate({ (element) in
                if element.ephemeral {
                    registry.delete(element)
                }
            })
        }
    }


}



// MARK: - BprintEntry

/**
 *  A struct to insure temporary persistency of a BprintEntry
 */
public struct BprintEntry:CustomStringConvertible{

    public var counter: Int
    public var message: AnyObject
    public var file: String
    public var function: String
    public var line: Int
    public var category: String
    public var elapsed:CFAbsoluteTime

    public var description: String {

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

        let ft: Int=Int(floor(elapsed))
        let micro=Int((elapsed-Double(ft))*1000)
        let s="\(padded(counter, 6)) \( category) | \(padded(ft, 4)):\(padded( micro, 3, "0", false)) : \(message)  {\(extractFileName(file))(\(line)).\(function)}"

        return  s
    }
}

