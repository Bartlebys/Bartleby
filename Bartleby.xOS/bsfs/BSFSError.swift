//
//  BSFSError.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 08/11/2016.
//
//

import Foundation

/// BSFS error
enum BSFSError:Error{
    case boxDelegateIsNotAvailable
    case attemptToMountBoxMultipleTime(boxUID:String)
    case nodeIsNotAssemblable
}
