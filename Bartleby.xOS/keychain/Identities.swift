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


open class Identities:Codable {

    // You should set your own storage key during Document initialization
    open static var storageKey="identities.org.bartlebys"

    open var identifications:[Identification]=[Identification]()
    open var profiles:[UserProfile]=[UserProfile]()

    public init () {}


    open func saveToKeyChain(accessGroup:String)throws->(){
        let json = try JSON.encoder.encode(self)
            let keyChainHelper=KeyChainHelper(accessGroup: accessGroup)
            // The identities are crypted in the KeyChain
            let jsonString =  try json.string(using: Default.STRING_ENCODING)
            let crypted = try Bartleby.cryptoDelegate.encryptString(jsonString,useKey:Bartleby.configuration.KEY)
            let _ = keyChainHelper.set(crypted, forKey: Identities.storageKey)

    }

    open static func loadFromKeyChain(accessGroup:String)throws->Identities{
        let keyChainHelper=KeyChainHelper(accessGroup: accessGroup)
        if let cryptedJson=keyChainHelper.get(Identities.storageKey){
            // The identities are crypted in the KeyChain
            let json = try Bartleby.cryptoDelegate.decryptString(cryptedJson,useKey:Bartleby.configuration.KEY)
            if let jsonData = json.data(using: Default.STRING_ENCODING){
                let instance = try JSON.decoder.decode(Identities.self, from: jsonData)
                return instance
            }else{
                throw IdentitiesError.missingData
            }
        }

        // Return a void Identities
        return Identities()

    }
}
