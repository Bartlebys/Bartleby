//
//  ManagedModel+NSCopying.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

// #TODO ???
/*
extension ManagedModel:NSCopying{

    open func copy(with zone: NSZone?) -> Any {
        if let document=self.referentDocument{
            let data: Data = document.serializer.serialize(self)
            do{
                let SerializableType = type(of:self)
                if let copied = try document.serializer.deserialize(data, register: false) as? SerializableType{
                    // Reallocate the collection ? is equivalent to register
                    //copied.collection=self.collection
                    return copied as Any
                }
            }catch{
                self.log("ERROR with Copy with zone on \(String(describing: self._runTimeTypeName)) \(self.UID) \(error)" as AnyObject, file:#file, function:#function, line:#line,category:Default.LOG_DEFAULT)
            }
            return self as Any
        }
        return self
    }

}
*/
