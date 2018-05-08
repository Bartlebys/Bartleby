//
//  BoxStates.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/03/2017.
//
//

import Foundation

public enum BoxStates: StateMessage {
    case isMounting(box: Box)
    case hasBeenMounted(box: Box)
    case mountingHasFailed(boxUID: String, message: String)
}
