//
//  BartlebyObject+Distribuable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

extension BartlebyObject:Distribuable{


    /// Perform changes without commit
    ///
    /// - parameter changes: the changes
    open func doNotCommit(_ changes:()->()){
        let autoCommitIsEnabled = self._autoCommitIsEnabled
        self._autoCommitIsEnabled=false
        changes()
        self._autoCommitIsEnabled = autoCommitIsEnabled
    }


    /// Returns if the Object should be committed
    open var shouldBeCommitted: Bool {
        return self._shouldBeCommitted
    }

}
