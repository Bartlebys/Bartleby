//
//  JRegistryMetadata.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 12/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif


// The standard RegistryMetadata implementation
// The underlining model has been implemented by flexions in BaseRegistryMetadata
@objc(JRegistryMetadata) public class JRegistryMetadata : BaseRegistryMetadata,RegistryMetadata {
    
    
    public func configureSchema(metadatum:JCollectionMetadatum) throws ->() {
        for m in self.collectionsMetadata{
            if m.collectionName == metadatum.collectionName{
                throw RegistryMetadataError.DuplicatedCollectionName
            }
        }
        collectionsMetadata.append(metadatum)
    }
    
    dynamic public var storedPassword:String{
        get {
            if (saveThePassword){
                if let rootUser=rootUser {
                    return rootUser.password
                }
            }
            return ""
        }
    }
    
    required public init() {
        super.init()
    }
    
    // MARK: Mappable
    
    
    required public init?(_ map: Map) {
        super.init(map)
    }
    
    
    // MARK: NSecureCoding
    
    
    public override func encodeWithCoder(coder: NSCoder){
        super.encodeWithCoder(coder)
    }
    
    required public init?(coder decoder: NSCoder){
        super.init(coder: decoder)
    }

 

 
    
    override public class func supportsSecureCoding() -> Bool{
        return true
    }
    
    

}