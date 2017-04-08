//
//  DocumentMetadata.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for [Benoit Pereira da Silva] (https://pereira-da-silva.com/contact)
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  [Bartleby's org] (https://bartlebys.org)   All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
	import Alamofire
	import ObjectMapper
#endif

// MARK: Bartleby's Core: Complete implementation in DocumentMetadata.
@objc(DocumentMetadata) open class DocumentMetadata : ValueObject {


	//The data space UID can be shared between multiple Docuemnt.
	dynamic open var spaceUID:String = "\(Bartleby.createUID())"

	//Defines the document UID.
	dynamic open var persistentUID:String = "\(Bartleby.createUID())"

	//The user UID currently associated to the local instance of the document
	dynamic open var currentUserUID:String = "\(Default.NO_UID)"

	//The current user email (to be displayed during identity control)
	dynamic open var currentUserEmail:String = "\(Default.VOID_STRING)"

	//The current user full phone number including the prefix (to be displayed during identity control)
	dynamic open var currentUserFullPhoneNumber:String = "\(Default.VOID_STRING)"

	//The sugar (not serialized but loaded from the Bowl)
	dynamic open var sugar:String = "\(Default.VOID_STRING)"

	//The locker UID to be used by the user to obtain the sugar from the locker
	dynamic open var lockerUID:String = "\(Default.NO_UID)"

	//Has the current user been controlled
	dynamic open var userHasBeenControlled:Bool = false

	//If set to false the identification chain will by pass the second authentication factor
	dynamic open var secondaryAuthFactorRequired:Bool = Bartleby.configuration.REDUCED_SECURITY_MODE

	//The identification method (By cookie or by Key - kvid)
	public enum IdentificationMethod:String{
		case key = "key"
		case cookie = "cookie"
	}
	open var identificationMethod:IdentificationMethod = .key

	//You can define a shared app group container identifier "group.myDomain.com.groupName")
	dynamic open var appGroup:String = ""

	//The current kvid identification value (injected in HTTP headers)
	dynamic open var identificationValue:String?

	//The url of the collaboration server
	dynamic open var collaborationServerURL:URL?

	//Should be Set to true only when the document has been correctly registred on collaboration server
	dynamic open var registred:Bool = false

	//If the changes are inspectable all the changes are stored in KeyChanges objects
	dynamic open var changesAreInspectables:Bool = Bartleby.configuration.CHANGES_ARE_INSPECTABLES_BY_DEFAULT

	//If set to true the boxes will be deleted when closing the document (Better security) 
	dynamic open var cleanupBoxesWhenClosingDocument:Bool = true

	//A collection of CollectionMetadatum
	dynamic open var collectionsMetadata:[CollectionMetadatum] = [CollectionMetadatum]()

	//The State dictionary to insure document persistency 
	dynamic open var stateDictionary:[String:Any] = [String:AnyObject]()

	//A collection of KeyedData
	dynamic open var URLBookmarkData:[KeyedData] = [KeyedData]()

	//The preferred filename for this document
	dynamic open var preferredFileName:String?

	//used for Core Debug , stores all the indexes by order of reception.
	dynamic open var triggersIndexesDebugHistory:[Int] = [Int]()

	//The persistentcollection of triggers indexes owned by the current user (allows local distinctive analytics even on cloned documents)
	dynamic open var ownedTriggersIndexes:[Int] = [Int]()

	//The index of the last trigger that has been integrated
	open var lastIntegratedTriggerIndex:Int = -1

	//A collection Triggers that are temporarly stored before data integration
	dynamic open var receivedTriggers:[Trigger] = [Trigger]()

	//A collection of PushOperations in Quarantine (check DataSynchronization.md "Faults" section for details) 
	dynamic open var operationsQuarantine:[PushOperation] = [PushOperation]()

	//Do we have operations in progress in the current bunch ?
	dynamic open var bunchInProgress:Bool = false

	//The highest number that we may have counted
	open var totalNumberOfOperations:Int = 0

	//The consolidated progression state of all pending operations
	dynamic open var pendingOperationsProgressionState:Progression?

	//When monitoring reachability we need to know if we should be connected to Collaborative server
	dynamic open var shouldBeOnline:Bool = Bartleby.configuration.ONLINE_BY_DEFAULT

	//is the user performing Online
	dynamic open var online:Bool = Bartleby.configuration.ONLINE_BY_DEFAULT

	//Is the document transitionning offToOn: offline > online, onToOff: online > offine
	public enum Transition:String{
		case none = "none"
		case offToOn = "offToOn"
		case onToOff = "onToOff"
	}
	open var transition:Transition = .none

	//If set to true committed object will be pushed as soon as possible.
	dynamic open var pushOnChanges:Bool = Bartleby.configuration.ONLINE_BY_DEFAULT

	//Save the password or not?
	dynamic open var saveThePassword:Bool = Bartleby.configuration.SAVE_PASSWORD_BY_DEFAULT

	//The sum of all the metrics
	dynamic open var cumulatedUpMetricsDuration:Double = 0

	//Total number of metrics since the document creation
	dynamic open var totalNumberOfUpMetrics:Int = 0

	//The qos Indice
	dynamic open var qosIndice:Double = 0


    // MARK: - Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }

    override open func mapping(map: Map) {
        super.mapping(map: map)
        self.quietChanges {
			self.spaceUID <- ( map["spaceUID"] )
			self.persistentUID <- ( map["persistentUID"] )
			self.currentUserUID <- ( map["currentUserUID"] )
			self.currentUserEmail <- ( map["currentUserEmail"] )
			self.currentUserFullPhoneNumber <- ( map["currentUserFullPhoneNumber"] )
			self.lockerUID <- ( map["lockerUID"] )
			self.secondaryAuthFactorRequired <- ( map["secondaryAuthFactorRequired"] )
			self.identificationMethod <- ( map["identificationMethod"] )
			self.appGroup <- ( map["appGroup"] )
			self.identificationValue <- ( map["identificationValue"] )
			self.collaborationServerURL <- ( map["collaborationServerURL"], URLTransform(shouldEncodeURLString:false) )
			self.registred <- ( map["registred"] )
			self.collectionsMetadata <- ( map["collectionsMetadata"] )
			self.stateDictionary <- ( map["stateDictionary"] )
			self.URLBookmarkData <- ( map["URLBookmarkData"] )
			self.preferredFileName <- ( map["preferredFileName"] )
			self.triggersIndexesDebugHistory <- ( map["triggersIndexesDebugHistory"] )
			self.ownedTriggersIndexes <- ( map["ownedTriggersIndexes"] )
			self.lastIntegratedTriggerIndex <- ( map["lastIntegratedTriggerIndex"] )
			self.receivedTriggers <- ( map["receivedTriggers"] )
			self.operationsQuarantine <- ( map["operationsQuarantine"] )
			self.shouldBeOnline <- ( map["shouldBeOnline"] )
			self.online <- ( map["online"] )
			self.pushOnChanges <- ( map["pushOnChanges"] )
			self.saveThePassword <- ( map["saveThePassword"] )
			self.cumulatedUpMetricsDuration <- ( map["cumulatedUpMetricsDuration"] )
			self.totalNumberOfUpMetrics <- ( map["totalNumberOfUpMetrics"] )
			self.qosIndice <- ( map["qosIndice"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.quietChanges {
			self.spaceUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "spaceUID")! as NSString)
			self.persistentUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "persistentUID")! as NSString)
			self.currentUserUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "currentUserUID")! as NSString)
			self.currentUserEmail=String(describing: decoder.decodeObject(of: NSString.self, forKey: "currentUserEmail")! as NSString)
			self.currentUserFullPhoneNumber=String(describing: decoder.decodeObject(of: NSString.self, forKey: "currentUserFullPhoneNumber")! as NSString)
			self.lockerUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "lockerUID")! as NSString)
			self.secondaryAuthFactorRequired=decoder.decodeBool(forKey:"secondaryAuthFactorRequired") 
			self.identificationMethod=DocumentMetadata.IdentificationMethod(rawValue:String(describing: decoder.decodeObject(of: NSString.self, forKey: "identificationMethod")! as NSString))! 
			self.appGroup=String(describing: decoder.decodeObject(of: NSString.self, forKey: "appGroup")! as NSString)
			self.identificationValue=String(describing: decoder.decodeObject(of: NSString.self, forKey:"identificationValue") as NSString?)
			self.collaborationServerURL=decoder.decodeObject(of: NSURL.self, forKey:"collaborationServerURL") as URL?
			self.registred=decoder.decodeBool(forKey:"registred") 
			self.collectionsMetadata=decoder.decodeObject(of: [NSArray.classForCoder(),CollectionMetadatum.classForCoder()], forKey: "collectionsMetadata")! as! [CollectionMetadatum]
			self.stateDictionary=decoder.decodeObject(of: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()], forKey: "stateDictionary")as! [String:Any]
			self.URLBookmarkData=decoder.decodeObject(of: [NSArray.classForCoder(),KeyedData.classForCoder()], forKey: "URLBookmarkData")! as! [KeyedData]
			self.preferredFileName=String(describing: decoder.decodeObject(of: NSString.self, forKey:"preferredFileName") as NSString?)
			self.triggersIndexesDebugHistory=decoder.decodeObject(of: [NSArray.classForCoder(),NSNumber.self], forKey: "triggersIndexesDebugHistory")! as! [Int]
			self.ownedTriggersIndexes=decoder.decodeObject(of: [NSArray.classForCoder(),NSNumber.self], forKey: "ownedTriggersIndexes")! as! [Int]
			self.lastIntegratedTriggerIndex=decoder.decodeInteger(forKey:"lastIntegratedTriggerIndex") 
			self.receivedTriggers=decoder.decodeObject(of: [NSArray.classForCoder(),Trigger.classForCoder()], forKey: "receivedTriggers")! as! [Trigger]
			self.operationsQuarantine=decoder.decodeObject(of: [NSArray.classForCoder(),PushOperation.classForCoder()], forKey: "operationsQuarantine")! as! [PushOperation]
			self.shouldBeOnline=decoder.decodeBool(forKey:"shouldBeOnline") 
			self.online=decoder.decodeBool(forKey:"online") 
			self.pushOnChanges=decoder.decodeBool(forKey:"pushOnChanges") 
			self.saveThePassword=decoder.decodeBool(forKey:"saveThePassword") 
			self.cumulatedUpMetricsDuration=decoder.decodeDouble(forKey:"cumulatedUpMetricsDuration") 
			self.totalNumberOfUpMetrics=decoder.decodeInteger(forKey:"totalNumberOfUpMetrics") 
			self.qosIndice=decoder.decodeDouble(forKey:"qosIndice") 
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self.spaceUID,forKey:"spaceUID")
		coder.encode(self.persistentUID,forKey:"persistentUID")
		coder.encode(self.currentUserUID,forKey:"currentUserUID")
		coder.encode(self.currentUserEmail,forKey:"currentUserEmail")
		coder.encode(self.currentUserFullPhoneNumber,forKey:"currentUserFullPhoneNumber")
		coder.encode(self.lockerUID,forKey:"lockerUID")
		coder.encode(self.secondaryAuthFactorRequired,forKey:"secondaryAuthFactorRequired")
		coder.encode(self.identificationMethod.rawValue ,forKey:"identificationMethod")
		coder.encode(self.appGroup,forKey:"appGroup")
		if let identificationValue = self.identificationValue {
			coder.encode(identificationValue,forKey:"identificationValue")
		}
		if let collaborationServerURL = self.collaborationServerURL {
			coder.encode(collaborationServerURL,forKey:"collaborationServerURL")
		}
		coder.encode(self.registred,forKey:"registred")
		coder.encode(self.collectionsMetadata,forKey:"collectionsMetadata")
		coder.encode(self.stateDictionary,forKey:"stateDictionary")
		coder.encode(self.URLBookmarkData,forKey:"URLBookmarkData")
		if let preferredFileName = self.preferredFileName {
			coder.encode(preferredFileName,forKey:"preferredFileName")
		}
		coder.encode(self.triggersIndexesDebugHistory,forKey:"triggersIndexesDebugHistory")
		coder.encode(self.ownedTriggersIndexes,forKey:"ownedTriggersIndexes")
		coder.encode(self.lastIntegratedTriggerIndex,forKey:"lastIntegratedTriggerIndex")
		coder.encode(self.receivedTriggers,forKey:"receivedTriggers")
		coder.encode(self.operationsQuarantine,forKey:"operationsQuarantine")
		coder.encode(self.shouldBeOnline,forKey:"shouldBeOnline")
		coder.encode(self.online,forKey:"online")
		coder.encode(self.pushOnChanges,forKey:"pushOnChanges")
		coder.encode(self.saveThePassword,forKey:"saveThePassword")
		coder.encode(self.cumulatedUpMetricsDuration,forKey:"cumulatedUpMetricsDuration")
		coder.encode(self.totalNumberOfUpMetrics,forKey:"totalNumberOfUpMetrics")
		coder.encode(self.qosIndice,forKey:"qosIndice")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

     required public init() {
        super.init()
    }
}