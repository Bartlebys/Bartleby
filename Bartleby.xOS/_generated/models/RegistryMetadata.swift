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

// MARK: Bartleby's Core: Complete implementation in JRegistryMetadata. All its properties are not supervisable.
@objc(RegistryMetadata) open class RegistryMetadata : JObject{

    // Universal type support
    override open class func typeName() -> String {
        return "RegistryMetadata"
    }

	//The data space UID can be shared between multiple registries.
	dynamic open var spaceUID:String = "\(Default.NO_UID)"
	//The user currently associated to the local instance of the registry
	dynamic open var currentUser:User?
	//The identification method (By cookie or by Key - kvid)
	public enum IdentificationMethod:String{
		case key = "key"
		case cookie = "cookie"
	}
	open var identificationMethod:IdentificationMethod = .key
	//The current kvid identification value (injected in HTTP headers)
	dynamic open var identificationValue:String?
	//The rootObject UID
	dynamic open var rootObjectUID:String = "\(Default.NO_UID)"
	//The url of the collaboration server
	dynamic open var collaborationServerURL:URL?
	//A collection of CollectionMetadatum
	dynamic open var collectionsMetadata:[CollectionMetadatum] = [CollectionMetadatum]()
	//The State dictionary to insure registry persistency 
	dynamic open var stateDictionary:[String:Any] = [String:AnyObject]()
	//The collection of serialized Security-Scoped Bookmarks (you should store Data)
	dynamic open var URLBookmarkData:[String:Any] = [String:AnyObject]()
	//The preferred filename for this registry/document
	dynamic open var preferredFileName:String?
	//A collection of trigger Indexes (used to detect data holes)
	dynamic open var triggersIndexes:[Int] = [Int]()
	//The persistentcollection of triggers indexes owned by the current user (allows local distinctive analytics even on cloned documents)
	dynamic open var ownedTriggersIndexes:[Int] = [Int]()
	//The index of the last trigger that has been integrated
	open var lastIntegratedTriggerIndex:Int = -1
	//A collection Triggers that are temporarly stored before data integration
	dynamic open var receivedTriggers:[Trigger] = [Trigger]()
	//The serialized version of loaded trigger data that are pending integration
	open var triggeredDataBuffer:Data?
	//Do we have operations in progress in the current bunch ?
	dynamic open var bunchInProgress:Bool = false
	//The highest number that we may have counted
	open var totalNumberOfOperations:Int = 0
	//The consolidated progression state of all pending operations
	dynamic open var pendingOperationsProgressionState:Progression?
	//is the user performing Online
	dynamic open var online:Bool = Bartleby.configuration.ONLINE_BY_DEFAULT  {	 
	    didSet { 
	       if online != oldValue {
	            self.provisionChanges(forKey: "online",oldValue: oldValue,newValue: online)  
	       } 
	    }
	}

	//If set to true any object creation, update, or deletion will be pushed to the server immediately
	dynamic open var pushOnChanges:Bool = true  {	 
	    didSet { 
	       if pushOnChanges != oldValue {
	            self.provisionChanges(forKey: "pushOnChanges",oldValue: oldValue,newValue: pushOnChanges)  
	       } 
	    }
	}

	//Save the password or not?
	dynamic open var saveThePassword:Bool = Bartleby.configuration.SAVE_PASSWORD_DEFAULT_VALUE  {	 
	    didSet { 
	       if saveThePassword != oldValue {
	            self.provisionChanges(forKey: "saveThePassword",oldValue: oldValue,newValue: saveThePassword)  
	       } 
	    }
	}



    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override open func mapping(_ map: Map) {
        super.mapping(map)
        self.silentGroupedChanges {
			self.spaceUID <- ( map["spaceUID"] )
			self.currentUser <- ( map["currentUser"] )
			self.identificationMethod <- ( map["identificationMethod"] )
			self.identificationValue <- ( map["identificationValue"] )
			self.rootObjectUID <- ( map["rootObjectUID"] )
			self.collaborationServerURL <- ( map["collaborationServerURL"], URLTransform() )
			self.collectionsMetadata <- ( map["collectionsMetadata"] )
			self.stateDictionary <- ( map["stateDictionary"] )
			self.URLBookmarkData <- ( map["URLBookmarkData"] )
			self.preferredFileName <- ( map["preferredFileName"] )
			self.triggersIndexes <- ( map["triggersIndexes"] )
			self.ownedTriggersIndexes <- ( map["ownedTriggersIndexes"] )
			self.lastIntegratedTriggerIndex <- ( map["lastIntegratedTriggerIndex"] )
			self.receivedTriggers <- ( map["receivedTriggers"] )
			self.triggeredDataBuffer <- ( map["triggeredDataBuffer"], Base64DataTransform() )
			self.online <- ( map["online"] )
			self.pushOnChanges <- ( map["pushOnChanges"] )
			self.saveThePassword <- ( map["saveThePassword"] )
        }
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self.spaceUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "spaceUID")! as NSString)
			self.currentUser=decoder.decodeObject(of:User.self, forKey: "currentUser") 
			self.identificationMethod=RegistryMetadata.IdentificationMethod(rawValue:String(describing: decoder.decodeObject(of: NSString.self, forKey: "identificationMethod")! as NSString))! 
			self.identificationValue=String(describing: decoder.decodeObject(of: NSString.self, forKey:"identificationValue") as NSString?)
			self.rootObjectUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "rootObjectUID")! as NSString)
			self.collaborationServerURL=decoder.decodeObject(of: NSURL.self, forKey:"collaborationServerURL") as URL?
			self.collectionsMetadata=decoder.decodeObject(of: [NSArray.classForCoder(),CollectionMetadatum.classForCoder()], forKey: "collectionsMetadata")! as! [CollectionMetadatum]
			self.stateDictionary=decoder.decodeObject(of: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()], forKey: "stateDictionary")as! [String:Any]
			self.URLBookmarkData=decoder.decodeObject(of: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()], forKey: "URLBookmarkData")as! [String:Any]
			self.preferredFileName=String(describing: decoder.decodeObject(of: NSString.self, forKey:"preferredFileName") as NSString?)
			self.triggersIndexes=decoder.decodeObject(of: [NSArray.classForCoder(),NSNumber.self], forKey: "triggersIndexes")! as! [Int]
			self.ownedTriggersIndexes=decoder.decodeObject(of: [NSArray.classForCoder(),NSNumber.self], forKey: "ownedTriggersIndexes")! as! [Int]
			self.lastIntegratedTriggerIndex=decoder.decodeInteger(forKey:"lastIntegratedTriggerIndex") 
			self.receivedTriggers=decoder.decodeObject(of: [NSArray.classForCoder(),Trigger.classForCoder()], forKey: "receivedTriggers")! as! [Trigger]
			self.triggeredDataBuffer=decoder.decodeObject(of: NSData.self, forKey:"triggeredDataBuffer") as Data?
			self.online=decoder.decodeBool(forKey:"online") 
			self.pushOnChanges=decoder.decodeBool(forKey:"pushOnChanges") 
			self.saveThePassword=decoder.decodeBool(forKey:"saveThePassword") 
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self.spaceUID,forKey:"spaceUID")
		if let currentUser = self.currentUser {
			coder.encode(currentUser,forKey:"currentUser")
		}
		coder.encode(self.identificationMethod.rawValue ,forKey:"identificationMethod")
		if let identificationValue = self.identificationValue {
			coder.encode(identificationValue,forKey:"identificationValue")
		}
		coder.encode(self.rootObjectUID,forKey:"rootObjectUID")
		if let collaborationServerURL = self.collaborationServerURL {
			coder.encode(collaborationServerURL,forKey:"collaborationServerURL")
		}
		coder.encode(self.collectionsMetadata,forKey:"collectionsMetadata")
		coder.encode(self.stateDictionary,forKey:"stateDictionary")
		coder.encode(self.URLBookmarkData,forKey:"URLBookmarkData")
		if let preferredFileName = self.preferredFileName {
			coder.encode(preferredFileName,forKey:"preferredFileName")
		}
		coder.encode(self.triggersIndexes,forKey:"triggersIndexes")
		coder.encode(self.ownedTriggersIndexes,forKey:"ownedTriggersIndexes")
		coder.encode(self.lastIntegratedTriggerIndex,forKey:"lastIntegratedTriggerIndex")
		coder.encode(self.receivedTriggers,forKey:"receivedTriggers")
		if let triggeredDataBuffer = self.triggeredDataBuffer {
			coder.encode(triggeredDataBuffer,forKey:"triggeredDataBuffer")
		}
		coder.encode(self.online,forKey:"online")
		coder.encode(self.pushOnChanges,forKey:"pushOnChanges")
		coder.encode(self.saveThePassword,forKey:"saveThePassword")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }


    required public init() {
        super.init()
    }

    // MARK: Identifiable

    override open class var collectionName:String{
        return "registryMetadatas"
    }

    override open var d_collectionName:String{
        return RegistryMetadata.collectionName
    }


}

