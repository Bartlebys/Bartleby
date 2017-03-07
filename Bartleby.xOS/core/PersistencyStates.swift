//
//  PersistencyStates.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/03/2017.
//
//

import Foundation


public enum PersistencyStates:StateMessage{
    
    case collectionsDataHasBeenDecrypted
    case documentWillSave
    case documentDidSave
    
}
