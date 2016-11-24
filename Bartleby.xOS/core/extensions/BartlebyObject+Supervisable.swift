//
//  BartlebyObject+Supervisable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

extension BartlebyObject:Supervisable{

    /**
     Adds a closure observer

     - parameter observer: the observer
     - parameter closure:  the closure to be called.
     */
    open func addChangesSuperviser(_ superviser: Identifiable, closure: @escaping (_ key:String,_ oldValue:Any?,_ newValue:Any?) -> ()) {
        self._supervisers[superviser.UID]=closure
    }



    /**
     Remove the observer's closure

     - parameter observer: the observer.
     */
    open func removeChangesSuperviser(_ superviser:Identifiable) {
        if let _=self._supervisers[superviser.UID]{
            self._supervisers.removeValue(forKey: superviser.UID)
        }
    }



    /// Performs some changes silently
    /// Supervision and auto commit are disabled.
    /// Then supervision and auto commit availability is restored
    ///
    /// - parameter changes: the changes closure
    open func silentGroupedChanges(_ changes:()->()){
        let autoCommitIsEnabled = self._autoCommitIsEnabled
        let supervisionIsEnabled = self._supervisionIsEnabled
        self._supervisionIsEnabled=false
        self._autoCommitIsEnabled=false
        changes()
        self._autoCommitIsEnabled = autoCommitIsEnabled
        self._supervisionIsEnabled = supervisionIsEnabled
    }

}
