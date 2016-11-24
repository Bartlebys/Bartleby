//
//  BartlebyObject+NSCopying.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation


extension BartlebyObject:NSCopying{


    open func copy(with zone: NSZone?) -> Any {
        let data: Data=JSerializer.serialize(self)
        if let copied = try? JSerializer.deserialize(data) {
            return copied as AnyObject
        }
        self.log("ERROR with Copy with zone on \(self._runTimeTypeName) \(self.UID) " as AnyObject, file:#file, function:#function, line:#line,category:Default.LOG_CATEGORY)
        return self as AnyObject
    }

}
