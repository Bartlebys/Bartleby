//
//  Distribuable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 20/07/2016.
//
//

import Foundation


public protocol Distribuable {

    // This flag is set to true on first commit.
    var committed: Bool { get set }

    // This flag should be set to true
    // When the collaborative server has acknowledged the object creation
    var pushed: Bool { get set }


    /// Shall we commit that instance during next autocommit?
    var shouldBeCommitted: Bool { get }

    /// Perform changes without commit
    ///
    /// - parameter changes: the changes
    func doNotCommit(_ changes:()->())
}
