//
//  ManagedModel+NSCopying.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

// This implementation works
// But is currently suspended
/*
extension ManagedModel:NSCopying{

    open func copy(with zone: NSZone?) -> Any {
        if let document=self.referentDocument{
            let data: Data = self.serialize()
            let typeName = type(of: self).typeName()
            do{
                // We must use dynamic deserialization
                return try document.dynamicDeserializer.deserialize(className:typeName ,data: data, document: nil)
            }catch{
                self.log("ERROR with Copy with zone on \(String(describing: self._runTimeTypeName)) \(self.UID) \(error)" as AnyObject, file:#file, function:#function, line:#line,category:Default.LOG_DEFAULT)
            }
            return self as Any
        }
        return self
    }

}
*/
