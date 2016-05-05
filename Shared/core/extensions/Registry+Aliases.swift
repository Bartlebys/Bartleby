//
//  Registry+Aliases.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 05/05/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation


extension Registry {
    // MARK: - Instances aliasing


    /**
     Transform an instance to an Alias

     - parameter instance: the instance

     - returns: the alias
     */
    static public func instanceToAlias(instance: Collectible) -> Alias {
        let alias=Alias(withInstanceUID: instance.UID)
        return alias
    }


    /**
     Transform an array of instance to aliases

     - parameter instances: the instance

     - returns: the aliases
     */
    static public func instanceToAliases(instances: [Collectible]) -> [Alias] {
        var aliases=[Alias]()
        for instance in instances {
            aliases.append(self.instanceToAlias(instance))
        }
        return aliases
    }


    /**
     Returns the local instance if found

     - parameter alias: the alias

     - returns: the local instance
     */
    static public func aliasToLocalInstance<T: Collectible>(alias: Alias) -> T? {
        return Registry.registredObjectByUID(alias.iUID) as T?
    }


    /**
     Returns the instances from a collection of aliases

     - parameter aliases: the collection of aliases

     - returns: the collection of instances.
     */
    static public func aliasesToLocalInstances<T: Collectible>(aliases: [Alias]) -> [T]? {
        var instances = [T]()
        for alias in aliases {
            if let instance=Registry.registredObjectByUID(alias.iUID) as T? {
                instances.append(instance)
            }
        }
        return instances
    }

    /**
     A function that can be used by generative handlers.

     - returns: an array of aliases
     */
    static public func arrayOfAliases() -> [Alias] {
        return [Alias]()
    }


    /**
     Removes the alias(es) from a collection of Alias

     - parameter instanceUID: the instance UID
     - parameter aliases:     the collection
     */
    static public func removeAliasWith(instanceUID: String, inout from aliases: [Alias]) {
        for (index, alias) in aliases.enumerate().reverse() {
            if alias.iUID==instanceUID {
                aliases.removeAtIndex(index)
            }
        }
    }



    /**
     DeReference an instance(es) from a collection without deleting the instance

     - parameter instanceUID: the instance UID
     - parameter aliases:     the collection
     */
    static public func deReferenceInstanceWithUID<T: Collectible>(instanceUID: String, inout from collection: [T]) {
        for (index, instance) in collection.enumerate().reverse() {
            if instance.UID==instanceUID {
                collection.removeAtIndex(index)
            }
        }
    }

}
