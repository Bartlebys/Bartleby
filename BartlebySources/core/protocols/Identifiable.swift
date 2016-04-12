//
//  Identifiable.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 23/09/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation


// MARK: - Equatable

func ==(lhs: Identifiable, rhs: Identifiable) -> Bool{
    return lhs.UID==rhs.UID
}

public protocol Identifiable{
    
    // The unique identifier
    var UID:String { get }

}