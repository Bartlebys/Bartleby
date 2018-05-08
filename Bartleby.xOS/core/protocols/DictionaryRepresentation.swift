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
    func dictionaryRepresentation()->[String:Any]

}
