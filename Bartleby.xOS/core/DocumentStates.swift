//
//  DocumentStates.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/03/2017.
//
//

import Foundation

public enum DocumentStates: StateMessage {
    case collectionsDataHasBeenDecrypted
    case documentWillSave
    case documentDidSave

    case cleanUp
}
