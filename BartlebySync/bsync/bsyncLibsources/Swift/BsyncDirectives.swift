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
@objc(BsyncDirectives) public class  BsyncDirectives : BsyncCredentials{
    
    public static let NO_HASHMAPVIEW="NO_HASHMAPVIEW"
    
    public static let distantSchemes:[String]=["http","https","ftp","ftps"]
    
    
    /// The default file name is just a convention
    public static let DEFAULT_FILE_NAME=".directives"
    
    public var sourceURL:NSURL?
    public var destinationURL:NSURL?
    public var creativeKey:String? //E.g For autocreation of trees
    public var hashMapViewName:String=BsyncDirectives.NO_HASHMAPVIEW
    
    public var computeTheHashMap:Bool=true
    public var automaticTreeCreation:Bool=false
    
    
    public required init(){
        super.init()
    }
    
    
    public func areValid()->(valid:Bool,message:String?){
        if sourceURL == nil || destinationURL == nil {
            return (false,NSLocalizedString("The source and the destination must be set", comment: "The source and the destination must be set"))
        }
        if creativeKey == nil{
            return (false,NSLocalizedString("The creative key must be set", comment: "The creative key must be set"))
        }
        if hashMapViewName != BsyncDirectives.NO_HASHMAPVIEW {
            // We currently support only down streams with hashMapView
            if let scheme=destinationURL?.scheme{
                if (BsyncDirectives.distantSchemes.indexOf( scheme ) != nil) {
                    return (false,NSLocalizedString("Hash map views must be restricted to down stream synchronisation", comment: "Hash map views must be restricted to down stream synchronisation"))
                }else{
                    // It's ok.
                }
            }else{
                return (false,NSLocalizedString("No valid destination scheme", comment: "No valid destination scheme"))
            }
            
        }
        
        return (true,nil)
    }
    
    /**
     Creates an upStream directives.
     
     - parameter distantURL:  distantURL should conform with ${API_BASE_URL}BartlebySync/tree/${TREE_ID}
     - parameter localURL:  localURL should be local :-)
     - parameter creativeKey: the creative Key
     
     - returns: the directives
     */
    public static func upStreamDirectivesWithDistantURL(distantURL:NSURL,localURL:NSURL, creativeKey:String)->BsyncDirectives{
        let directives=BsyncDirectives()
        directives.sourceURL=localURL
        directives.destinationURL=distantURL
        directives.creativeKey=creativeKey
        return directives
        
    }
    /**
     Creates an downStream directives.
     
     - parameter distantURL:  distantURL should conform with ${API_BASE_URL}BartlebySync/tree/${TREE_ID}
     - parameter localURL:  localURL should be local :-)
     - parameter creativeKey: the creative Key
     
     - returns: the directives
     */
    public static func downStreamDirectivesWithDistantURL(distantURL:NSURL,localURL:NSURL,creativeKey:String)->BsyncDirectives{
        let directives=BsyncDirectives()
        directives.sourceURL=distantURL
        directives.destinationURL=localURL
        directives.creativeKey=creativeKey
        return directives
    }
    
    
    // MARK: Mappable
    
    required public init?(_ map: Map) {
        super.init(map)
        self.mapping(map)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map)
        sourceURL <- (map["sourceURL"],URLTransform())
        destinationURL <- (map["destinationURL"],URLTransform())
        computeTheHashMap <- map["computeTheHashMap"]
        automaticTreeCreation <- map["automaticTreeCreation"]
        if BsyncCredentials.DEBUG_DISABLE_ENCRYPTION {
            hashMapViewName <- map["hashMapViewName"]
            creativeKey <- map["creativeKey"]
        }else{
            hashMapViewName <- (map["hashMapViewName"],CryptedStringTransform()) // Crypted to prevent discovery
            creativeKey <- (map["creativeKey"],CryptedStringTransform())
        }
        
    }
    
    
    // MARK: NSecureCoding
    
    
    public override func encodeWithCoder(coder: NSCoder){
        super.encodeWithCoder(coder)
        coder.encodeObject(sourceURL, forKey: "sourceURL")
        coder.encodeObject(destinationURL, forKey: "destinationURL")
        coder.encodeObject(creativeKey, forKey: "creativeKey")
        coder.encodeObject(hashMapViewName, forKey: "hashMapViewName")
        coder.encodeBool(computeTheHashMap, forKey: "computeTheHashMap")
        coder.encodeBool(automaticTreeCreation, forKey: "automaticTreeCreation")
        
    }
    
    public required init?(coder decoder: NSCoder){
        super.init(coder: decoder)
        self.sourceURL=decoder.decodeObjectOfClass(NSURL.self, forKey:"sourceURL") as NSURL?
        self.destinationURL=decoder.decodeObjectOfClass(NSURL.self, forKey:"destinationURL") as NSURL?
        self.creativeKey=String(decoder.decodeObjectOfClass(NSString.self, forKey:"creativeKey") as NSString?)
        self.hashMapViewName=String(decoder.decodeObjectOfClass(NSString.self, forKey:"hashMapViewName") as NSString?)
        self.computeTheHashMap=decoder.decodeBoolForKey("computeTheHashMap")
        self.automaticTreeCreation=decoder.decodeBoolForKey("automaticTreeCreation")
    }
    
    
    
    
}