//
//  Supervisable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 20/07/2016.
//
//

import Foundation


public typealias SupervisionClosure = (_ key:String,_ oldValue:Any?,_ newValue:Any?)->()

public protocol Supervisable {


    /**
     Adds a closure observer

     - parameter observer: the observer
     - parameter closure:  the closure to be called.
     */
    func addChangesSuperviser(_ superviser:Identifiable, closure:@escaping SupervisionClosure)

    /**
     Remove the observer's closure

     - parameter observer: the observer.
     */
    func removeChangesSuperviser(_ superviser:Identifiable)


}

