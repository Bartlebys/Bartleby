//
//  Global.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 06/05/2016.
//
//  A set of general global functions

import Foundation



/*

 // MARK: General Equatable implementation


public func == (lhs:[String:AnyObject], rhs: [String:AnyObject]) -> Bool {
    return NSDictionary(dictionary: lhs).isEqualToDictionary(rhs)
}

public func == (lhs: [String:AnyObject]?, rhs: [String:AnyObject]?) -> Bool {
    if let lhs=lhs, rhs=rhs {
       return lhs == rhs
    }
    if lhs==nil && rhs==nil{
        return true
    }else{
        return false
    }
}


public func == <T:Equatable> (lhs: [T], rhs: [T]) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    for i in 0...lhs.count {
        if lhs[i] != rhs [i] {
            return false
        }
    }
    return true
}


public  func == <T:Equatable> (lhs: [T]?, rhs: [T]?) -> Bool {
    if let lhs=lhs, rhs=rhs {
        if lhs.count != rhs.count {
            return false
        }
        for i in 0...lhs.count {
            if lhs[i] != rhs [i] {
                return false
            }
        }
    }
    if lhs==nil && rhs==nil{
        return true
    }else{
        return false
    }
}
*/

// MARK: - bartleby Print


public var DEFAULT_BPRINT_CATEGORY: String=""

public protocol BprintCategorizable {
    static var BPRINT_CATEGORY: String { get }
}



/**
 Returns a category for bprint

 - parameter subject: the subject to classify

 - returns: a string representing the category
 */
public func bprintCategoryFor(subject: AnyObject) -> String {
    if let s = subject as? Collectible {
        return s.d_collectionName
    }
    return DEFAULT_BPRINT_CATEGORY
}


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
public func bprint(message: AnyObject, file: String, function: String, line: Int, category: String=DEFAULT_BPRINT_CATEGORY,decorative:Bool=false) {
    Bartleby.bprint(message, file: file, function: function, line: line, category:category,decorative: decorative)
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
            return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
        case .UserInitiated:
            return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        case .Utility:
            return dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
        case .Background:
            return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)

        }
    }
}
