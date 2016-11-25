//
//  BartlebyDocument+MetaDataImportExport.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 08/07/2016.
//
//

import Foundation


public extension BartlebyDocument{

    // This is the BartlebyDocument UID
    // We use the root object UID as observationUID
    // You should have set up the rootObjectUID before any trigger emitted.
    // The triggers are observable via this UID
    public var UID:String{
        get{
            return self.metadata.rootObjectUID
        }
    }

    // The spaceUID can be shared between multiple documents-registries
    // It defines a dataSpace in wich a user can perform operations.
    // A user can `live` in one data space only.
    public var spaceUID: String {
        get {
            return self.metadata.spaceUID
        }
    }


    /// The current document user
    public var currentUser: User {
        get {
            if let currentUser=self.metadata.currentUser {
                return currentUser
            } else {
                return User()
            }
        }
    }


    // The file extension for crypted data
    public static var DATA_EXTENSION: String { return (Bartleby.cryptoDelegate is NoCrypto) ? ".json" : ".data" }

    // The metadata file name
    internal var _metadataFileName: String { return "metadata" + BartlebyDocument.DATA_EXTENSION }

    // The bsfs data file name
    internal var _bsfsDataFileName: String { return "bsfs" + BartlebyDocument.DATA_EXTENSION }

    // The collection server base URL
    public dynamic var baseURL:URL{
        return self.metadata.collaborationServerURL ?? Bartleby.configuration.API_BASE_URL
    }
    
}
