//
//  Commitable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 20/07/2016.
//
//

import Foundation

public protocol Committable {

    /**

     Commits the changes in one bunch
     - returns: an array of UID.
     */
    func commitChanges() -> [String]
    
}
