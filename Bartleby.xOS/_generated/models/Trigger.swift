//
//  Trigger.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for b@bartlebys.org
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  Bartleby's | https://bartlebys.org  All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
import Alamofire
import ObjectMapper
#endif

// MARK: Bartleby's Core: a Trigger encapsulates a bunch of ExternalReferencees that's modelizes a state transformation
@objc(Trigger) public class Trigger : JObject{

    // Universal type support
    override public class func typeName() -> String {
        return "Trigger"
    }

	//The index is injected server side (each dataspace-registry) has it own counter)
	dynamic public var index:Int = -1
	//The dataSpace UID
	dynamic public var spaceUID:String?
	//The observation UID for a given document correspond  to the Registry.rootObjectUID
	dynamic public var observationUID:String?
	//The user.UID of the sender
	dynamic public var senderUID:String?
	//The UID of the instance of Bartleby client that has created the trigger.
	dynamic public var runUID:String?
	//The action that has initiated the trigger
	dynamic public var origin:String?
	//The targetted collection name
	dynamic public var targetCollectionName:String = ""
	//The server side creation date ( informative, use index for ranking)
	dynamic public var creationDate:Date?
	//The action name
	dynamic public var action:String = ""
	//A coma separated UIDS list
	dynamic public var UIDS:String = ""


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(_ map: Map) {
        super.mapping(map)
        self.disableSupervisionAndCommit()
		self.index <- ( map["index"] )
		self.spaceUID <- ( map["spaceUID"] )
		self.observationUID <- ( map["observationUID"] )
		self.senderUID <- ( map["senderUID"] )
		self.runUID <- ( map["runUID"] )
		self.origin <- ( map["origin"] )
		self.targetCollectionName <- ( map["targetCollectionName"] )
		self.creationDate <- ( map["creationDate"], ISO8601DateTransform() )
		self.action <- ( map["action"] )
		self.UIDS <- ( map["UIDS"] )
        self.enableSuperVisionAndCommit()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.disableSupervisionAndCommit()
		self.index=decoder.decodeInteger(forKey:"index") 
		self.spaceUID=String(describing: decoder.decodeObject(of: NSString.self, forKey:"spaceUID") as NSString?)
		self.observationUID=String(describing: decoder.decodeObject(of: NSString.self, forKey:"observationUID") as NSString?)
		self.senderUID=String(describing: decoder.decodeObject(of: NSString.self, forKey:"senderUID") as NSString?)
		self.runUID=String(describing: decoder.decodeObject(of: NSString.self, forKey:"runUID") as NSString?)
		self.origin=String(describing: decoder.decodeObject(of: NSString.self, forKey:"origin") as NSString?)
		self.targetCollectionName=String(describing: decoder.decodeObject(of: NSString.self, forKey: "targetCollectionName")! as NSString)
		self.creationDate=decoder.decodeObject(of: NSDate.self , forKey:"creationDate") as Date?
		self.action=String(describing: decoder.decodeObject(of: NSString.self, forKey: "action")! as NSString)
		self.UIDS=String(describing: decoder.decodeObject(of: NSString.self, forKey: "UIDS")! as NSString)
        self.disableSupervisionAndCommit()
    }

    override public func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self.index,forKey:"index")
		if let spaceUID = self.spaceUID {
			coder.encode(spaceUID,forKey:"spaceUID")
		}
		if let observationUID = self.observationUID {
			coder.encode(observationUID,forKey:"observationUID")
		}
		if let senderUID = self.senderUID {
			coder.encode(senderUID,forKey:"senderUID")
		}
		if let runUID = self.runUID {
			coder.encode(runUID,forKey:"runUID")
		}
		if let origin = self.origin {
			coder.encode(origin,forKey:"origin")
		}
		coder.encode(self.targetCollectionName,forKey:"targetCollectionName")
		if let creationDate = self.creationDate {
			coder.encode(creationDate,forKey:"creationDate")
		}
		coder.encode(self.action,forKey:"action")
		coder.encode(self.UIDS,forKey:"UIDS")
    }

    override public class var supportsSecureCoding:Bool{
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

