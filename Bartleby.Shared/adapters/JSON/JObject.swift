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
public class JObject: NSObject, NSCopying, Mappable, Collectible, Persistent, NSSecureCoding {


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

    //Collectible protocol: committed
    public var committed: Bool = false
    //Collectible protocol: distributed
    public var distributed: Bool = false
    //Collectible protocol: The Creator UID
    public var creatorUID: String = "\(Default.NO_UID)"
    //The object summary can be used for example by aliases to describe the JObject instance.
    public var summary: String?


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


    public func updateData(data: NSData) -> Serializable {
        do {
            if let JSONDictionary = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments) as? [String:AnyObject] {
                let map=Map(mappingType: .FromJSON, JSONDictionary: JSONDictionary)
                self.mapping(map)
                return self
            }
        } catch {
            //Silent catch
            bprint("deserialize ERROR \(error)")
        }
        // If there is an issue we relay to the serializer

        return JSerializer.deserialize(data)
    }

    // MARK: -Identifiable

    // This  id is always  created locally and used as primary index by MONGODB

    // @bpds to be revised
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
            return _id
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
        mapping(map)
    }


    public func mapping(map: Map) {
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
    }


    // MARK: - NSecureCoding


    public required init?(coder decoder: NSCoder) {
        super.init()
        self._id=String(decoder.decodeObjectOfClass(NSString.self, forKey: Default.UID_KEY)! as NSString)
        self._typeName=String(decoder.decodeObjectOfClass(NSString.self, forKey: Default.TYPE_NAME_KEY)! as NSString)
        self.committed=decoder.decodeBoolForKey("committed")
        self.distributed=decoder.decodeBoolForKey("distributed")
        self.creatorUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "creatorUID")! as NSString)
        self.summary=String(decoder.decodeObjectOfClass(NSString.self, forKey:"summary") as NSString?)
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
     }



    public class func supportsSecureCoding() -> Bool {
        return true
    }


    // MARK: - NSCopying


    public func copyWithZone(zone: NSZone) -> AnyObject {
        let data: NSData=JSerializer.serialize(self)
        return JSerializer.deserialize(data) as! AnyObject
    }


    // MARK: - Persistent

    public func toPersistentRepresentation()->(UID: String, collectionName: String, serializedUTF8String: String, A: Double, B: Double, C: Double, D: Double, E: Double, S: String) {
        if let data = Mapper().toJSONString(self, prettyPrint: Bartleby.configuration.HUMAN_FORMATTED_SERIALIZATON_FORMAT) {
            return (self.UID, self.d_collectionName, data, 0, 0, 0, 0, 0, "")
        } else {
            let s="{\"Persitency Error - serialization failed\"}"
            return (self.UID, self.d_collectionName, s, 0, 0, 0, 0, 0, "")
        }
    }


    static public func fromSerializedUTF8String(serializedUTF8String: String) -> Serializable {
        // In our case the serializedUTF8String encapuslate all the required information
        if let d = serializedUTF8String.dataUsingEncoding(Default.TEXT_ENCODING) {
            return JSerializer.deserialize(d)
        } else {
            let error=ObjectError()
            error.message="Error on deserialization of \(serializedUTF8String)"
            return error
        }

    }
}



// MARK: - DictionaryRepresentation

extension JObject:DictionaryRepresentation {

    public func dictionaryRepresentation()->[String:AnyObject] {
        self.defineUID()
        return Mapper().toJSON(self)
    }
}
