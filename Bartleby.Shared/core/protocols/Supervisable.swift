//
//  Supervisable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 20/07/2016.
//
//

import Foundation


public typealias SupervisionClosure = (key:String,oldValue:AnyObject?,newValue:AnyObject?)->()

public protocol Supervisable {

    // Supervision

    /**
     Tags the changed keys
     And Mark that the instance requires to be committed if the auto commit observer is active
     This mecanism can replace KVO if necessary.

     - parameter key:      the key
     - parameter oldValue: the oldValue
     - parameter newValue: the newValue
     */
    func provisionChanges(forKey key:String,oldValue:AnyObject?,newValue:AnyObject?)


    /**
     Adds a closure observer

     - parameter observer: the observer
     - parameter closure:  the closure to be called.
     */
    func addChangesObserver(observer:Identifiable, closure:SupervisionClosure)

    /**
     Remove the observer's closure

     - parameter observer: the observer.
     */
    func removeChangesObserver(observer:Identifiable)


    /**
     Locks the supervision mecanism
     Supervision mecanism == tracks the changed keys and relay to the holding collection
     The supervision works even on Triggered Upsert
     */
    func disableSupervision()

    /**
     Unlock the auto commit observer
     */
    func enableSupervision()
}

