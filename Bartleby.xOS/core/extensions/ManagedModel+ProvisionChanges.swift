//
//  ManagedModel+ProvisionChanges.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

extension ManagedModel: ProvisionChanges {
    /**
     The change provisionning is related to multiple essential notions.

     ## **Supervision** is a local mechanism used to determine if an object has changed.
     Properties that are declared `supervisable` provision their changes using this method.

     ## **Commit** is the first phase of the **distribution** mechanism (the second is Push, and the Third Trigger and integration on another node)
     If auto-commit is enabled on any supervised change an object is "staged" in its collection

     ## You can add **supervisers** to any ManagedModel.
     On supervised change the closure of the supervisers will be invoked.

     ## **Inspection** During debbuging or when  Bartleby's inspector is opened we record and analyse the changes
     If Bartleby.inspectable we store in memory the changes changed Keys to allow Bartleby's runtime inspections
     (we use  `KeyedChanges` objects)

     `provisionChanges` is the entry point of those mechanisms.

     - parameter key:      the key
     - parameter oldValue: the oldValue
     - parameter newValue: the newValue
     */
    open func provisionChanges(forKey key: String, oldValue: Any?, newValue: Any?) {
        // Invoke the closures (changes Observers)
        // note that it occurs even changes are not inspectable.
        for (_, supervisionClosure) in _supervisers {
            supervisionClosure(key, oldValue, newValue)
        }

        if _autoCommitIsEnabled == true {
            collection?.stage(self)
        }

        // Changes propagation & Inspection
        // Propagate item changes to its collections

        if key == "*" && !(self is BartlebyCollection) {
            if isInspectable {
                // Dictionnary or NSData Patch
                _appendChanges(key: key, changes: "\(type(of: self).typeName()) \(UID) has been patched")
            }
            collection?.provisionChanges(forKey: "item", oldValue: self, newValue: self)
        } else {
            if let collection = self as? BartlebyCollection {
                if isInspectable {
                    let entityName = Pluralization.singularize(collection.d_collectionName)
                    if key == "_items" {
                        if let oldArray = oldValue as? [ManagedModel], let newArray = newValue as? [ManagedModel] {
                            if oldArray.count < newArray.count {
                                let stringValue: String! = (newArray.last?.UID ?? "")
                                _appendChanges(key: key, changes: "Added a new \(entityName) \(stringValue))")
                            } else {
                                _appendChanges(key: key, changes: "Removed One \(entityName)")
                            }
                        }
                    }
                    if key == "item" {
                        if let o = newValue as? ManagedModel {
                            _appendChanges(key: key, changes: "\(entityName) \(o.UID) has changed")
                        } else {
                            _appendChanges(key: key, changes: "\(entityName) has changed anomaly")
                        }
                    }
                    if key == "*" {
                        _appendChanges(key: key, changes: "This collection has been patched")
                    }
                }
            } else if let collectibleNewValue = newValue as? Collectible {
                if isInspectable {
                    // Collectible objects
                    _appendChanges(key: key, changes: "\(collectibleNewValue.runTimeTypeName()) \(collectibleNewValue.UID) has changed")
                }
                // Relay the as a global change to the collection
                collection?.provisionChanges(forKey: "item", oldValue: self, newValue: self)
            } else {
                // Natives types
                let o = oldValue ?? "void"
                let n = newValue ?? "void"
                if isInspectable {
                    _appendChanges(key: key, changes: "\(o) ->\(n)")
                }
                // Relay the as a global change to the collection
                collection?.provisionChanges(forKey: "item", oldValue: self, newValue: self)
            }
        }
    }

    /// Performs the deserialization without invoking provisionChanges
    ///
    /// - parameter changes: the changes closure
    public func quietChanges(_ changes: () -> Void) {
        _quietChanges = true
        changes()
        _quietChanges = false
    }

    /// Performs the deserialization without invoking provisionChanges
    ///
    /// - parameter changes: the changes closure
    public func quietThrowingChanges(_ changes: () throws -> Void) rethrows {
        _quietChanges = true
        try changes()
        _quietChanges = false
    }

    // MARK: -

    public var wantsQuietChanges: Bool {
        return _quietChanges
    }

    /// **Inspection**
    /// Appends the change to the changedKey
    ///
    /// - parameter key:     the key
    /// - parameter changes: the description of the changes
    private func _appendChanges(key: String, changes: String) {
        let kChanges = KeyedChanges()
        kChanges.key = key
        kChanges.changes = changes
        changedKeys.append(kChanges)
    }

    open func stage() {
        collection?.stage(self)
    }
}
