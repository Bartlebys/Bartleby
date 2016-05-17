//
//  Global.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 06/05/2016.
//
//  A set of general global functions

import Foundation


// MARK: - bartleby Print

/**
Print indirection with guided contextual info
Usage : bprint("<Message>",file:#file,function:#function,line:#line")
You can create code snippet

- parameter items: the items to print
- parameter file:  the file
- parameter line:  the line
- parameter function : the function name
- parameter context: a contextual string
*/
public func bprint(message: AnyObject?, file: String = "", function: String = "", line: Int = -1) {
    Bartleby.bprint(message, file: file, function: function, line: line)
}

// MARK: - ExternalReferencing


public func removeExternalReferenceWith(instanceUID: String, inout from externalReferences: [ExternalReference]) {
    for (index, reference) in externalReferences.enumerate().reverse() {
        if reference.iUID==instanceUID {
            externalReferences.removeAtIndex(index)
        }
    }
}

public func deReferenceInstanceWithUID<T: Collectible>(instanceUID: String, inout from collection: [T]) {
    for (index, instance) in collection.enumerate().reverse() {
        if instance.UID==instanceUID {
            collection.removeAtIndex(index)
        }
    }
}

public func instancesToExternalReferences<T: Collectible>(instances: [T]) -> [ExternalReference] {
    var externalReferences=[ExternalReference]()
    for instance in instances {
        externalReferences.append(ExternalReference(from:instance))
    }
    return externalReferences
}


public func instancesFromExternalReferences<T: Collectible>(externalReferences: [ExternalReference]) -> [T] {
    var instances=[T]()
    for reference in externalReferences {
        if let instance: T=reference.toLocalInstance() {
            instances.append(instance)
        }

    }
    return instances
}


enum GlobalQueue {

    case Main
    case UserInteractive
    case UserInitiated
    case Utility
    case Background

     func get() -> dispatch_queue_t {
        switch self {
        case .Main:
            return dispatch_get_main_queue()
        case .UserInteractive:
            if #available(OSX 10.10, *) {
                return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
            } else {
                return dispatch_get_main_queue()
            }
        case .UserInitiated:
            if #available(OSX 10.10, *) {
                return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
            } else {
               return dispatch_get_main_queue()
            }
        case .Utility:
            if #available(OSX 10.10, *) {
                return dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
            } else {
                return dispatch_get_main_queue()
            }
        case .Background:
            if #available(OSX 10.10, *) {
                return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
            } else {
                return dispatch_get_main_queue()
            }
        }
    }
}
