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
    
    public required init() {
        super.init()
    }
    
    public func areValid()->(valid: Bool, message: String) {
        if let sourceURL = self.sourceURL, let destinationURL = self.destinationURL {
            let destinationIsDistant = BsyncDirectives.distantSchemes.indexOf(destinationURL.scheme) != nil
            let sourceIsDistant = BsyncDirectives.distantSchemes.indexOf(sourceURL.scheme) != nil
            
            if (sourceIsDistant || destinationIsDistant) {
                if self.user == nil {
                    return (false, NSLocalizedString("Distant directives need a user", comment: ""))
                }
                if self.password == nil {
                    return (false, NSLocalizedString("Distant directives need a password", comment: ""))
                }
                if self.salt == nil {
                    return (false, NSLocalizedString("Distant directives need a shared salt", comment: ""))
                }
            }
            
            if (self.hashMapViewName != nil) && destinationIsDistant {
                return (false, NSLocalizedString("Hash map view must be restricted when synchronizing to the final consumer", comment: ""))
            }
            
        } else {
            return (false, NSLocalizedString("The source and the destination must be set", comment: "The source and the destination must be set"))
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
    
    // MARK: Mappable
    
    required public init?(_ map: Map) {
        super.init(map)
        self.mapping(map)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map)
        self.lockAutoCommitObserver()
        sourceURL <- (map["sourceURL"], URLTransform())
        destinationURL <- (map["destinationURL"], URLTransform())
        computeTheHashMap <- map["computeTheHashMap"]
        automaticTreeCreation <- map["automaticTreeCreation"]
        hashMapViewName <- (map["hashMapViewName"], CryptedStringTransform()) // Crypted to prevent discovery
        self.unlockAutoCommitObserver()
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
        self.lockAutoCommitObserver()
        self.sourceURL=decoder.decodeObjectOfClass(NSURL.self, forKey:"sourceURL") as NSURL?
        self.destinationURL=decoder.decodeObjectOfClass(NSURL.self, forKey:"destinationURL") as NSURL?
        self.hashMapViewName=String(decoder.decodeObjectOfClass(NSString.self, forKey:"hashMapViewName") as NSString?)
        self.computeTheHashMap=decoder.decodeBoolForKey("computeTheHashMap")
        self.automaticTreeCreation=decoder.decodeBoolForKey("automaticTreeCreation")
        self.unlockAutoCommitObserver()
    }
    
    // MARK: Identifiable
    
    override public class var collectionName: String {
        return "BsyncDirectives"
    }
    
    override public var d_collectionName: String {
        return BsyncDirectives.collectionName
    }
}
