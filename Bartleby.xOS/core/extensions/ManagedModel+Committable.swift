//
//  ManagedModel+Distribuable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

extension ManagedModel: Committable {

    // MARK: Commit

    // You can in specific situation mark that an instance should be committed by calling this method.
    // For example after a bunch of un supervised changes.
    open func needsToBeCommitted() {
        collection?.stage(self)
    }

    // Marks the entity as committed and increments it provisionning counter
    open func hasBeenCommitted() {
        commitCounter += 1
    }

    // MARK: Changes

    /// Perform changes without commit
    ///
    /// - parameter changes: the changes
    open func doNotCommit(_ changes: () -> Void) {
        let autoCommitIsEnabled = _autoCommitIsEnabled
        _autoCommitIsEnabled = false
        changes()
        _autoCommitIsEnabled = autoCommitIsEnabled
    }
}
