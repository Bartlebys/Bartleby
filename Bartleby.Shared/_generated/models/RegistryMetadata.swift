//
//  RegistryMetadata.swift
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

// MARK: Bartleby's Core: Complete implementation in JRegistryMetadata. All its properties are not observable.
@objc(RegistryMetadata) public class RegistryMetadata : JObject{

    // Universal type support
    override public class func typeName() -> String {
        return "RegistryMetadata"
    }

	//The data space UID can be shared between multiple registries.
	dynamic public var spaceUID:String = "\(Default.NO_UID)"
	//The user currently associated to the local instance of the registry
	public var currentUser:User?
	//The identification method (By cookie or by Key - kvid)
	public enum IdentificationMethod:String{
		case Key = "Key"
		case Cookie = "Cookie"
	}
	public var identificationMethod:IdentificationMethod = .Key
	//The current kvid identification value (injected in HTTP headers)
	public var identificationValue:String?
	//The rootObject UID
	dynamic public var rootObjectUID:String = "\(Default.NO_UID)"
	//The url of the collaboration server
	dynamic public var collaborationServerURL:NSURL?
	//A collection of CollectionMetadatum
	public var collectionsMetadata:[CollectionMetadatum] = [CollectionMetadatum]()
	//is the user performing Online
	dynamic public var online:Bool = Bartleby.configuration.ONLINE_BY_DEFAULT
	//The State dictionary to insure registry persistency 
	public var stateDictionary:[String:AnyObject] = [String:AnyObject]()
	//The collection of serialized Security-Scoped Bookmarks (you should store NSData)
	public var URLBookmarkData:[String:AnyObject] = [String:AnyObject]()
	//Save the password or not?
	dynamic public var saveThePassword:Bool = Bartleby.configuration.SAVE_PASSWORD_DEFAULT_VALUE
	//The url of the assets folder
	public var assetsFolderURL:NSURL?
	//A collection of trigger Indexes (used to detect data holes)
	public var triggersIndexes:[Int] = [Int]()
	//The persistentcollection of triggers indexes owned by the current user (allows local distinctive analytics even on cloned documents)
	public var ownedTriggersIndexes:[Int] = [Int]()
	//The index of the last trigger that has been integrated
	public var lastIntegratedTriggerIndex:Int = -1
	//A collection Triggers that are temporarly stored before data integration
	public var receivedTriggers:[Trigger] = [Trigger]()
	//The serialized version of loaded trigger data that are pending integration
	public var _triggeredDataBuffer:NSData?


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
        self.lockAutoCommitObserver()
		self.spaceUID <- ( map["spaceUID"] )
		self.currentUser <- ( map["currentUser"] )
		self.identificationMethod <- ( map["identificationMethod"] )
		self.identificationValue <- ( map["identificationValue"] )
		self.rootObjectUID <- ( map["rootObjectUID"] )
		self.collaborationServerURL <- ( map["collaborationServerURL"], URLTransform() )
		self.collectionsMetadata <- ( map["collectionsMetadata"] )
		self.online <- ( map["online"] )
		self.stateDictionary <- ( map["stateDictionary"] )
		self.URLBookmarkData <- ( map["URLBookmarkData"] )
		self.saveThePassword <- ( map["saveThePassword"] )
		self.assetsFolderURL <- ( map["assetsFolderURL"], URLTransform() )
		self.triggersIndexes <- ( map["triggersIndexes"] )
		self.ownedTriggersIndexes <- ( map["ownedTriggersIndexes"] )
		self.lastIntegratedTriggerIndex <- ( map["lastIntegratedTriggerIndex"] )
		self.receivedTriggers <- ( map["receivedTriggers"] )
		self._triggeredDataBuffer <- ( map["_triggeredDataBuffer"], Base64DataTransform() )
        self.unlockAutoCommitObserver()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.lockAutoCommitObserver()
		self.spaceUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "spaceUID")! as NSString)
		self.currentUser=decoder.decodeObjectOfClass(User.self, forKey: "currentUser") 
		self.identificationMethod=RegistryMetadata.IdentificationMethod(rawValue:String(decoder.decodeObjectOfClass(NSString.self, forKey: "identificationMethod")! as NSString))! 
		self.identificationValue=String(decoder.decodeObjectOfClass(NSString.self, forKey:"identificationValue") as NSString?)
		self.rootObjectUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "rootObjectUID")! as NSString)
		self.collaborationServerURL=decoder.decodeObjectOfClass(NSURL.self, forKey:"collaborationServerURL") as NSURL?
		self.collectionsMetadata=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),CollectionMetadatum.classForCoder()]), forKey: "collectionsMetadata")! as! [CollectionMetadatum]
		self.online=decoder.decodeBoolForKey("online") 
		self.stateDictionary=decoder.decodeObjectOfClasses(NSSet(array: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()]), forKey: "stateDictionary")as! [String:AnyObject]
		self.URLBookmarkData=decoder.decodeObjectOfClasses(NSSet(array: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()]), forKey: "URLBookmarkData")as! [String:AnyObject]
		self.saveThePassword=decoder.decodeBoolForKey("saveThePassword") 
		self.assetsFolderURL=decoder.decodeObjectOfClass(NSURL.self, forKey:"assetsFolderURL") as NSURL?
		self.triggersIndexes=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),NSNumber.self]), forKey: "triggersIndexes")! as! [Int]
		self.ownedTriggersIndexes=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),NSNumber.self]), forKey: "ownedTriggersIndexes")! as! [Int]
		self.lastIntegratedTriggerIndex=decoder.decodeIntegerForKey("lastIntegratedTriggerIndex") 
		self.receivedTriggers=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),Trigger.classForCoder()]), forKey: "receivedTriggers")! as! [Trigger]
		self._triggeredDataBuffer=decoder.decodeObjectOfClass(NSData.self, forKey:"_triggeredDataBuffer") as NSData?
        self.unlockAutoCommitObserver()
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		coder.encodeObject(self.spaceUID,forKey:"spaceUID")
		if let currentUser = self.currentUser {
			coder.encodeObject(currentUser,forKey:"currentUser")
		}
		coder.encodeObject(self.identificationMethod.rawValue ,forKey:"identificationMethod")
		if let identificationValue = self.identificationValue {
			coder.encodeObject(identificationValue,forKey:"identificationValue")
		}
		coder.encodeObject(self.rootObjectUID,forKey:"rootObjectUID")
		if let collaborationServerURL = self.collaborationServerURL {
			coder.encodeObject(collaborationServerURL,forKey:"collaborationServerURL")
		}
		coder.encodeObject(self.collectionsMetadata,forKey:"collectionsMetadata")
		coder.encodeBool(self.online,forKey:"online")
		coder.encodeObject(self.stateDictionary,forKey:"stateDictionary")
		coder.encodeObject(self.URLBookmarkData,forKey:"URLBookmarkData")
		coder.encodeBool(self.saveThePassword,forKey:"saveThePassword")
		if let assetsFolderURL = self.assetsFolderURL {
			coder.encodeObject(assetsFolderURL,forKey:"assetsFolderURL")
		}
		coder.encodeObject(self.triggersIndexes,forKey:"triggersIndexes")
		coder.encodeObject(self.ownedTriggersIndexes,forKey:"ownedTriggersIndexes")
		coder.encodeInteger(self.lastIntegratedTriggerIndex,forKey:"lastIntegratedTriggerIndex")
		coder.encodeObject(self.receivedTriggers,forKey:"receivedTriggers")
		if let _triggeredDataBuffer = self._triggeredDataBuffer {
			coder.encodeObject(_triggeredDataBuffer,forKey:"_triggeredDataBuffer")
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
        return "registryMetadatas"
    }

    override public var d_collectionName:String{
        return RegistryMetadata.collectionName
    }


}

