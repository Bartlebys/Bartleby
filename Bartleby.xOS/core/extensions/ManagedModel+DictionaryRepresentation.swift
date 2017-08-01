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
        var dictionary = [String:Any]()
        for key in self.exposedKeys{
            if let value = try? self.getExposedValueForKey(key){
                if let convertibleValue = value as? DictionaryRepresentation{
                    dictionary[key] = convertibleValue.dictionaryRepresentation()
                }else{
                    dictionary[key] = value
                }
            }
        }
        return dictionary
    }

}
