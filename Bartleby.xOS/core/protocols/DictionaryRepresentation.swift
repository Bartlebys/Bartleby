//
//  DicitionaryRepresentation.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 15/05/2016.
//
//

import Foundation

public protocol DictionaryRepresentation {
    /**
     returns a dictionary
     
     - returns: the dictionary representation
     */
    func dictionaryRepresentation()->[String:AnyObject]


    /**
     Applies the values stored in the dictionary representation to self.

     - parameter dictionaryRepresentation: a dictionary
     */
    func patchFrom(_ dictionaryRepresentation:[String:AnyObject])
    
}
