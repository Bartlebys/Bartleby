//
//  Distribuable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 20/07/2016.
//
//

import Foundation


public protocol Distribuable {

    /// Shall we commit that instance during next autocommit?
    var toBeCommitted: Bool { get }

    /**
     Locks the auto commit observer
     */
    func disableAutoCommit()

    /**
     Unlock the auto commit observer
     */
    func enableAutoCommit()

    // This flag is set to true on first commit.
    var committed: Bool { get set }

    // This flag should be set to true
    // When the collaborative server has acknowledged the object creation
    var distributed: Bool { get set }
    
    
}