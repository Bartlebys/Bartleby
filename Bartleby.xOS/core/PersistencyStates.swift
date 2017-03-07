//
//  PersistencyStates.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/03/2017.
//
//

import Foundation


public enum PersistencyStates:StateMessage{

    public typealias RawValue = String

    case undefined
    case collectionsDataHasBeenDecrypted
    case documentWillSave
    case documentDidSave

    public init?(rawValue: PersistencyStates.RawValue) {
        self = .undefined
        if rawValue=="collectionsDataHasBeenDecrypted"{
            self = .collectionsDataHasBeenDecrypted
        }
        if rawValue=="documentWillSave"{
            self = .documentWillSave
        }
        if rawValue=="documentDidSave"{
            self = .documentDidSave
        }
    }

    public var rawValue: String{
        switch self {
        case .undefined:
            return "undefined"
        case .collectionsDataHasBeenDecrypted:
            return "collectionsDataHasBeenDecrypted"
        case .documentWillSave:
            return "documentWillSave"
        case .documentDidSave:
            return "documentDidSave"
        }

    }
    
}
