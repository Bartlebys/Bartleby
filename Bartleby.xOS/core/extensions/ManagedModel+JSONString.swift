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
        // #TODO
        //if let j=Mapper().toJSONString(self, prettyPrint:prettyPrint) {
        //    return j
        //} else {
            return "{}"
        //}
    }

    // MARK: - CustomStringConvertible

    override open var description: String {
        get {
            if self is Descriptible {
                return (self as! Descriptible).toString()
            }
           // #TODO
            //if let j=Mapper().toJSONString(self, prettyPrint:false) {
            // return j
            //} else {
                return "{}"
            //}
        }
    }
    
}
