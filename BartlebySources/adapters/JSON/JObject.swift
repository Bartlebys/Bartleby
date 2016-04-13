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

func ==(lhs: JObject, rhs: JObject) -> Bool{
    return lhs.UID==rhs.UID
}

// Notice the @objc(Name)
// http://stackoverflow.com/a/24196632/341994

@objc(JObject) public class JObject : NSObject,NSCopying,Mappable,Persistent,Serializable,Identifiable,NSSecureCoding{
    
    
    // Key Mapping
    
    // The id is always  created locally
    // and used as primary index by MONGODB
    private var _id:String=Default.NO_UID
    
    private var _referenceName:String=Default.NO_NAME
    
    // The class name
    public var referenceName:String{
        get{
            if _referenceName == Default.NO_NAME{
                let classNameString:NSString=NSStringFromClass(self.dynamicType)
                _referenceName = classNameString.stringByReplacingOccurrencesOfString("NSKVONotifying_",withString:"")
            }
            return _referenceName
        }
        set{
            _referenceName=referenceName
        }
    }
    
    
    // MARK: -
    
    private func _createUIDifNecessary(){
        if _id==Default.NO_UID{
            _id=Bartleby.createUID()
            Registry.register(self) // register on creation
        }
    }
    
    override required public init() {
        super.init()
    }

    
    public required init?(_ map: Map) {
        super.init()
        mapping(map)
    }
    
    
    public func mapping(map: Map) {
        _id <- map[Default.UID_KEY]
        referenceName <- map[Default.REFERENCE_NAME_KEY]
        if map.mappingType == MappingType.FromJSON{
            Registry.register(self)//register on deserialization
        }
    }
    
    // MARK : Identifiable
    
    
    final public var UID:String{
        get{
            self._createUIDifNecessary()
            return _id
        }
    }
    
    
    // Needs to be overriden to determine in wich collection the instances will be 'stored
    class public var collectionName:String{
        return "JObjects"
    }
    
    public var d_collectionName:String{
        return JObject.collectionName
    }
    
    // MARK: CustomStringConvertible
    
    override public var description: String {
        get{
            if let j=Mapper().toJSONString(self,prettyPrint:true){
                return "\n\(j)"
            }else{
                return "Void JObject"
            }
        }
    }
    
    
    // MARK : Serializable
    
    
    
    public func serialize()->NSData {
        let dictionaryRepresentation = self.dictionaryRepresentation()
        do{
            if Default.HUMAN_FORMATTED_SERIALIZATON_FORMAT {
                return try NSJSONSerialization.dataWithJSONObject(dictionaryRepresentation, options:[NSJSONWritingOptions.PrettyPrinted])
            }else{
                return try NSJSONSerialization.dataWithJSONObject(dictionaryRepresentation, options:[])
            }
        }catch{
            return NSData()
        }
    }
    
    
    public func patchWithSerializedData(data: NSData) -> Serializable {
        do{
            if let JSONDictionary = try NSJSONSerialization.JSONObjectWithData(data,options:NSJSONReadingOptions.AllowFragments) as? [String:AnyObject] {
                let map=Map(mappingType: .FromJSON, JSONDictionary: JSONDictionary)
                self.mapping(map)
                return self
            }
        }catch{
            //Silent catch
            Bartleby.bprint("deserialize ERROR \(error)")
        }
        // If there is an issue we relay to the serializer
        
        return JSerializer.deserialize(data)
    }
    
    
    public func dictionaryRepresentation()->[String:AnyObject]{
        return Mapper().toJSON(self)
    }
    
    
    // MARK : Persistent
    
    
    
    public func toPersistentRepresentation()->(UID:String,collectionName:String,serializedUTF8String:String,A:Double,B:Double,C:Double,D:Double,E:Double,S:String){
        if let data = Mapper().toJSONString(self, prettyPrint: Default.HUMAN_FORMATTED_SERIALIZATON_FORMAT){
            return (self.UID,self.d_collectionName,data,0,0,0,0,0,"")
        }else{
            let s="{\"Persitency Error - serialization failed\"}"
            return (self.UID,self.d_collectionName,s,0,0,0,0,0,"")
        }
    }
    
    
    static public func fromSerializedUTF8String(serializedUTF8String:String)->Serializable{
        // In our case the serializedUTF8String encapuslate all the required information
        if let d = serializedUTF8String.dataUsingEncoding(NSUTF8StringEncoding){
            return JSerializer.deserialize(d)
        }else{
            let error=ObjectError()
            error.message="Error on deserialization of \(serializedUTF8String)"
            return error
        }
        
    }
    
    
    // MARK: NSecureCoding
    
    
    public func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeObject(_id, forKey: Default.UID_KEY)
        aCoder.encodeObject(referenceName, forKey: Default.REFERENCE_NAME_KEY)
    }

    public required init?(coder decoder: NSCoder){
        super.init()
        _id=String(decoder.decodeObjectOfClass( NSString.self, forKey:Default.UID_KEY)! as NSString? )
        referenceName=String(decoder.decodeObjectOfClass( NSString.self, forKey:Default.REFERENCE_NAME_KEY)! as NSString?)
        Registry.register(self)//registration on deserialization
    }
    
    public class func supportsSecureCoding() -> Bool{
        return true
    }
    
    
    // MARK: NSCopying
    
    /*
     
     - parameter zone:
     
     - returns:
     */
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let data:NSData=JSerializer.serialize(self)
        return JSerializer.deserialize(data) as! AnyObject
    }
   
    
}


 