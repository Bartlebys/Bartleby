//
//  ManagedModel+NSCopying.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation


extension ManagedModel:NSCopying{

    open func copy(with zone: NSZone?) -> Any {
        if let document=self.referentDocument{
            let data: Data = document.serializer.serialize(self)
            do{
                if let copied = try document.serializer.deserialize(data) as? ManagedModel{
                    // Reallocate the collection
                    copied.collection=self.collection
                    return copied as AnyObject
                }
            }catch{
                self.log("ERROR with Copy with zone on \(self._runTimeTypeName) \(self.UID) \(error)" as AnyObject, file:#file, function:#function, line:#line,category:Default.LOG_DEFAULT)
            }
            return self as AnyObject
        }
        return self
    }

}
