//
//  Committable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 20/07/2016.
//
//

import Foundation


public protocol Committable {

    // MARK: Commit

    // You can in specific situation mark that an instance should be committed by calling this method.
    // For example after a bunch of un supervised changes.
    func needsToBeCommitted()

    // Marks the entity as committed and increments it provisionning counter
    func hasBeenCommitted()

    /// Shall we commit that instance during next autocommit?
    var shouldBeCommitted: Bool { get }

    // Returns the current commit counter
    var commitCounter:UInt { get }

    // MARK: Changes

    /// Perform changes without commit
    ///
    /// - parameter changes: the changes
    func doNotCommit(_ changes:()->())

}
