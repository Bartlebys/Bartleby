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
    import Locksmith
#endif

public enum IdentitiesError:Error{
    case serializationFailure
    case deserializationFailure
    case missingData
}


public struct Identities:Mappable {

    var identifications:[Identification]=[Identification]()
    var profiles:[Profile]=[Profile]()

    public init() {}

    public init?(map: Map) {}

    public mutating func mapping(map: Map) {
        self.identifications <- ( map["identifications"] )
        self.profiles <- ( map["profiles"] )
    }

    func saveToKeyChain()throws->(){
        if let json=self.toJSONString(){
            // The identities are crypted in the KeyChain
            let crypted = try Bartleby.cryptoDelegate.encryptString(json,useKey:Bartleby.configuration.KEY)
            let _ = try? Locksmith.deleteDataForUserAccount(userAccount: "bartleby")
            try Locksmith.saveData(data: ["data":crypted], forUserAccount:"bartleby")
        }else{
            throw IdentitiesError.serializationFailure
        }
    }

    static func loadFromKeyChain()throws->Identities{
        if let data=Locksmith.loadDataForUserAccount(userAccount: "bartleby"){
            if let cryptedJson=data["data"] as? String{
                // The identities are crypted in the KeyChain
                let json = try Bartleby.cryptoDelegate.decryptString(cryptedJson,useKey:Bartleby.configuration.KEY)
                if let instance = Mapper <Identities>().map(JSONString:json){
                    return instance
                }else{
                    throw IdentitiesError.deserializationFailure
                }
            }else{
                throw IdentitiesError.missingData
            }
        }else{
            // Return a void Identities
            return Identities()
        }
    }
}

