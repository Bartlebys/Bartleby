//
//  JObject.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 16/09/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif


// MARK: - Equatable

public func ==(lhs: JObject, rhs: JObject) -> Bool {
    return lhs.UID==rhs.UID
}


// JOBjects are polyglot They can be serialized in multiple dialects ... (Mappable, NSecureCoding, ...)
// Currently the name Mangling @objc(JObject) is necessary to be able to pass a JObject in an XPC call.
// During XPC calls the Module varies (BartlebyKit in the framework, BSyncXPC, ...)
// NSecureCoding does not implement Universal Strategy the module is prepended to the name.
// By putting @objc(name) we fix the serialization name.
// This is due to the impossibility to link a FrameWork to an XPC services.
@objc(JObject) open class JObject: NSObject,Collectible, Mappable, NSCopying, NSSecureCoding {

    // MARK: - Initializable

    override required public init() {
        super.init()
    }

    // A reference to the document
    // Most of the JObject contains a reference to the document
    open var document:BartlebyDocument?

    // On object insertion or Registry deserialization
    // We setup this collection reference
    // On newUser we setup directly user.document.
    open var collection:CollectibleCollection?{
        didSet{
            if let registry=collection?.registry{
                self.document=registry
            }
        }
    }

    // MARK: - Collectible = Identifiable, Serializable, Supervisable,DictionaryRepresentation, UniversalType

    // MARK: UniversalType

    // Used to store the type name on serialization
    fileprivate var _typeName: String?

    // The type name is Universal and used when serializing the instance
    open class func typeName() -> String {
        return "JObject"
    }

    internal var _runTimeTypeName: String?

    // The runTypeName is used when deserializing the instance.
    open func runTimeTypeName() -> String {
        guard let _ = self._runTimeTypeName  else {
            self._runTimeTypeName = NSStringFromClass(type(of: self))
            return self._runTimeTypeName!
        }
        return self._runTimeTypeName!
    }

    /// The internal flag for auto commit
    fileprivate var _shouldBeCommitted: Bool = false

    open var changedKeys=[KeyedChanges]()

    // MARK: Distribuable

    open var toBeCommitted: Bool { return self._shouldBeCommitted }

    fileprivate var _autoCommitIsEnabled: Bool = true


    /**
     Locks the auto commit observer
     */
    open func disableAutoCommit(){
        self._autoCommitIsEnabled=false
    }

    /**
     Unlock the auto commit observer
     */
    open func enableAutoCommit(){
        self._autoCommitIsEnabled=true
    }


    //Collectible protocol: committed
    open var committed: Bool = false {
        willSet {
            if newValue==true{
                // The changes have been committed
                self._shouldBeCommitted=false
                self.changedKeys.removeAll()
            }
        }
        didSet {
        }
    }

    //Collectible protocol: distributed
    open var distributed: Bool = false

    // MARK: Supervisable

    fileprivate var _supervisers=[String:SupervisionClosure]()

    /**
     Tags the changed keys
     And Mark that the instance requires to be committed if the auto commit observer is active
     This method stores in memory changed Keys to allow Bartleby's runtime inspections

     Supervisers closure call and properties uses the Main queue.

     - parameter key:      the key
     - parameter oldValue: the oldValue
     - parameter newValue: the newValue
     */
    open func provisionChanges(forKey key:String,oldValue:AnyObject?,newValue:AnyObject?){

        if self._autoCommitIsEnabled == true {
            // Set up the commit flag
            self._shouldBeCommitted=true
        }

        // Commit is related to distribution
        // Supervision is a local  "observation" mecanism
        // Supervision Closures are invoked on the main queue asynchronously
        if self._supervisionIsEnabled{
            GlobalQueue.main.get().async {

                if key=="*" && !(self is CollectibleCollection){
                    // Dictionnary or NSData Patch
                    self.changedKeys.append(KeyedChanges(key:key,changes:"\(type(of: self).typeName()) \(self.UID) has been patched"))
                    self.collection?.provisionChanges(forKey: "item", oldValue: self, newValue: self)
                }else{
                    if let collection = self as? CollectibleCollection {
                        let entityName=Pluralization.singularize(collection.d_collectionName)
                        if key=="items"{
                            if let oldArray=oldValue as? [JObject], let newArray=newValue as? [JObject]{
                                if oldArray.count < newArray.count{
                                    let stringValue:String! = (newArray.last?.UID ?? "")
                                    self.changedKeys.append(KeyedChanges(key:key,changes:"Added a new \(entityName) \(stringValue))"))
                                }else{
                                    self.changedKeys.append(KeyedChanges(key:key,changes:"Removed One \(entityName)"))
                                }
                            }
                        }
                        if key == "item" {
                            let stringValue:String! = newValue?.UID ?? ""
                            self.changedKeys.append(KeyedChanges(key:key,changes:"\(entityName) \(stringValue) has changed"))
                        }

                        if key == "*" {
                            self.changedKeys.append(KeyedChanges(key:key,changes:"This collection has been patched"))
                        }
                    }else if let collectibleNewValue = newValue as? Collectible{
                        // Collectible objects
                        self.changedKeys.append( KeyedChanges(key:key,changes:"\(collectibleNewValue.runTimeTypeName()) \(collectibleNewValue.UID) has changed"))
                        // Relay the as a global change to the collection
                        self.collection?.provisionChanges(forKey: "item", oldValue: self, newValue: self)
                    }else{
                        // Natives types
                        let o = oldValue ?? "nil"
                        let n = newValue ?? "nil"
                        self.changedKeys.append( KeyedChanges(key:key,changes:"\(o!)->\(n!)"))
                        // Relay the as a global change to the collection
                        self.collection?.provisionChanges(forKey: "item", oldValue: self, newValue: self)
                    }
                }
                // Invoke the closures (changes Observers)
                for (_,supervisionClosure) in self._supervisers{
                    supervisionClosure(key: key,oldValue: oldValue,newValue: newValue)
                }
            }
        }

    }


    /**
     Adds a closure superviser
     Supervision Closure are called on the Main Queue.

     - parameter observer: the observer
     - parameter closure:  the closure to be called.
     */
    open func addChangesSuperviser(_ superviser:Identifiable, closure:@escaping SupervisionClosure) {
        _supervisers[superviser.UID]=closure
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

    deinit{
        self._supervisers.removeAll()
    }


    fileprivate var _supervisionIsEnabled: Bool = true

    /**
     Locks the supervision mecanism
     Supervision mecanism == tracks the changed keys and relay to the holding collection
     The supervision works even on Triggered Upsert
     */
    open func disableSupervision() {
        self._supervisionIsEnabled=false
    }

    /**
     UnLocks the supervision mecanism
     */
    open func enableSupervision() {
        self._supervisionIsEnabled=true
    }


    //Collectible protocol: The Creator UID
    open var creatorUID: String = "\(Default.NO_UID)" {
        didSet{
            if creatorUID != oldValue{
                self.provisionChanges(forKey: "creatorUID",oldValue: oldValue as AnyObject?,newValue: creatorUID as AnyObject?)
            }
        }
    }

    // The object summary can be used for example by externalReferences to describe the JObject instance.
    // If you want to disclose more information you can adopt the Descriptible protocol.
    open var summary: String? {
        didSet{
            if summary != oldValue{
                self.provisionChanges(forKey: "summary",oldValue: oldValue as AnyObject?,newValue: summary as AnyObject?)
            }
        }
    }

    // MARK: Collection Name

    // Needs to be overriden to determine in wich collection the instances will be 'stored
    class open var collectionName: String {
        return "JObjects"
    }

    open var d_collectionName: String {
        return JObject.collectionName
    }


    // An instance Marked ephemeral will be destroyed server side on next ephemeral cleaning procedure.
    // This flag allows for example to remove entities that have been for example created by unit-tests.
    open var ephemeral: Bool=false


    // MARK: Serializable

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


    open func updateData(_ data: Data,provisionChanges:Bool) throws -> Serializable {
        if let JSONDictionary = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as? [String:AnyObject] {
            let map=Map(mappingType: .fromJSON, JSONDictionary: JSONDictionary)
            self.mapping(map)
            if provisionChanges{
                self.provisionChanges(forKey: "*", oldValue: self, newValue: self)
            }

        }
        return self
    }

    // MARK: Identifiable

    // This  id is always  created locally and used as primary index by MONGODB
    fileprivate var _id: String=Default.NO_UID {
        didSet {
            // tag ephemeral instance
            if Bartleby.ephemeral {
                self.ephemeral=true
            }
            // And register.
            Registry.register(self)
        }
    }


    /**
     The creation of a Unique Identifier is ressource intensive.
     We create the UID only if necessary.
     */
    open func defineUID() {
        if self._id == Default.NO_UID {
            self._id=Bartleby.createUID()
        }
    }

    final public var UID: String {
        get {
            self.defineUID()
            return self._id
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

    // MARK: - ToJSON

    open func toJSONString(_ prettyPrint:Bool)->String{
        if let j=Mapper().toJSONString(self, prettyPrint:prettyPrint) {
            return j
        } else {
            return "{}"
        }
    }

    // MARK: - Mappable

    public required init?(_ map: Map) {
        super.init()
    }


    open func mapping(_ map: Map) {
        self.disableSupervisionAndCommit()
        // store the changedKeys in memory
        let changedKeys=self.changedKeys
        if map.mappingType == .toJSON {
            // Define if necessary the UID
            self.defineUID()
            // Store the universal type Name
            self._typeName=type(of: self).typeName()
        }
        self._id <- map[Default.UID_KEY]
        self._typeName <- map[Default.TYPE_NAME_KEY]
        self.committed <- map["committed"]
        self.distributed <- map["distributed"]
        self.creatorUID <- map["creatorUID"]
        self.summary <- map["summary"]
        self._shouldBeCommitted <- map["_toBeCommitted"]
        self.ephemeral <- map["ephemeral"]

        // Changed keys are not serialized
        self.changedKeys=changedKeys
        self.enableSuperVisionAndCommit()

    }


    open func disableSupervisionAndCommit(){
        self.disableSupervision()
        self.disableAutoCommit()
    }

    open func enableSuperVisionAndCommit(){
        self.enableSupervision()
        self.enableAutoCommit()
    }



    // MARK: - NSecureCoding


    public required init?(coder decoder: NSCoder) {
        super.init()
        self.disableSupervisionAndCommit()
        self.defineUID()
        self._id=String(decoder.decodeObject(of: NSString.self, forKey: Default.UID_KEY)! as NSString)
        self._typeName=type(of: self).typeName()
        self.committed=decoder.decodeBool(forKey: "committed")
        self.distributed=decoder.decodeBool(forKey: "distributed")
        self.creatorUID=String(decoder.decodeObject(of: NSString.self, forKey: "creatorUID")! as NSString)
        self.summary=String(describing: decoder.decodeObject(of: NSString.self, forKey:"summary") as NSString?)
        self._shouldBeCommitted=decoder.decodeBool(forKey: "_toBeCommitted")
        self.ephemeral=decoder.decodeBool(forKey: "ephemeral")
        self.enableSuperVisionAndCommit()
    }

    open func encode(with coder: NSCoder) {
        self._typeName=type(of: self).typeName()// Store the universal type name on serialization
        coder.encode(self._typeName, forKey: Default.TYPE_NAME_KEY)
        coder.encode(self._id, forKey: Default.UID_KEY)
        coder.encode(self.committed, forKey:"committed")
        coder.encode(self.distributed, forKey:"distributed")
        coder.encode(self.creatorUID, forKey:"creatorUID")
        if let summary = self.summary {
            coder.encode(summary, forKey:"summary")
        }
        coder.encode(self._shouldBeCommitted, forKey: "_toBeCommitted")
        coder.encode(self.ephemeral, forKey: "ephemeral")
    }


    public class var supportsSecureCoding : Bool {
        return true
    }


    // MARK: - NSCopying


    open func copy(with zone: NSZone?) -> Any {
        let data: Data=JSerializer.serialize(self)
        if let copied = try? JSerializer.deserialize(data) {
            return copied as! AnyObject
        }
        bprint("ERROR with Copy with zone on \(self._runTimeTypeName) \(self.UID) ", file:#file, function:#function, line:#line)
        return self as AnyObject
    }


}


// MARK: - DictionaryRepresentation

extension JObject:DictionaryRepresentation {

    public func dictionaryRepresentation()->[String:AnyObject] {
        self.defineUID()
        return Mapper().toJSON(self)
    }

    public func patchFrom(_ dictionaryRepresentation:[String:AnyObject]){
        let mapped=Map(mappingType: .fromJSON, JSONDictionary: dictionaryRepresentation)
        self.mapping(mapped)
        self.provisionChanges(forKey: "*", oldValue: self, newValue: self)
    }
}


/**
 *  A simple Objc compliant object to keep track of changes in memory
 */
@objc(KeyedChanges) open class KeyedChanges:NSObject {
    
    var elapsed=Bartleby.elapsedTime
    var key:String
    var changes:String
    
    init(key:String,changes:String) {
        self.key=key
        self.changes=changes
    }
}

