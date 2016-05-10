//
//  Trigger.swift
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

// MARK: Model Trigger
public class Trigger : JObject{

    // Universal type support
    override public class func typeName() -> String {
        return "Trigger"
    }

	//A message that can be injected for monitoring or external observation
	public var associatedMessage:String?
	//The index is injected server side.
	public var index:Int?
	//A UID characterizing the observable
	public var observableUID:String?


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
        mapping(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
		self.associatedMessage <- map["associatedMessage"]
		self.index <- map["index"]
		self.observableUID <- map["observableUID"]
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
		self.associatedMessage=String(decoder.decodeObjectOfClass(NSString.self, forKey:"associatedMessage") as NSString?)
		self.index=decoder.decodeIntegerForKey("index") 
		self.observableUID=String(decoder.decodeObjectOfClass(NSString.self, forKey:"observableUID") as NSString?)

    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		if let associatedMessage = self.associatedMessage {
			coder.encodeObject(associatedMessage,forKey:"associatedMessage")
		}
		if let index = self.index {
			coder.encodeInteger(index,forKey:"index")
		}
		if let observableUID = self.observableUID {
			coder.encodeObject(observableUID,forKey:"observableUID")
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
        return "triggers"
    }

    override public var d_collectionName:String{
        return Trigger.collectionName
    }


}

