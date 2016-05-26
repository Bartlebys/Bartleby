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

func ==(lhs: JObject, rhs: JObject) -> Bool {
    return lhs.UID==rhs.UID
}



// JOBjects are polyglot They can be serialized in multiple dialects ... (Mappable, NSecureCoding, ...)

// Currently the name Mangling @objc(JObject) is necessary to be able to pass a JObject in an XPC call.
// During XPC calls the Module varies (BartlebyKit in the framework, BSyncXPC, ...)
// NSecureCoding does not implement Universal Strategy the module is prepended to the name.
// By putting @objc(name) we fix the serialization name.
// This is due to the impossibility to link a FrameWork to an XPC services.
@objc(JObject) public class JObject: NSObject, Mappable, Collectible, Supervisable, NSCopying, NSSecureCoding {


    // MARK: - Initializable

    override required public init() {
        super.init()
    }

    // MARK: - Collectible = Identifiable + Serializable + type and status management

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
    // Supervisable
    public var toBeCommitted: Bool {
        get {
            return self._shouldBeCommitted
        }
    }

    /**
     If the auto commit observer flag is set to true then _shouldBeCommitted is turned to true.
     */
    public func provisionChanges() {
        if !self._lockAutoCommitObserver {
            self._shouldBeCommitted=true
        }
    }

    //
    public func lockAutoCommitObserver() {
        self._lockAutoCommitObserver=true
    }

    public func unlockAutoCommitObserver() {
        self._lockAutoCommitObserver=false
    }

    private var _lockAutoCommitObserver: Bool = false


    //Collectible protocol: committed
    public var committed: Bool = false {
        willSet {
            // The changes have been committed
           self._shouldBeCommitted=false
        }
        didSet {
        }
    }

    //Collectible protocol: distributed
    public var distributed: Bool = false

    //Collectible protocol: The Creator UID
    public var creatorUID: String = "\(Default.NO_UID)" {
        willSet {
            if creatorUID != newValue {
                self.provisionChanges()
            }
        }
    }

    // The object summary can be used for example by externalReferences to describe the JObject instance.
    // If you want to disclose more information you can adopt the Descriptible protocol.
    public var summary: String? {
        willSet {
            if summary != newValue {
                self.provisionChanges()
            }
        }
    }

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

    // MARK: -Identifiable

    // This  id is always  created locally and used as primary index by MONGODB
    private var _id: String=Default.NO_UID {
        didSet {
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


    // Needs to be overriden to determine in wich collection the instances will be 'stored
    class public var collectionName: String {
        return "JObjects"
    }

    public var d_collectionName: String {
        return JObject.collectionName
    }


    // MARK: - CustomStringConvertible


    override public var description: String {
        get {
            if self is Descriptible {
                return (self as! Descriptible).toString()
            }
            if let j=Mapper().toJSONString(self, prettyPrint:true) {
                return "\n\(j)"
            } else {
                return "Void JObject"
            }
        }
    }

    // MARK: - Mappable

    public required init?(_ map: Map) {
        super.init()
    }


    public func mapping(map: Map) {
        self.lockAutoCommitObserver()
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
        self.unlockAutoCommitObserver()
    }


    // MARK: - NSecureCoding


    public required init?(coder decoder: NSCoder) {
        super.init()
        self._id=String(decoder.decodeObjectOfClass(NSString.self, forKey: Default.UID_KEY)! as NSString)
        self._typeName=self.dynamicType.typeName()
        self._typeName=String(decoder.decodeObjectOfClass(NSString.self, forKey: Default.TYPE_NAME_KEY)! as NSString)
        self.committed=decoder.decodeBoolForKey("committed")
        self.distributed=decoder.decodeBoolForKey("distributed")
        self.creatorUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "creatorUID")! as NSString)
        self.summary=String(decoder.decodeObjectOfClass(NSString.self, forKey:"summary") as NSString?)
        self._shouldBeCommitted=decoder.decodeBoolForKey("_toBeCommitted")
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
}
