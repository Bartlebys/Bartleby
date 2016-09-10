//
//  Global.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 06/05/2016.
//
//  A set of general global functions

import Foundation



// MARK: - bartleby Print


public var DEFAULT_BPRINT_CATEGORY: String="Default"

public protocol BprintCategorizable {
    static var BPRINT_CATEGORY: String { get }
}



/**
 Returns a category for bprint

 - parameter subject: the subject to classify

 - returns: a string representing the category
 */
public func bprintCategoryFor(_ subject: AnyObject) -> String {
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
public func bprint(_ message: AnyObject, file: String, function: String, line: Int, category: String=DEFAULT_BPRINT_CATEGORY,decorative:Bool=false) {
    Bartleby.bprint(message, file: file, function: function, line: line, category:category,decorative: decorative)
}






// MARK: - ExternalReferences facilities


/**
 Removes and external references

 - parameter instanceUID:        its UID
 - parameter externalReferences: the reference to the externalReferences collection
 */
public func removeExternalReferenceWith(_ instanceUID: String, from externalReferences: inout [ExternalReference]) {
    if let idx=externalReferences.index(where: {$0.iUID == instanceUID}){
        externalReferences.remove(at: idx)
    }
}



public func instancesToExternalReferences<T: Collectible>(_ instances: [T]) -> [ExternalReference] {
    var externalReferences=[ExternalReference]()
    for instance in instances {
        externalReferences.append(ExternalReference(from:instance))
    }
    return externalReferences
}


public func instancesFromExternalReferences<T: Collectible>(_ externalReferences: [ExternalReference]) -> [T] {
    var instances=[T]()
    for reference in externalReferences {
        if let instance: T=reference.toLocalInstance() {
            instances.append(instance)
        }
    }
    return instances
}




public enum GlobalQueue {

    case main
    case userInteractive
    case userInitiated
    case utility
    case background

     public func get() -> DispatchQueue {
        switch self {
        case .main:
            return DispatchQueue.main
        case .userInteractive:
            return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
        case .userInitiated:
            return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
        case .utility:
            return DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
        case .background:
            return DispatchQueue.global(qos: DispatchQoS.QoSClass.background)

        }
    }
}
