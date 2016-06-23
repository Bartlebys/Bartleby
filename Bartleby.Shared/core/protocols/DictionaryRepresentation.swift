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
     Should return a dictionary composed of native members that can be serialized (!)
     
     - returns: the dictionary
     */
    func dictionaryRepresentation()->[String:AnyObject]
    
}
