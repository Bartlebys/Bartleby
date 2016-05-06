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

// MARK: - Aliasing

// We uses Aliases to reference external enities.

public func arrayOfAliases<T: Collectible>() -> [Alias<T>] {
    return [Alias<T>]()
}


public func removeAliasWith<T: Collectible>(instanceUID: String, inout from aliases: [Alias<T>]) {
    for (index, alias) in aliases.enumerate().reverse() {
        if alias.iUID==instanceUID {
            aliases.removeAtIndex(index)
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

public func instancesToAliases<T: Collectible>(instances: [Collectible]) -> [Alias<T>] {
    var aliases=[Alias<T>]()
    for instance in instances {
        aliases.append(instance.toAlias())
    }
    return aliases
}

//!!! <- ASYNC is a must
public func instancesFromAliases<T: Collectible>(aliases: [Alias<T>]) -> [T] {
    var instances=[T]()
    for alias in aliases {
        /*
        if let instance: T=alias.toInstance() {
            instances.append(instance)
        }
 */
    }
    return instances
}
