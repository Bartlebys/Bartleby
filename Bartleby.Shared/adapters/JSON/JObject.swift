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
@objc(JObject) public class JObject: NSObject,Collectible, Mappable, NSCopying, NSSecureCoding {

    // MARK: - Initializable

    override required public init() {
        super.init()
    }


    // On object insertion or Registry deserialization 
    // We setup this collection reference
    public var collection:CollectibleCollection?

    //Returns the registry
    public func getRegistry()->(Registry?){
        return self.collection?.registry
    }

    // MARK: - Collectible = Identifiable, Serializable, Supervisable,DictionaryRepresentation, UniversalType


    // MARK: UniversalType

    // Used to store the type name on serialization
    private var _typeName: String?

    // The type name is Universal and used when serializing the instance
    public class func typeName() -> String {
        return "JObject"
    }

    internal var _runTimeTypeName: String?

    // The runTypeName is used when deserializing the instance.
    public func runTimeTypeName() -> String {
        guard let _ = self._runTimeTypeName  else {
            self._runTimeTypeName = NSStringFromClass(self.dynamicType)
            return self._runTimeTypeName!
        }
        return self._runTimeTypeName!
    }

    /// The internal flag for auto commit
    private var _shouldBeCommitted: Bool = false


    public var changedKeys=[KeyedChanges]()

    // MARK: Supervisable

    public var toBeCommitted: Bool { return self._shouldBeCommitted }

    private var _observers=[String:SupervisionClosure]()

    /**
     Tags the changed keys
     And Mark that the instance requires to be committed if the auto commit observer is active
     - parameter key:      the key
     - parameter oldValue: the oldValue
     - parameter newValue: the newValue
     */
    public func provisionChanges(forKey key:String,oldValue:AnyObject?,newValue:AnyObject?){
        if self._supervisionIsEnabled == true {

            // Set up the commit flag
            self._shouldBeCommitted=true

            if let collection = self as? CollectibleCollection {
                self.changedKeys.append( KeyedChanges(key:key,changes:"\(collection.d_collectionName) did change. (\(collection.count))"))
            }else if let collectibleNewValue = newValue as? Collectible{
                changedKeys.append( KeyedChanges(key:key,changes:"\(collectibleNewValue.runTimeTypeName()) \(collectibleNewValue.UID) did change"))
            }else{
                changedKeys.append( KeyedChanges(key:key,changes:"\(oldValue ?? "nil" )->\(newValue ?? "nil" )"))
            }

            // Invoke the closures
            for (_,SupervisionClosure) in self._observers{
                SupervisionClosure(key: key,oldValue: oldValue,newValue: newValue)
            }
        }
    }


    /**
     Adds a closure observer

     - parameter observer: the observer
     - parameter closure:  the closure to be called.
     */
    public func addChangesObserver(observer:Identifiable, closure:SupervisionClosure) {
        _observers[observer.UID]=closure
    }

    /**
     Remove the observer's closure

     - parameter observer: the observer.
     */
    public func removeChangesObserver(observer:Identifiable) {
        if let _=self._observers[observer.UID]{
            self._observers.removeValueForKey(observer.UID)
        }
    }

    deinit{
        self._observers.removeAll()
    }


    // Prevent from autoCommit
    public func disableSupervision() {
        self._supervisionIsEnabled=false
    }

    // AutCommnit is possible
    public func enableSupervision() {
        self._supervisionIsEnabled=true
    }

    private var _supervisionIsEnabled: Bool = true


    //Collectible protocol: committed
    public var committed: Bool = false {
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
    public var distributed: Bool = false{
        didSet{
        }
    }

    //Collectible protocol: The Creator UID
    public var creatorUID: String = "\(Default.NO_UID)" {
        didSet{
            if creatorUID != oldValue{
                self.provisionChanges(forKey: "creatorUID",oldValue: oldValue,newValue: creatorUID)
            }
        }
    }

    // The object summary can be used for example by externalReferences to describe the JObject instance.
    // If you want to disclose more information you can adopt the Descriptible protocol.
    public var summary: String? {
        didSet{
            if summary != oldValue{
                self.provisionChanges(forKey: "summary",oldValue: oldValue,newValue: summary)
            }
        }
    }

    // MARK: Collection Name

    // Needs to be overriden to determine in wich collection the instances will be 'stored
    class public var collectionName: String {
        return "JObjects"
    }

    public var d_collectionName: String {
        return JObject.collectionName
    }


    // An instance Marked ephemeral will be destroyed server side on next ephemeral cleaning procedure.
    // This flag allows for example to remove entities that have been for example created by unit-tests.
    public var ephemeral: Bool=false


    // MARK: Serializable

    public func serialize() -> NSData {
        let dictionaryRepresentation = self.dictionaryRepresentation()
        do {
            if Bartleby.configuration.HUMAN_FORMATTED_SERIALIZATON_FORMAT {
                return try NSJSONSerialization.dataWithJSONObject(dictionaryRepresentation, options:[NSJSONWritingOptions.PrettyPrinted])
            } else {
                return try NSJSONSerialization.dataWithJSONObject(dictionaryRepresentation, options:[])
            }
        } catch {
            return NSData()
        }
    }


    public func updateData(data: NSData) throws -> Serializable {
        if let JSONDictionary = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments) as? [String:AnyObject] {
            let map=Map(mappingType: .FromJSON, JSONDictionary: JSONDictionary)
            self.mapping(map)
        }
        return self
    }

    // MARK: Identifiable

    // This  id is always  created locally and used as primary index by MONGODB
    private var _id: String=Default.NO_UID {
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
    public func defineUID() {
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


    override public var description: String {
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

    public func toJSONString(prettyPrint:Bool)->String{
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


    public func mapping(map: Map) {
        self.disableSupervision()
        self.defineUID()
        if map.mappingType == .ToJSON {
            // Store the universal type Name
            self._typeName=self.dynamicType.typeName()
        }
        self._id <- map[Default.UID_KEY]
        self._typeName <- map[Default.TYPE_NAME_KEY]
        self.committed <- map["committed"]
        self.distributed <- map["distributed"]
        self.creatorUID <- map["creatorUID"]
        self.summary <- map["summary"]
        self._shouldBeCommitted <- map["_toBeCommitted"]
        self.ephemeral <- map["ephemeral"]
        self.enableSupervision()
    }


    // MARK: - NSecureCoding


    public required init?(coder decoder: NSCoder) {
        super.init()
        self.disableSupervision()
        self.defineUID()
        self._id=String(decoder.decodeObjectOfClass(NSString.self, forKey: Default.UID_KEY)! as NSString)
        self._typeName=self.dynamicType.typeName()
        self.committed=decoder.decodeBoolForKey("committed")
        self.distributed=decoder.decodeBoolForKey("distributed")
        self.creatorUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "creatorUID")! as NSString)
        self.summary=String(decoder.decodeObjectOfClass(NSString.self, forKey:"summary") as NSString?)
        self._shouldBeCommitted=decoder.decodeBoolForKey("_toBeCommitted")
        self.ephemeral=decoder.decodeBoolForKey("ephemeral")
        self.enableSupervision()
    }

    public func encodeWithCoder(coder: NSCoder) {
        self._typeName=self.dynamicType.typeName()// Store the universal type name on serialization
        coder.encodeObject(self._typeName, forKey: Default.TYPE_NAME_KEY)
        coder.encodeObject(self._id, forKey: Default.UID_KEY)
        coder.encodeBool(self.committed, forKey:"committed")
        coder.encodeBool(self.distributed, forKey:"distributed")
        coder.encodeObject(self.creatorUID, forKey:"creatorUID")
        if let summary = self.summary {
            coder.encodeObject(summary, forKey:"summary")
        }
        coder.encodeBool(self._shouldBeCommitted, forKey: "_toBeCommitted")
        coder.encodeBool(self.ephemeral, forKey: "ephemeral")
    }


    public class func supportsSecureCoding() -> Bool {
        return true
    }


    // MARK: - NSCopying


    public func copyWithZone(zone: NSZone) -> AnyObject {
        let data: NSData=JSerializer.serialize(self)
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

    public func patchFrom(dictionaryRepresentation:[String:AnyObject]){
        let mapped=Map(mappingType: .FromJSON, JSONDictionary: dictionaryRepresentation)
        self.mapping(mapped)
    }
}


/**
 *  A simple Objc compliant object to keep track of changes in memory
 */
@objc(KeyedChanges) public class KeyedChanges:NSObject {
    var elapsed=Bartleby.elapsedTime
    var key:String
    var changes: String
    
    init(key:String,changes:String) {
        self.key=key
        self.changes=changes
    }
}

