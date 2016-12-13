//
//  ManagedModel+DictionaryRepresentation.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

extension ManagedModel:DictionaryRepresentation {

    open func dictionaryRepresentation()->[String:Any] {
        return Mapper().toJSON(self)
    }
    
}
