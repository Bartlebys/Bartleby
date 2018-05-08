//
//  ManagedModel+DictionaryRepresentation.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

extension ManagedModel:DictionaryRepresentation {

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
