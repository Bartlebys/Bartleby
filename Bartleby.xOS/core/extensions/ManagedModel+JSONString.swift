//
//  Bartleby+JSONString.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

extension ManagedModel:JSONString{

    // MARK:-  JSONString

    open func toJSONString(_ prettyPrint:Bool)->String{
        let encoder = prettyPrint ? JSON.prettyEncoder : JSON.encoder
        do{
            let data = try encoder.encode(self)
            return data.optionalString(using: Default.STRING_ENCODING) ?? Default.DESERIALIZATION_HAS_FAILED
        }catch{
            return Default.DESERIALIZATION_HAS_FAILED
        }
    }


    // MARK: - CustomStringConvertible

    override open var description: String {
        get {
            if self is Descriptible {
                return (self as! Descriptible).toString()
            }else{
                return self.toJSONString(true)
            }
        }
    }
    
}
