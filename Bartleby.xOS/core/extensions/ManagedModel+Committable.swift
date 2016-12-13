//
//  ManagedModel+Distribuable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

extension ManagedModel:Committable{


    // MARK: Commit


    /// Returns if the Object should be committed
    open var shouldBeCommitted: Bool {
        return self._shouldBeCommitted
    }

    // You can in specific situation mark that an instance should be committed by calling this method.
    // For example after a bunch of un supervised changes.
    open func needsToBeCommitted(){
        self._shouldBeCommitted=true
    }

    // Marks the entity as committed and increments it provisionning counter
    open func hasBeenCommitted(){
        self._shouldBeCommitted=false
        self._commitCounter += 1
    }

    // Returns the current commit counter
    public var commitCounter: UInt {
        return UInt(self._commitCounter)
    }

    // MARK: Changes

    /// Perform changes without commit
    ///
    /// - parameter changes: the changes
    open func doNotCommit(_ changes:()->()){
        let autoCommitIsEnabled = self._autoCommitIsEnabled
        self._autoCommitIsEnabled=false
        changes()
        self._autoCommitIsEnabled = autoCommitIsEnabled
    }


}
