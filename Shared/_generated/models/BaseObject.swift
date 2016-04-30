//
//  BaseObject.swift
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

// MARK: Model BaseObject
@objc(BaseObject) public class BaseObject : JObject{


	//Collectible protocol: committed 
	public var committed:Bool = false
	//Collectible protocol: distributed 
	public var distributed:Bool = false
	//Collectible protocol: The Creator UID
	public var creatorUID:String = "\(Default.NO_UID)"
	//Collectible protocol: The Group UID
	public var groupUID:String = "\(Default.NO_UID)"
	//The class name of the reference
	public var summary:String?


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
        mapping(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
		self.committed <- map["committed"]
		self.distributed <- map["distributed"]
		self.creatorUID <- map["creatorUID"]
		self.groupUID <- map["groupUID"]
		self.summary <- map["summary"]
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
		self.committed=decoder.decodeBoolForKey("committed") 
		self.distributed=decoder.decodeBoolForKey("distributed") 
		self.creatorUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "creatorUID")! as NSString)
		self.groupUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "groupUID")! as NSString)
		self.summary=String(decoder.decodeObjectOfClass(NSString.self, forKey:"summary") as NSString?)

    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		coder.encodeBool(self.committed,forKey:"committed")
		coder.encodeBool(self.distributed,forKey:"distributed")
		coder.encodeObject(self.creatorUID,forKey:"creatorUID")
		coder.encodeObject(self.groupUID,forKey:"groupUID")
		if let summary = self.summary {
			coder.encodeObject(summary,forKey:"summary")
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
        return "baseObjects"
    }

    override public var d_collectionName:String{
        return BaseObject.collectionName
    }


    // MARK: Persistent

    override public func toPersistentRepresentation()->(UID:String,collectionName:String,serializedUTF8String:String,A:Double,B:Double,C:Double,D:Double,E:Double,S:String){
        var r=super.toPersistentRepresentation()
        r.A=NSDate().timeIntervalSince1970
        return r
    }

}

