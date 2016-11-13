//
//  BartlebyObject+BaseImplementation.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/10/2016.
//
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif


/*

 IMPORTANT NOTE

 - you should always manipulate collections data  on the main thread
 - including any BartlebyObject Property.

 BartlebyObject is primary object of any Bartleby model.
 BartlebyObjects are polyglot They can be serialized in multiple dialects ... (Mappable, NSecureCoding, ...)
 Currently the name Mangling @objc(BartlebyObject) is necessary to be able to pass a BartlebyObject in an XPC call.
 During XPC calls the Module varies (BartlebyKit in the framework, BSyncXPC, ...)
 NSecureCoding does not implement Universal Strategy the module is prepended to the name.
 By putting @objc(name) we fix the serialization name.
 This is due to the impossibility to link a FrameWork to an XPC services.

*/

// MARK: - Equatable

public func ==(lhs: BartlebyObject, rhs: BartlebyObject) -> Bool {
    return lhs.UID==rhs.UID
}


public enum ObjectExpositionError:Error {
    case UnknownKey(key:String,forTypeName:String)
}



// MARK: - Supervisable

extension BartlebyObject{


    /**
     The change provisionning is related to multiple essential notions.

     ## **Supervision** is a local  "observation" mecanism
     We use supervision to determine if an object has changed.
     Properties that are declared `supervisable` provision their changes using this method.

     ## **Commit** is the first phase of the **distribution** mecanism (the second is Push, and the Third Trigger and integration on another node)
     If auto-commit is enabled on any supervised change an object is marked  to be committed `_shouldBeCommitted=true`

     ## You can add **supervisers** to any BartlebyObject.
     On supervised change the closure of the supervisers will be invoked.

     ## **Inspection** During debbuging or when  Bartleby's inspector is opened we record and analyse the changes
     If Bartleby.inspectable we store in memory the changes changed Keys to allow Bartleby's runtime inspections
     (we use  `KeyedChanges` objects)

     `provisionChanges` is the entry point of those mecanisms.

     - parameter key:      the key
     - parameter oldValue: the oldValue
     - parameter newValue: the newValue
     */
    open func provisionChanges(forKey key:String,oldValue:Any?,newValue:Any?){
        if !(self is Shadow){
            if self._autoCommitIsEnabled == true {
                // Set up the commit flag
                self._shouldBeCommitted=true
            }

            if self._supervisionIsEnabled{

                if key=="*" && !(self is BartlebyCollection){
                    if self.isInspectable {
                        // Dictionnary or NSData Patch
                        self._appendChanges(key:key,changes:"\(type(of: self).typeName()) \(self.UID) has been patched")
                    }
                    self.collection?.provisionChanges(forKey: "item", oldValue: self, newValue: self)
                }else{
                    if let collection = self as? BartlebyCollection {
                        if self.isInspectable {
                            let entityName=Pluralization.singularize(collection.d_collectionName)
                            if key=="items"{
                                if let oldArray=oldValue as? [BartlebyObject], let newArray=newValue as? [BartlebyObject]{
                                    if oldArray.count < newArray.count{
                                        let stringValue:String! = (newArray.last?.UID ?? "")
                                        self._appendChanges(key:key,changes:"Added a new \(entityName) \(stringValue))")
                                    }else{
                                        self._appendChanges(key:key,changes:"Removed One \(entityName)")
                                    }
                                }
                            }
                            if key == "item" {
                                if let o = newValue as? BartlebyObject{
                                    self._appendChanges(key:key,changes:"\(entityName) \(o.UID) has changed")
                                }else{
                                    self._appendChanges(key:key,changes:"\(entityName) has changed anomaly")
                                }
                            }
                            if key == "*" {
                                self._appendChanges(key:key,changes:"This collection has been patched")
                            }
                        }
                    }else if let collectibleNewValue = newValue as? Collectible{
                        if self.isInspectable {
                            // Collectible objects
                            self._appendChanges(key:key,changes:"\(collectibleNewValue.runTimeTypeName()) \(collectibleNewValue.UID) has changed")
                        }
                        // Relay the as a global change to the collection
                        self.collection?.provisionChanges(forKey: "item", oldValue: self, newValue: self)
                    }else{
                        // Natives types
                        let o = oldValue ?? "void"
                        let n = newValue ?? "void"
                        if self.isInspectable {
                            self._appendChanges(key:key,changes:"\(o) ->\(n)")
                        }
                        // Relay the as a global change to the collection
                        self.collection?.provisionChanges(forKey: "item", oldValue: self, newValue: self)
                    }
                }

                // Invoke the closures (changes Observers)
                // note that it occurs even changes are not inspectable.
                for (_,supervisionClosure) in self._supervisers{
                    supervisionClosure(key,oldValue,newValue)
                }
                
            }

        }

    }


    /// Return true if the inspector has been openned.
    open var isInspectable:Bool{
        get{
            var inspectable=false
            if let m=self.document?.metadata{
                inspectable=m.changesAreInspectables
            }
            return inspectable
        }
    }




    /// **Inspection**
    /// Appends the change to the changedKey
    ///
    /// - parameter key:     the key
    /// - parameter changes: the description of the changes
    private func _appendChanges(key:String,changes:String){
        let kChanges=KeyedChanges()
        kChanges.key=key
        kChanges.changes=changes
        self.changedKeys.append(kChanges)
    }

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


// MARK: - Distribuable

extension BartlebyObject{

    /// Perform changes without commit
    ///
    /// - parameter changes: the changes
    open func doNotCommit(_ changes:()->()){
        let autoCommitIsEnabled = self._autoCommitIsEnabled
        self._autoCommitIsEnabled=false
        changes()
        self._autoCommitIsEnabled = autoCommitIsEnabled
    }


    /// Returns if the Object should be committed
    open var shouldBeCommitted: Bool {
        return self._shouldBeCommitted
    }

}


// MARK: - Serializable

extension BartlebyObject{

    open func serialize() -> Data {
        let dictionaryRepresentation = self.dictionaryRepresentation()
        do {
            if Bartleby.configuration.HUMAN_FORMATTED_SERIALIZATON_FORMAT {
                return try JSONSerialization.data(withJSONObject: dictionaryRepresentation, options:[JSONSerialization.WritingOptions.prettyPrinted])
            } else {
                return try JSONSerialization.data(withJSONObject: dictionaryRepresentation, options:[])
            }
        } catch {
            return Data()
        }
    }


    /// Serialize the current object to an UTF8 string
    ///
    /// - Returns: return an UTF8 string
    open func serializeToUFf8String()->String{
        return self.toJSONString(false)
    }

    open func updateData(_ data: Data,provisionChanges:Bool) throws -> Serializable {
        if let JSONDictionary = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as? [String:AnyObject] {
            let map=Map(mappingType: .fromJSON, JSON: JSONDictionary)
            self.mapping(map: map)
            if provisionChanges && self.isInspectable {
                self.provisionChanges(forKey: "*", oldValue: self, newValue: self)
            }
        }
        return self
    }


    /// Merge the instance with another
    ///
    /// - parameter instance: the instance
    open func mergeWith(_ instance: Exposed) throws {
        for key in instance.exposedKeys{
            if self.exposedKeys.contains(key){
                let value = try instance.getExposedValueForKey(key)
                try self.setExposedValue(value, forKey: key)
            }else{
                self.log("Attempt to merge an unexisting key \(key) on \(instance))", file: #file, function: #function, line: #line, category: logsCategoryFor(self), decorative: false)
            }
        }
    }

}


// MARK: - DictionaryRepresentation

extension BartlebyObject {

    open func dictionaryRepresentation()->[String:Any] {
        self.defineUID()
        return Mapper().toJSON(self)
    }


}

extension BartlebyObject{

    // MARK:-  JSONString

    open func toJSONString(_ prettyPrint:Bool)->String{
        if let j=Mapper().toJSONString(self, prettyPrint:prettyPrint) {
            return j
        } else {
            return "{}"
        }
    }

    // MARK: - CustomStringConvertible


    override open var description: String {
        get {
            if self is Descriptible {
                return (self as! Descriptible).toString()
            }
            if let j=Mapper().toJSONString(self, prettyPrint:false) {
                return j
            } else {
                return "{}"
            }
        }
    }
    
}




extension BartlebyObject{

    /**
     Print indirection with contextual informations.

     - parameter message: the message
     - parameter file:  the file
     - parameter line:  the line
     - parameter function : the function name
     - parameter category: a categorizer string
     - parameter decorative: if set to true only the message will be displayed.
     */
    open func log(_ message: Any, file: String, function: String, line: Int, category: String,decorative:Bool=false) {
        self.document?.log(message, file: file, function: function, line: line, category: category, decorative: decorative)
    }
}



// MARK: - NSCopying

extension BartlebyObject : NSCopying{

    open func copy(with zone: NSZone?) -> Any {
        let data: Data=JSerializer.serialize(self)
        if let copied = try? JSerializer.deserialize(data) {
            return copied as AnyObject
        }
        self.log("ERROR with Copy with zone on \(self._runTimeTypeName) \(self.UID) " as AnyObject, file:#file, function:#function, line:#line,category:Default.LOG_CATEGORY)
        return self as AnyObject
    }
    
}


