//
//  Identities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

public enum IdentitiesError:Error{
    case serializationFailure
    case deserializationFailure
    case missingData
}


public struct Identities:Mappable {

    // You should set your own storage key during Document initialization
    public static var storageKey="identities.org.bartlebys"

    var identifications:[Identification]=[Identification]()
    var profiles:[Profile]=[Profile]()

    public init () {}

    public init?(map: Map) {
    }

    public mutating func mapping(map: Map) {
        self.identifications <- ( map["identifications"] )
        self.profiles <- ( map["profiles"] )
    }

    func saveToKeyChain(accessGroup:String)throws->(){
        if let json=self.toJSONString(){
            let keyChainHelper=KeyChainHelper(accessGroup: accessGroup)
            // The identities are crypted in the KeyChain
            let crypted = try Bartleby.cryptoDelegate.encryptString(json,useKey:Bartleby.configuration.KEY)
            let _ = keyChainHelper.set(crypted, forKey: Identities.storageKey)
        }else{
            throw IdentitiesError.serializationFailure
        }
    }

    public static func loadFromKeyChain(accessGroup:String)throws->Identities{
        let keyChainHelper=KeyChainHelper(accessGroup: accessGroup)
        if let cryptedJson=keyChainHelper.get(Identities.storageKey){
            // The identities are crypted in the KeyChain
            let json = try Bartleby.cryptoDelegate.decryptString(cryptedJson,useKey:Bartleby.configuration.KEY)
            if let instance = Mapper <Identities>().map(JSONString:json){
                return instance
            }else{
                throw IdentitiesError.deserializationFailure
            }
        }else{
            // Return a void Identities
            return Identities()
        }
    }
}

