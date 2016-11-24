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
@objc(DocumentMetadata) open class DocumentMetadata : BartlebyObject{

    // Universal type support
    override open class func typeName() -> String {
        return "DocumentMetadata"
    }

	//The data space UID can be shared between multiple registries.
	dynamic open var spaceUID:String = "\(Default.NO_UID)"

	//The user currently associated to the local instance of the document
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

	//If the changes are inspectable all the changes are stored in KeyChanges objects
	dynamic open var changesAreInspectables:Bool = Bartleby.configuration.CHANGES_ARE_INSPECTABLES_BY_DEFAULT

	//A collection of CollectionMetadatum
	dynamic open var collectionsMetadata:[CollectionMetadatum] = [CollectionMetadatum]()

	//The State dictionary to insure document persistency 
	dynamic open var stateDictionary:[String:Any] = [String:AnyObject]()

	//The collection of serialized Security-Scoped Bookmarks (you should store Data)
	dynamic open var URLBookmarkData:[String:Any] = [String:AnyObject]()

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
	dynamic open var shouldBeOnline:Bool = Bartleby.configuration.ONLINE_BY_DEFAULT  {
	    didSet { 
	       if !self.wantsQuietChanges && shouldBeOnline != oldValue {
	            self.provisionChanges(forKey: "shouldBeOnline",oldValue: oldValue,newValue: shouldBeOnline)  
	       } 
	    }
	}

	//is the user performing Online
	dynamic open var online:Bool = Bartleby.configuration.ONLINE_BY_DEFAULT  {
	    didSet { 
	       if !self.wantsQuietChanges && online != oldValue {
	            self.provisionChanges(forKey: "online",oldValue: oldValue,newValue: online)  
	       } 
	    }
	}

	//Is the document transitionning offToOn: offline > online, onToOff: online > offine
	public enum Transition:String{
		case none = "none"
		case offToOn = "offToOn"
		case onToOff = "onToOff"
	}
	open var transition:Transition = .none  {
	    didSet { 
	       if !self.wantsQuietChanges && transition != oldValue {
	            self.provisionChanges(forKey: "transition",oldValue: oldValue.rawValue,newValue: transition.rawValue)  
	       } 
	    }
	}

	//If set to true committed object will be pushed as soon as possible.
	dynamic open var pushOnChanges:Bool = Bartleby.configuration.ONLINE_BY_DEFAULT  {
	    didSet { 
	       if !self.wantsQuietChanges && pushOnChanges != oldValue {
	            self.provisionChanges(forKey: "pushOnChanges",oldValue: oldValue,newValue: pushOnChanges)  
	       } 
	    }
	}

	//Save the password or not?
	dynamic open var saveThePassword:Bool = Bartleby.configuration.SAVE_PASSWORD_DEFAULT_VALUE  {
	    didSet { 
	       if !self.wantsQuietChanges && saveThePassword != oldValue {
	            self.provisionChanges(forKey: "saveThePassword",oldValue: oldValue,newValue: saveThePassword)  
	       } 
	    }
	}

	//The sum of all the metrics
	dynamic open var cumulatedUpMetricsDuration:Double = 0

	//Total number of metrics since the document creation
	dynamic open var totalNumberOfUpMetrics:Int = 0

	//The qos Indice
	dynamic open var qosIndice:Double = 0

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["spaceUID","currentUser","identificationMethod","identificationValue","rootObjectUID","collaborationServerURL","changesAreInspectables","collectionsMetadata","stateDictionary","URLBookmarkData","preferredFileName","triggersIndexesDebugHistory","ownedTriggersIndexes","lastIntegratedTriggerIndex","receivedTriggers","operationsQuarantine","bunchInProgress","totalNumberOfOperations","pendingOperationsProgressionState","shouldBeOnline","online","transition","pushOnChanges","saveThePassword","cumulatedUpMetricsDuration","totalNumberOfUpMetrics","qosIndice"])
        return exposed
    }


    /// Set the value of the given key
    ///
    /// - parameter value: the value
    /// - parameter key:   the key
    ///
    /// - throws: throws an Exception when the key is not exposed
    override open func setExposedValue(_ value:Any?, forKey key: String) throws {
        switch key {
            case "spaceUID":
                if let casted=value as? String{
                    self.spaceUID=casted
                }
            case "currentUser":
                if let casted=value as? User{
                    self.currentUser=casted
                }
            case "identificationMethod":
                if let casted=value as? DocumentMetadata.IdentificationMethod{
                    self.identificationMethod=casted
                }
            case "identificationValue":
                if let casted=value as? String{
                    self.identificationValue=casted
                }
            case "rootObjectUID":
                if let casted=value as? String{
                    self.rootObjectUID=casted
                }
            case "collaborationServerURL":
                if let casted=value as? URL{
                    self.collaborationServerURL=casted
                }
            case "changesAreInspectables":
                if let casted=value as? Bool{
                    self.changesAreInspectables=casted
                }
            case "collectionsMetadata":
                if let casted=value as? [CollectionMetadatum]{
                    self.collectionsMetadata=casted
                }
            case "stateDictionary":
                if let casted=value as? [String:Any]{
                    self.stateDictionary=casted
                }
            case "URLBookmarkData":
                if let casted=value as? [String:Any]{
                    self.URLBookmarkData=casted
                }
            case "preferredFileName":
                if let casted=value as? String{
                    self.preferredFileName=casted
                }
            case "triggersIndexesDebugHistory":
                if let casted=value as? [Int]{
                    self.triggersIndexesDebugHistory=casted
                }
            case "ownedTriggersIndexes":
                if let casted=value as? [Int]{
                    self.ownedTriggersIndexes=casted
                }
            case "lastIntegratedTriggerIndex":
                if let casted=value as? Int{
                    self.lastIntegratedTriggerIndex=casted
                }
            case "receivedTriggers":
                if let casted=value as? [Trigger]{
                    self.receivedTriggers=casted
                }
            case "operationsQuarantine":
                if let casted=value as? [PushOperation]{
                    self.operationsQuarantine=casted
                }
            case "bunchInProgress":
                if let casted=value as? Bool{
                    self.bunchInProgress=casted
                }
            case "totalNumberOfOperations":
                if let casted=value as? Int{
                    self.totalNumberOfOperations=casted
                }
            case "pendingOperationsProgressionState":
                if let casted=value as? Progression{
                    self.pendingOperationsProgressionState=casted
                }
            case "shouldBeOnline":
                if let casted=value as? Bool{
                    self.shouldBeOnline=casted
                }
            case "online":
                if let casted=value as? Bool{
                    self.online=casted
                }
            case "transition":
                if let casted=value as? DocumentMetadata.Transition{
                    self.transition=casted
                }
            case "pushOnChanges":
                if let casted=value as? Bool{
                    self.pushOnChanges=casted
                }
            case "saveThePassword":
                if let casted=value as? Bool{
                    self.saveThePassword=casted
                }
            case "cumulatedUpMetricsDuration":
                if let casted=value as? Double{
                    self.cumulatedUpMetricsDuration=casted
                }
            case "totalNumberOfUpMetrics":
                if let casted=value as? Int{
                    self.totalNumberOfUpMetrics=casted
                }
            case "qosIndice":
                if let casted=value as? Double{
                    self.qosIndice=casted
                }
            default:
                return try super.setExposedValue(value, forKey: key)
        }
    }


    /// Returns the value of an exposed key.
    ///
    /// - parameter key: the key
    ///
    /// - throws: throws Exception when the key is not exposed
    ///
    /// - returns: returns the value
    override open func getExposedValueForKey(_ key:String) throws -> Any?{
        switch key {
            case "spaceUID":
               return self.spaceUID
            case "currentUser":
               return self.currentUser
            case "identificationMethod":
               return self.identificationMethod
            case "identificationValue":
               return self.identificationValue
            case "rootObjectUID":
               return self.rootObjectUID
            case "collaborationServerURL":
               return self.collaborationServerURL
            case "changesAreInspectables":
               return self.changesAreInspectables
            case "collectionsMetadata":
               return self.collectionsMetadata
            case "stateDictionary":
               return self.stateDictionary
            case "URLBookmarkData":
               return self.URLBookmarkData
            case "preferredFileName":
               return self.preferredFileName
            case "triggersIndexesDebugHistory":
               return self.triggersIndexesDebugHistory
            case "ownedTriggersIndexes":
               return self.ownedTriggersIndexes
            case "lastIntegratedTriggerIndex":
               return self.lastIntegratedTriggerIndex
            case "receivedTriggers":
               return self.receivedTriggers
            case "operationsQuarantine":
               return self.operationsQuarantine
            case "bunchInProgress":
               return self.bunchInProgress
            case "totalNumberOfOperations":
               return self.totalNumberOfOperations
            case "pendingOperationsProgressionState":
               return self.pendingOperationsProgressionState
            case "shouldBeOnline":
               return self.shouldBeOnline
            case "online":
               return self.online
            case "transition":
               return self.transition
            case "pushOnChanges":
               return self.pushOnChanges
            case "saveThePassword":
               return self.saveThePassword
            case "cumulatedUpMetricsDuration":
               return self.cumulatedUpMetricsDuration
            case "totalNumberOfUpMetrics":
               return self.totalNumberOfUpMetrics
            case "qosIndice":
               return self.qosIndice
            default:
                return try super.getExposedValueForKey(key)
        }
    }
    // MARK: - Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }

    override open func mapping(map: Map) {
        super.mapping(map: map)
        self.quietChanges {
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
			self.currentUser=decoder.decodeObject(of:User.self, forKey: "currentUser") 
			self.identificationMethod=DocumentMetadata.IdentificationMethod(rawValue:String(describing: decoder.decodeObject(of: NSString.self, forKey: "identificationMethod")! as NSString))! 
			self.identificationValue=String(describing: decoder.decodeObject(of: NSString.self, forKey:"identificationValue") as NSString?)
			self.rootObjectUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "rootObjectUID")! as NSString)
			self.collaborationServerURL=decoder.decodeObject(of: NSURL.self, forKey:"collaborationServerURL") as URL?
			self.collectionsMetadata=decoder.decodeObject(of: [NSArray.classForCoder(),CollectionMetadatum.classForCoder()], forKey: "collectionsMetadata")! as! [CollectionMetadatum]
			self.stateDictionary=decoder.decodeObject(of: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()], forKey: "stateDictionary")as! [String:Any]
			self.URLBookmarkData=decoder.decodeObject(of: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()], forKey: "URLBookmarkData")as! [String:Any]
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

    override open class var collectionName:String{
        return "documentMetadatas"
    }

    override open var d_collectionName:String{
        return DocumentMetadata.collectionName
    }
}