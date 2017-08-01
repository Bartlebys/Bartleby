//
//  Identities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//
//

import Foundation

public enum IdentitiesError:Error{
    case serializationFailure
    case deserializationFailure
    case missingData
}


public struct Identities:Codable {

    // You should set your own storage key during Document initialization
    public static var storageKey="identities.org.bartlebys"

    var identifications:[Identification]=[Identification]()
    var profiles:[Profile]=[Profile]()

    public init () {}


    func saveToKeyChain(accessGroup:String)throws->(){
        let json = try JSONEncoder().encode(self)
            let keyChainHelper=KeyChainHelper(accessGroup: accessGroup)
            // The identities are crypted in the KeyChain
            let jsonString =  try json.string(using: Default.STRING_ENCODING)
            let crypted = try Bartleby.cryptoDelegate.encryptString(jsonString,useKey:Bartleby.configuration.KEY)
            let _ = keyChainHelper.set(crypted, forKey: Identities.storageKey)

    }

    public static func loadFromKeyChain(accessGroup:String)throws->Identities{
        let keyChainHelper=KeyChainHelper(accessGroup: accessGroup)
        if let cryptedJson=keyChainHelper.get(Identities.storageKey){
            // The identities are crypted in the KeyChain
            let json = try Bartleby.cryptoDelegate.decryptString(cryptedJson,useKey:Bartleby.configuration.KEY)
            if let jsonData = json.data(using: Default.STRING_ENCODING){
                let instance = try JSONDecoder().decode(Identities.self, from: jsonData)
                return instance
            }else{
                throw IdentitiesError.missingData
            }
        }

        // Return a void Identities
        return Identities()

    }
}
