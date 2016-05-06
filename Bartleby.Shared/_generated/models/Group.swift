//
//  Group.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for benoit@pereira-da-silva.com
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
// WE TRY TO GENERATE ANY REPETITIVE CODE AND TO IMPROVE THE QUALITY ITERATIVELY
//
// Copyright (c) 2015  Chaosmos | https://chaosmos.fr  All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
import Alamofire
import ObjectMapper
#endif

// MARK: Model Group
@objc(Group) public class Group : JObject{


	public var creationDate:String?
	//The relative paths to its parent tag e.g : registryUID/collectionName/instanceUID
	public var parentReference:String?
	//The relative paths to a children tag e.g : registryUID/collectionName/instanceUID
	public var childrensReferences:[String]?
	public var color:String?
	public var icon:String?


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
        mapping(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
		self.creationDate <- map["creationDate"]
		self.parentReference <- map["parentReference"]
		self.childrensReferences <- map["childrensReferences"]
		self.color <- map["color"]
		self.icon <- map["icon"]
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
		self.creationDate=String(decoder.decodeObjectOfClass(NSString.self, forKey:"creationDate") as NSString?)
		self.parentReference=String(decoder.decodeObjectOfClass(NSString.self, forKey:"parentReference") as NSString?)
		self.childrensReferences=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),NSString.self]), forKey: "childrensReferences") as? [String]
		self.color=String(decoder.decodeObjectOfClass(NSString.self, forKey:"color") as NSString?)
		self.icon=String(decoder.decodeObjectOfClass(NSString.self, forKey:"icon") as NSString?)

    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		if let creationDate = self.creationDate {
			coder.encodeObject(creationDate,forKey:"creationDate")
		}
		if let parentReference = self.parentReference {
			coder.encodeObject(parentReference,forKey:"parentReference")
		}
		if let childrensReferences = self.childrensReferences {
			coder.encodeObject(childrensReferences,forKey:"childrensReferences")
		}
		if let color = self.color {
			coder.encodeObject(color,forKey:"color")
		}
		if let icon = self.icon {
			coder.encodeObject(icon,forKey:"icon")
		}
    }


    override public class func supportsSecureCoding() -> Bool{
        return true
    }


    required public init() {
        super.init()
    }

    // MARK: Identifiable

    override public class var collectionName:String{
        return "groups"
    }

    override public var d_collectionName:String{
        return Group.collectionName
    }


    // MARK: Persistent

    override public func toPersistentRepresentation()->(UID:String,collectionName:String,serializedUTF8String:String,A:Double,B:Double,C:Double,D:Double,E:Double,S:String){
        var r=super.toPersistentRepresentation()
        r.A=NSDate().timeIntervalSince1970
        return r
    }

}
