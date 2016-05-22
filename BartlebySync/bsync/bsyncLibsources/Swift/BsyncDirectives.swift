//
//  BsyncDirectives.swift
//  Bartleby's Sync client aka "bsync"
//
//
//  Created by Benoit Pereira da silva on 30/12/2015.
//  Copyright © 2015 Benoit Pereira da silva. All rights reserved.
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
    import BartlebyKit
#endif


public enum BsyncDirectivesError: ErrorType {
    case DeserializationError
}


/**
 *  Directives are serializeed in files
 *  One of the URL must be local, to mark it is local it is set to nil
 *  and we use its parent folder as tree root
 *  It suppports NSSecureCoding as it can be to perform XPC calls.
 */
@objc(BsyncDirectives) public class  BsyncDirectives: BsyncCredentials {
    
    override public class func typeName() -> String {
        return "BsyncDirectives"
    }
    
    public static let distantSchemes: [String]=["http", "https", "ftp", "ftps"]
    
    
    /// The default file name is just a convention
    public static let DEFAULT_FILE_NAME=".directives"
    
    // TODO: @bpds @md #bsync Change url to not optionnal
    public var sourceURL: NSURL?
    public var destinationURL: NSURL?
    public var hashMapViewName: String?
    
    public var computeTheHashMap: Bool=true
    public var automaticTreeCreation: Bool=false
    
    // TODO: @bpds @md #bsync Which file manager should we use?
    let _fm = BFileManager()
    
    public required init() {
        super.init()
    }
    
    // TODO: @md #test #bsync Test credential are not nil when using distant url (source or destination)
    public func areValid()->(valid: Bool, message: String) {
        if self.sourceURL == nil || self.destinationURL == nil {
            return (false, NSLocalizedString("The source and the destination must be set", comment: "The source and the destination must be set"))
        }
        if self.hashMapViewName != nil {
            // We currently support only down streams with hashMapView
            if let scheme=destinationURL?.scheme {
                if (BsyncDirectives.distantSchemes.indexOf( scheme ) != nil) {
                    return (false, NSLocalizedString("Hash map views must be restricted to down stream synchronisation", comment: "Hash map views must be restricted to down stream synchronisation"))
                } else {
                    // It's ok.
                }
            } else {
                return (false, NSLocalizedString("No valid destination scheme", comment: "No valid destination scheme"))
            }
            
        }
        
        return (true, "")
    }
    
    /**
     Creates an upStream directives.
     
     - parameter distantURL:  distantURL should conform with ${API_BASE_URL}BartlebySync/tree/${TREE_ID}
     - parameter localPath:  path to local folder
     
     - returns: the directives
     */
    public static func upStreamDirectivesWithDistantURL(distantURL: NSURL, localPath: String) -> BsyncDirectives {
        let directives=BsyncDirectives()
        directives.sourceURL = NSURL(fileURLWithPath: localPath)
        directives.destinationURL = distantURL
        return directives
        
    }
    /**
     Creates a downStream directives.
     
     - parameter distantURL:  distantURL should conform with ${API_BASE_URL}BartlebySync/tree/${TREE_ID}
     - parameter localPath:  path to local folder
     
     - returns: the directives
     */
    public static func downStreamDirectivesWithDistantURL(distantURL: NSURL, localPath: String) -> BsyncDirectives {
        let directives=BsyncDirectives()
        directives.sourceURL = distantURL
        directives.destinationURL = NSURL(fileURLWithPath: localPath)
        return directives
    }
    
    /**
     Creates a local directives.
     
     - parameter sourcePath:  path to source folder
     - parameter localPath:  path to destination folder
     
     - returns: the directives
     */
    public static func localDirectivesWithPath(sourcePath: String, destinationPath: String) -> BsyncDirectives {
        let directives=BsyncDirectives()
        directives.sourceURL = NSURL(fileURLWithPath: sourcePath)
        directives.destinationURL = NSURL(fileURLWithPath: destinationPath)
        return directives
    }
    
    /**
     Load directives from file
     
     */
    public static func load(path: String) throws -> BsyncDirectives {
        // Load the directives
        var JSONString="{}"
        // If the file is named .json the file is deleted.
        // TODO: @bpds @md #io Using BFileManager with handlers is not very comod here...
        JSONString = try NSString(contentsOfFile: path, encoding: Default.STRING_ENCODING) as String
        // TODO: @bpds @md #crypto Since we already crypt json content, do we need to encrypt again directives? (currently not symetric btw
        //        JSONString = try Bartleby.cryptoDelegate.decryptString(JSONString as String)
        
        if let directives: BsyncDirectives = Mapper<BsyncDirectives>().map(JSONString) {
            return directives
        } else {
            throw BsyncDirectivesError.DeserializationError
        }
        
    }
    /**
     
     Save directives.
     
     - parameter directive: the synchronization directive
     - parameter fileURL: the folder URL
     
     - throws: Explanation is something wrong happened
     */
    public func save(path: String, handlers: Handlers) {
        let result = self.areValid()
        if result.valid {
            if let jsonString = Mapper().toJSONString(self) {
                self._fm.writeString(jsonString, path: path, handlers: handlers)
            } else {
                handlers.on(Completion.failureState("Error serializing directives", statusCode: CompletionStatus.Undefined))
            }
        } else {
            handlers.on(Completion.failureState(result.message, statusCode: .Bad_Request))
        }
    }
    
    // MARK: Mappable
    
    required public init?(_ map: Map) {
        super.init(map)
        self.mapping(map)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map)
        sourceURL <- (map["sourceURL"], URLTransform())
        destinationURL <- (map["destinationURL"], URLTransform())
        computeTheHashMap <- map["computeTheHashMap"]
        automaticTreeCreation <- map["automaticTreeCreation"]
        hashMapViewName <- (map["hashMapViewName"], CryptedStringTransform()) // Crypted to prevent discovery
    }
    
    
    // MARK: NSecureCoding
    
    
    public override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        coder.encodeObject(sourceURL, forKey: "sourceURL")
        coder.encodeObject(destinationURL, forKey: "destinationURL")
        coder.encodeObject(hashMapViewName, forKey: "hashMapViewName")
        coder.encodeBool(computeTheHashMap, forKey: "computeTheHashMap")
        coder.encodeBool(automaticTreeCreation, forKey: "automaticTreeCreation")
        
    }
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.sourceURL=decoder.decodeObjectOfClass(NSURL.self, forKey:"sourceURL") as NSURL?
        self.destinationURL=decoder.decodeObjectOfClass(NSURL.self, forKey:"destinationURL") as NSURL?
        self.hashMapViewName=String(decoder.decodeObjectOfClass(NSString.self, forKey:"hashMapViewName") as NSString?)
        self.computeTheHashMap=decoder.decodeBoolForKey("computeTheHashMap")
        self.automaticTreeCreation=decoder.decodeBoolForKey("automaticTreeCreation")
    }
    
    // MARK: Identifiable
    
    override public class var collectionName: String {
        return "BsyncDirectives"
    }
    
    override public var d_collectionName: String {
        return BsyncDirectives.collectionName
    }
    
    // MARK: Implementation
    
    /**
     Run the directives
     
     - parameter filePath:   the directives filePath
     - parameter sharedSalt: the shared salt
     - parameter handlers:    verbose or not
     */
    
    
    func run(sharedSalt: String, handlers: Handlers) {
        
        let validity=self.areValid()
        
        if let sourceURL = self.sourceURL, let destinationURL = self.destinationURL where validity.valid {
            
            if self.computeTheHashMap {
                
                // Before to Proceed to hash.
                // We need to determine what ?
                // The source or the destination ?
                
                // Syncronization context
                let context=BsyncContext(
                    sourceURL: sourceURL,
                    andDestinationUrl: destinationURL,
                    restrictedTo: self.hashMapViewName,
                    autoCreateTrees: self.automaticTreeCreation
                )
                
                var analyzer = BsyncLocalAnalyzer()

                switch context.mode() {
                case BsyncMode.SourceIsLocalDestinationIsDistant:
                    if let sourcePath = sourceURL.path {
                        analyzer.createHashMapFromLocalPath(sourcePath, handlers: Handlers { (result) in
                            if result.success {
                                self.synchronize(sharedSalt, handlers: handlers)
                            } else {
                                handlers.on(result)
                            }
                            })
                    } else {
                        handlers.on(Completion.failureState("Bad source URL: \(sourceURL)", statusCode: .Bad_Request))
                    }
                case BsyncMode.SourceIsDistantDestinationIsLocal:
                    if let destinationPath = destinationURL.path {
                        analyzer.createHashMapFromLocalPath(destinationPath, handlers: Handlers { (result) in
                            if result.success {
                                self.synchronize(sharedSalt, handlers: handlers)
                            } else {
                                handlers.on(result)
                            }
                            })
                    } else {
                        handlers.on(Completion.failureState("Bad destination URL: \(destinationURL)", statusCode: .Bad_Request))
                    }
                case BsyncMode.SourceIsLocalDestinationIsLocal:
                    if let sourcePath = sourceURL.path, let destinationPath = destinationURL.path {
                        analyzer.createHashMapFromLocalPath(sourcePath, handlers: Handlers { (result) in
                            if result.success {
                                analyzer.createHashMapFromLocalPath(destinationPath, handlers: Handlers { (result) in
                                    if result.success {
                                        self.synchronize(sharedSalt, handlers: handlers)
                                    } else {
                                        handlers.on(result)
                                    }
                                    })
                            } else {
                                handlers.on(result)
                            }
                            })
                    } else {
                        handlers.on(Completion.failureState("Bad source or destination URL: \(sourceURL) /  \(destinationURL)", statusCode: .Bad_Request))
                    }
                default:
                    handlers.on(Completion.failureState("Unsupported mode \(context.mode())", statusCode: .Bad_Request))
                }
            } else {
                // There is no need to compute
                // Run the synchro directly
                synchronize(sharedSalt, handlers: handlers)
            }
        } else {
            handlers.on(Completion.failureState(validity.message, statusCode: .Bad_Request))
        }
        
    }
    
    /**
     The synchronization implementation
     
     - parameter sharedSalt:      sharedSalt
     - parameter handlers: the progress and completion handlers
     
     
     */
    func synchronize(sharedSalt: String?, handlers: Handlers) {
        
        // Syncronization context
        
        let context=BsyncContext(   sourceURL: self.sourceURL!,
                                    andDestinationUrl: self.destinationURL!,
                                    restrictedTo: self.hashMapViewName,
                                    autoCreateTrees:self.automaticTreeCreation
        )
        
        context.credentials=BsyncCredentials()
        context.credentials?.user=user
        context.credentials?.salt=sharedSalt
        context.credentials?.password=password
        
        var url: NSURL?
        switch context.mode() {
        case BsyncMode.SourceIsDistantDestinationIsLocal:
            url=sourceURL
        case BsyncMode.SourceIsLocalDestinationIsDistant:
            url=destinationURL
        default:
            url=nil
        }
        // If there is an url let's determine the API base url.
        // it should be before baseAPI_URL/BartlebySync/tree/...
        // eg.: http://yd.local/api/v1/BartlebySync/tree/nameOfTree/
        
        if var stringURL=url?.absoluteString {
            let r=stringURL.rangeOfString("/BartlebySync")
            if let foundIndex=r?.startIndex {
                // extract the base URL
                url=NSURL(string: stringURL.substringToIndex(foundIndex))
            }
        }
        
        // Synchronization handler
        func doSync() {
            
            let admin: BsyncAdmin=BsyncAdmin(context:context)
            admin.synchronizeWithprogressBlock(handlers)
        }
        
        if (context.mode() == BsyncMode.SourceIsLocalDestinationIsDistant) || (context.mode() == BsyncMode.SourceIsDistantDestinationIsLocal) {
            // We need to login before performing sync
            if let user = user, let password = password {
                
                LoginUser.execute(user, withPassword: password, sucessHandler: {
                    print ("Successful login")
                    doSync()
                    }, failureHandler: { (context) in
                        // Print a JSON failure description
                        handlers.on(Completion.failureStateFromJHTTPResponse(context))
                        return
                })
            }
        } else {
            doSync()
        }
        
    }
}
