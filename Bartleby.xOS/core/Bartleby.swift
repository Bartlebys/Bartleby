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
// Bartleby 2.0 will implement storage layers for larger data set, and distant external references
public class  Bartleby: Consignee {

    // The configuration
    static public var configuration: BartlebyConfiguration.Type=BartlebyDefaultConfiguration.self

    // The crypto delegate
    static public var cryptoDelegate: CryptoDelegate=NoCrypto()

    // The File manager
    static public var fileManager: BartlebyFileIO=BFileManager()

    // The task scheduler
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

    public static var requestCounter=0

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
     Returns a document by its UID ( == document.registryMetadata.rootObjectUID)
     The SpaceUID is shared between multiple document.

     - parameter UID: the uid of the document

     - returns: the document
     */
    public func getDocumentByUID(UID:String) -> BartlebyDocument?{
        return self._registries[UID] as? BartlebyDocument
    }
    /**
     Register a registry (each document has its own registry)

     - parameter registry: the registry
     */
    public func declare(registry: Registry) {
        self._registries[registry.UID]=registry
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
    public func replaceRegistryUID(registryProxyUID: String, by registryUID: String) {
        if( registryProxyUID != registryUID) {
            if let registry=self._registries[registryProxyUID] {
                self._registries[registryUID]=registry
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

    public static var elapsedTime:Double {
        return CFAbsoluteTimeGetCurrent()-Bartleby.startTime
    }

    // MARK: - bprint
    private static var _enableBPrint: Bool=false
    public static let logSectionSeparator="[- | BARTLEBY_LOG_SECTION | -]\n"
    public static let startTime=CFAbsoluteTimeGetCurrent()
    public static  var bprintCollection=BprintCollection()


    public static var bPrintObservers=[BprintObserver]()

    /**
     Print indirection with contextual informations.

     - parameter message: the message
     - parameter file:  the file
     - parameter line:  the line
     - parameter function : the function name
     - parameter category: a categorizer string
     - parameter decorative: if set to true only the message will be displayed.
     */
    public static func bprint(message: AnyObject, file: String, function: String, line: Int, category: String,decorative:Bool=false) {
        if(self._enableBPrint) {
            let elapsed=Bartleby.elapsedTime
            let entry=BprintEntry(counter: Bartleby.bprintCollection.entries.count+1, message: "\(message)", file: file, function: function, line: line, category: category,elapsed:elapsed,decorative:decorative)
            Bartleby.bprintCollection.entries.insert(entry, atIndex: 0)
            for observers in bPrintObservers{
                observers.acknowledge(entry)
            }
            print(entry)
        }
    }


    /**
     Returns a printable string for the bprint entries matching a specific criteria

     - parameter matching: the filter closure

     - returns: a dump of the entries
     */
    public static func getBprintEntries(matching:(entry: BprintEntry) -> Bool )->String{
        let entries=Bartleby.bprintCollection.entries.filter { (entry) -> Bool in
            return matching(entry: entry)
        }
        var infos=""
        var counter = 1
        for entry in entries{
            infos += "\(counter)# \(entry)\n"
            counter += 1
        }
        return infos
    }


    /**
     Cleans up all the entries
     */
    public static func cleanUpBprintEntries(){
        Bartleby.bprintCollection.entries.removeAll()
    }

    /**
     Dumps the bprint entries to a file.
     
     Samples
     ```
     // Writes logs in ~/Library/Application\ Support/Bartleby/logs
     Bartleby.dumpBprintEntries ({ (entry) -> Bool in
     return true // all the Entries
     }, fileName: "All")

     Bartleby.dumpBprintEntries ({ (entry) -> Bool in
     return entry.file=="TransformTests.swift"
     },fileName:"TransformTests.swift")



     Bartleby.dumpBprintEntries({ (entry) -> Bool in
     return true // all the Entries
     }, fileName: "Tests_zorro")



     Bartleby.dumpBprintEntries ({ (entry) -> Bool in
     // Entries matching default category
     return entry.category==Default.BPRINT_CATEGORY
     },fileName:"Default")


     // Clean up the entries
     Bartleby.cleanUpBprintEntries()
     ```


     - parameter matching: the filter closure
     */
    public static func dumpBprintEntries(matching:(entry: BprintEntry) -> Bool,fileName:String?){

        let log=Bartleby.getBprintEntries(matching)
        let date=NSDate()
        let df=NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd-HH-mm"
        let dateFolder = df.stringFromDate(date)
        var id = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleIdentifier")
        if id == nil{
            id=NSBundle.mainBundle().executableURL?.lastPathComponent
        }
        let groupFolder = (id ?? "Shared")!

        let folderPath=Bartleby.getSearchPath(NSSearchPathDirectory.ApplicationSupportDirectory)!.stringByAppendingString("Bartlebys/logs/\(groupFolder)/\(dateFolder)/")
        let filePath=folderPath+"\(fileName ?? "" ).txt"

        dispatch_async(GlobalQueue.Background.get()) {
            let fileCreationHandler=Handlers { (folderCreation) in
                if folderCreation.success {
                    Bartleby.fileManager.writeString(log, path:filePath, handlers: Handlers.withoutCompletion())
                }
            }
            Bartleby.fileManager.createDirectoryAtPath(folderPath, handlers:fileCreationHandler)
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
            let rand = Int(arc4random_uniform(length))
            let idx = signs.startIndex.advancedBy(rand,limit:signs.endIndex)
            let c=signs.characters[idx]
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
    public func getCollaborationURL(registryUID: String) -> NSURL {
        if let registry=self.getDocumentByUID(registryUID) {
            if let collaborationServerURL=registry.registryMetadata.collaborationServerURL {
                return collaborationServerURL
            }
        }
        return Bartleby.configuration.API_BASE_URL
    }


    // !!! TO BE DEPRECATED ?
    /**
     This method retuns the URL by space UID.
     You should normally use : getCollaborationURL(...)
     This method can be used when performing non specific document operation (Lockers, ...)
     - parameter spaceUID: the spaceUID

     - returns: the collaboration server URL
     */
    public func getCollaborationURLForSpaceUID(spaceUID:String)->NSURL{
        for (_,registry) in self._registries {
            if registry.spaceUID==spaceUID{
                return registry.baseURL
            }
        }
        return Bartleby.configuration.API_BASE_URL

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

    // MARK: - Maintenance

    public func destroyLocalEphemeralInstances() {
        for (dataSpaceUID, registry) in _registries {
            if  let document = registry as? BartlebyDocument{
                bprint("Destroying EphemeralInstances on \(dataSpaceUID)", file:#file, function:#function, line:#line, category: Default.BPRINT_CATEGORY)
                document.superIterate({ (element) in
                    if element.ephemeral {
                        document.delete(element)
                    }
                })
            }
        }
    }


}

public protocol BprintObserver{

    func acknowledge(entry:BprintEntry);
}

// MARK: - BprintEntry


@objc(BprintCollection) public class BprintCollection:NSObject,Mappable{

    @objc public dynamic var entries=[BprintEntry]()

    override public init(){
    }

    // MARK: - Mappable

    public required init?(_ map: Map) {
    }

    public func mapping(map: Map) {
        self.entries <- map["entries"]
    }

}



/**
 *  A struct to insure temporary persistency of a BprintEntry
 */
@objc(BprintEntry) public class BprintEntry:NSObject,Mappable{

    public var counter: Int=0
    public var message: String=""
    public var file: String=""
    public var function: String=""
    public var line: Int=0
    public var category: String=""
    public var elapsed:CFAbsoluteTime=0
    public var decorative:Bool=false
    private var _runUID:String=Bartleby.runUID

    override public init(){
    }

    public init(counter:Int,message: String, file: String, function: String, line: Int, category: String,elapsed:CFAbsoluteTime,decorative:Bool=false){
        self.counter=counter
        self.message=message
        self.file=BprintEntry.extractFileName(file)
        self.function=function
        self.line=line
        self.category=category
        self.elapsed=elapsed
        self.decorative=decorative
    }

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

    static func extractFileName(s: String) -> String {
        let components=s.componentsSeparatedByString("/")
        if components.count>0 {
            return components.last!
        }
        return ""
    }

    override public var description: String {
        if decorative {
            return "\(message)"
        }
        let s="\(self.padded(counter, 6)) \( category) | \(self.padded( elapsed, 3, "0", false)) \(file))/\(function)#\(line) : \(message)"

        return  s
    }

    // MARK: - Mappable

    public required init?(_ map: Map) {
    }


    public func mapping(map: Map) {
        self.counter <- map["counter"]
        self.message <- map["message"]
        self.file <- map["file"]
        self.function <- map["function"]
        self.line <- map["line"]
        self.category <- map["line"]
        self.elapsed <- map["elapsed"]
        self.decorative <- map["decorative"]
        self._runUID <- map["runUID"]
    }
    
}

