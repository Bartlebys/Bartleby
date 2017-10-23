//
//  UnManagedModel+Serializable.swift
//  Bartleby macOS
//
//  Created by Benoit Pereira da silva on 04/08/2017.
//

import Foundation

extension UnManagedModel:Serializable{

    open func serialize() -> Data {
        do {
            return try JSON.encoder.encode(self)
        } catch {
            return Data()
        }
    }


    /// Serialize the current object to an UTF8 string
    ///
    /// - Returns: return an UTF8 string
    open func serializeToUFf8String()->String{
        return self.toJSONString(false)
    }


    // MARK: - Crypto properties support

    open func encodeCryptedString<Key>(value:String, codingKey:Key, container : inout KeyedEncodingContainer<Key>)throws{
        let crypted = try Bartleby.cryptoDelegate.encryptString(value,useKey:Bartleby.configuration.KEY)
        try container.encode(crypted, forKey: codingKey)
    }

    open func encodeCryptedStringIfPresent<Key>(value:String?, codingKey:Key, container : inout KeyedEncodingContainer<Key>)throws{
        if let string = value{
            let crypted = try Bartleby.cryptoDelegate.encryptString(string,useKey:Bartleby.configuration.KEY)
            try container.encodeIfPresent(crypted, forKey: codingKey)
        }
    }

    open func decodeCryptedString<Key>(codingKey:Key,from container : KeyedDecodingContainer<Key>) throws ->String{
        let crypted = try container.decode(String.self, forKey:codingKey)
        let decrypted = try Bartleby.cryptoDelegate.decryptString(crypted,useKey:Bartleby.configuration.KEY)
        return decrypted
    }

    open func decodeCryptedStringIfPresent<Key>(codingKey:Key,from container : KeyedDecodingContainer<Key>) throws ->String?{
        if let crypted = try container.decodeIfPresent(String.self, forKey:codingKey){
            let decrypted = try Bartleby.cryptoDelegate.decryptString(crypted,useKey:Bartleby.configuration.KEY)
            return decrypted
        }
        return nil
    }

}

extension UnManagedModel:DictionaryRepresentation {

    open func dictionaryRepresentation() -> [String : Any] {
        do{
            let data = try JSON.encoder.encode(self)
            if let dictionary = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [String : Any]{
                return dictionary
            }
        }catch{
            // Silent catch
        }
        return [String:Any]()
    }
}
