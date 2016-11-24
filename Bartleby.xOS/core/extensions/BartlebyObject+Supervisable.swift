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

}
