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
#endif

// MARK: Bartleby's Core: Complete implementation in DocumentMetadata.
@objc(DocumentMetadata) open class DocumentMetadata : UnManagedModel {


	//The data space UID can be shared between multiple Docuemnt.
	@objc dynamic open var spaceUID:String = "\(Bartleby.createUID())"

	//Defines the document UID.
	@objc dynamic open var persistentUID:String = "\(Bartleby.createUID())"

	//The user UID currently associated to the local instance of the document
	@objc dynamic open var currentUserUID:String = "\(Default.NO_UID)"

	//The current user email (to be displayed during identity control)
	@objc dynamic open var currentUserEmail:String = "\(Default.VOID_STRING)"

	//The current user full phone number including the prefix (to be displayed during identity control)
	@objc dynamic open var currentUserFullPhoneNumber:String = "\(Default.VOID_STRING)"

	//The sugar (not serialized but loaded from the Bowl)
	@objc dynamic open var sugar:String = "\(Default.VOID_STRING)"

	//The locker UID to be used by the user to obtain the sugar from the locker
	@objc dynamic open var lockerUID:String = "\(Default.NO_UID)"

	//Has the current user been controlled
	@objc dynamic open var userHasBeenControlled:Bool = false

	//If set to false the identification chain will by pass the second authentication factor
	@objc dynamic open var secondaryAuthFactorRequired:Bool = Bartleby.configuration.REDUCED_SECURITY_MODE

	//The identification method (By cookie or by Key - kvid)
	public enum IdentificationMethod:String{
		case key = "key"
		case cookie = "cookie"
	}
	open var identificationMethod:IdentificationMethod = .key

	//You can define a shared app group container identifier "group.myDomain.com.groupName")
	@objc dynamic open var appGroup:String = ""

	//The current kvid identification value (injected in HTTP headers)
	@objc dynamic open var identificationValue:String?

	//The url of the collaboration server
	@objc dynamic open var collaborationServerURL:URL?

	//Should be Set to true only when the document has been correctly registred on collaboration server
	@objc dynamic open var registred:Bool = false

	//If the changes are inspectable all the changes are stored in KeyChanges objects
	@objc dynamic open var changesAreInspectables:Bool = Bartleby.configuration.CHANGES_ARE_INSPECTABLES_BY_DEFAULT

	//If set to true the boxes will be deleted when closing the document (Better security) 
	@objc dynamic open var cleanupBoxesWhenClosingDocument:Bool = true

	//A collection of CollectionMetadatum
	@objc dynamic open var collectionsMetadata:[CollectionMetadatum] = [CollectionMetadatum]()

	//The State dictionary to insure document persistency 
	@objc dynamic open var stateDictionary:[String:Any] = [String:AnyObject]()

	//A collection of KeyedData
	@objc dynamic open var URLBookmarkData:[KeyedData] = [KeyedData]()

	//The preferred filename for this document
	@objc dynamic open var preferredFileName:String?

	//used for Core Debug , stores all the indexes by order of reception.
	@objc dynamic open var triggersIndexesDebugHistory:[Int] = [Int]()

	//The persistentcollection of triggers indexes owned by the current user (allows local distinctive analytics even on cloned documents)
	@objc dynamic open var ownedTriggersIndexes:[Int] = [Int]()

	//The index of the last trigger that has been integrated
	open var lastIntegratedTriggerIndex:Int = -1

	//A collection Triggers that are temporarly stored before data integration
	@objc dynamic open var receivedTriggers:[Trigger] = [Trigger]()

	//A collection of PushOperations in Quarantine (check DataSynchronization.md "Faults" section for details) 
	@objc dynamic open var operationsQuarantine:[PushOperation] = [PushOperation]()

	//Do we have operations in progress in the current bunch ?
	@objc dynamic open var bunchInProgress:Bool = false

	//The highest number that we may have counted
	open var totalNumberOfOperations:Int = 0

	//The consolidated progression state of all pending operations
	@objc dynamic open var pendingOperationsProgressionState:Progression?

	//When monitoring reachability we need to know if we should be connected to Collaborative server
	@objc dynamic open var shouldBeOnline:Bool = Bartleby.configuration.ONLINE_BY_DEFAULT

	//is the user performing Online
	@objc dynamic open var online:Bool = Bartleby.configuration.ONLINE_BY_DEFAULT

	//Is the document transitionning offToOn: offline > online, onToOff: online > offine
	public enum Transition:String{
		case none = "none"
		case offToOn = "offToOn"
		case onToOff = "onToOff"
	}
	open var transition:Transition = .none

	//If set to true committed object will be pushed as soon as possible.
	@objc dynamic open var pushOnChanges:Bool = Bartleby.configuration.ONLINE_BY_DEFAULT

	//Save the password or not?
	@objc dynamic open var saveThePassword:Bool = Bartleby.configuration.SAVE_PASSWORD_BY_DEFAULT

	//The sum of all the metrics
	@objc dynamic open var cumulatedUpMetricsDuration:Double = 0

	//Total number of metrics since the document creation
	@objc dynamic open var totalNumberOfUpMetrics:Int = 0

	//The qos Indice
	@objc dynamic open var qosIndice:Double = 0


    // MARK: - Codable


    enum DocumentMetadataCodingKeys: String,CodingKey{
		case spaceUID
		case persistentUID
		case currentUserUID
		case currentUserEmail
		case currentUserFullPhoneNumber
		case sugar
		case lockerUID
		case userHasBeenControlled
		case secondaryAuthFactorRequired
		case identificationMethod
		case appGroup
		case identificationValue
		case collaborationServerURL
		case registred
		case changesAreInspectables
		case cleanupBoxesWhenClosingDocument
		case collectionsMetadata
		case stateDictionary
		case URLBookmarkData
		case preferredFileName
		case triggersIndexesDebugHistory
		case ownedTriggersIndexes
		case lastIntegratedTriggerIndex
		case receivedTriggers
		case operationsQuarantine
		case bunchInProgress
		case totalNumberOfOperations
		case pendingOperationsProgressionState
		case shouldBeOnline
		case online
		case transition
		case pushOnChanges
		case saveThePassword
		case cumulatedUpMetricsDuration
		case totalNumberOfUpMetrics
		case qosIndice
    }

    required public init(from decoder: Decoder) throws{
		try super.init(from: decoder)
        try self.quietThrowingChanges {
			let values = try decoder.container(keyedBy: DocumentMetadataCodingKeys.self)
			self.spaceUID = try values.decode(String.self,forKey:.spaceUID)
			self.persistentUID = try values.decode(String.self,forKey:.persistentUID)
			self.currentUserUID = try values.decode(String.self,forKey:.currentUserUID)
			self.currentUserEmail = try values.decode(String.self,forKey:.currentUserEmail)
			self.currentUserFullPhoneNumber = try values.decode(String.self,forKey:.currentUserFullPhoneNumber)
			self.lockerUID = try values.decode(String.self,forKey:.lockerUID)
			self.secondaryAuthFactorRequired = try values.decode(Bool.self,forKey:.secondaryAuthFactorRequired)
			self.identificationMethod = DocumentMetadata.IdentificationMethod(rawValue: try values.decode(String.self,forKey:.identificationMethod)) ?? .key
			self.appGroup = try values.decode(String.self,forKey:.appGroup)
			self.identificationValue = try values.decode(String.self,forKey:.identificationValue)
			self.collaborationServerURL = try values.decode(URL.self,forKey:.collaborationServerURL)
			self.registred = try values.decode(Bool.self,forKey:.registred)
			self.collectionsMetadata = try values.decode([CollectionMetadatum].self,forKey:.collectionsMetadata)
			self.stateDictionary = try values.decode([String:Any].self,forKey:.stateDictionary)
			self.URLBookmarkData = try values.decode([KeyedData].self,forKey:.URLBookmarkData)
			self.preferredFileName = try values.decode(String.self,forKey:.preferredFileName)
			self.triggersIndexesDebugHistory = try values.decode([Int].self,forKey:.triggersIndexesDebugHistory)
			self.ownedTriggersIndexes = try values.decode([Int].self,forKey:.ownedTriggersIndexes)
			self.lastIntegratedTriggerIndex = try values.decode(Int.self,forKey:.lastIntegratedTriggerIndex)
			self.receivedTriggers = try values.decode([Trigger].self,forKey:.receivedTriggers)
			self.operationsQuarantine = try values.decode([PushOperation].self,forKey:.operationsQuarantine)
			self.shouldBeOnline = try values.decode(Bool.self,forKey:.shouldBeOnline)
			self.online = try values.decode(Bool.self,forKey:.online)
			self.pushOnChanges = try values.decode(Bool.self,forKey:.pushOnChanges)
			self.saveThePassword = try values.decode(Bool.self,forKey:.saveThePassword)
			self.cumulatedUpMetricsDuration = try values.decode(Double.self,forKey:.cumulatedUpMetricsDuration)
			self.totalNumberOfUpMetrics = try values.decode(Int.self,forKey:.totalNumberOfUpMetrics)
			self.qosIndice = try values.decode(Double.self,forKey:.qosIndice)
        }
    }

    override open func encode(to encoder: Encoder) throws {
		try super.encode(to:encoder)
		var container = encoder.container(keyedBy: DocumentMetadataCodingKeys.self)
		try container.encodeIfPresent(self.spaceUID,forKey:.spaceUID)
		try container.encodeIfPresent(self.persistentUID,forKey:.persistentUID)
		try container.encodeIfPresent(self.currentUserUID,forKey:.currentUserUID)
		try container.encodeIfPresent(self.currentUserEmail,forKey:.currentUserEmail)
		try container.encodeIfPresent(self.currentUserFullPhoneNumber,forKey:.currentUserFullPhoneNumber)
		try container.encodeIfPresent(self.lockerUID,forKey:.lockerUID)
		try container.encodeIfPresent(self.secondaryAuthFactorRequired,forKey:.secondaryAuthFactorRequired)
		try container.encodeIfPresent(self.identificationMethod.rawValue ,forKey:.identificationMethod)
		try container.encodeIfPresent(self.appGroup,forKey:.appGroup)
		try container.encodeIfPresent(self.identificationValue,forKey:.identificationValue)
		try container.encodeIfPresent(self.collaborationServerURL,forKey:.collaborationServerURL)
		try container.encodeIfPresent(self.registred,forKey:.registred)
		try container.encodeIfPresent(self.collectionsMetadata,forKey:.collectionsMetadata)
		try container.encodeIfPresent(self.stateDictionary,forKey:.stateDictionary)
		try container.encodeIfPresent(self.URLBookmarkData,forKey:.URLBookmarkData)
		try container.encodeIfPresent(self.preferredFileName,forKey:.preferredFileName)
		try container.encodeIfPresent(self.triggersIndexesDebugHistory,forKey:.triggersIndexesDebugHistory)
		try container.encodeIfPresent(self.ownedTriggersIndexes,forKey:.ownedTriggersIndexes)
		try container.encodeIfPresent(self.lastIntegratedTriggerIndex,forKey:.lastIntegratedTriggerIndex)
		try container.encodeIfPresent(self.receivedTriggers,forKey:.receivedTriggers)
		try container.encodeIfPresent(self.operationsQuarantine,forKey:.operationsQuarantine)
		try container.encodeIfPresent(self.shouldBeOnline,forKey:.shouldBeOnline)
		try container.encodeIfPresent(self.online,forKey:.online)
		try container.encodeIfPresent(self.pushOnChanges,forKey:.pushOnChanges)
		try container.encodeIfPresent(self.saveThePassword,forKey:.saveThePassword)
		try container.encodeIfPresent(self.cumulatedUpMetricsDuration,forKey:.cumulatedUpMetricsDuration)
		try container.encodeIfPresent(self.totalNumberOfUpMetrics,forKey:.totalNumberOfUpMetrics)
		try container.encodeIfPresent(self.qosIndice,forKey:.qosIndice)
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override  open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["spaceUID","persistentUID","currentUserUID","currentUserEmail","currentUserFullPhoneNumber","sugar","lockerUID","userHasBeenControlled","secondaryAuthFactorRequired","identificationMethod","appGroup","identificationValue","collaborationServerURL","registred","changesAreInspectables","cleanupBoxesWhenClosingDocument","collectionsMetadata","stateDictionary","URLBookmarkData","preferredFileName","triggersIndexesDebugHistory","ownedTriggersIndexes","lastIntegratedTriggerIndex","receivedTriggers","operationsQuarantine","bunchInProgress","totalNumberOfOperations","pendingOperationsProgressionState","shouldBeOnline","online","transition","pushOnChanges","saveThePassword","cumulatedUpMetricsDuration","totalNumberOfUpMetrics","qosIndice"])
        return exposed
    }


    /// Set the value of the given key
    ///
    /// - parameter value: the value
    /// - parameter key:   the key
    ///
    /// - throws: throws an Exception when the key is not exposed
    override  open func setExposedValue(_ value:Any?, forKey key: String) throws {
        switch key {
            case "spaceUID":
                if let casted=value as? String{
                    self.spaceUID=casted
                }
            case "persistentUID":
                if let casted=value as? String{
                    self.persistentUID=casted
                }
            case "currentUserUID":
                if let casted=value as? String{
                    self.currentUserUID=casted
                }
            case "currentUserEmail":
                if let casted=value as? String{
                    self.currentUserEmail=casted
                }
            case "currentUserFullPhoneNumber":
                if let casted=value as? String{
                    self.currentUserFullPhoneNumber=casted
                }
            case "sugar":
                if let casted=value as? String{
                    self.sugar=casted
                }
            case "lockerUID":
                if let casted=value as? String{
                    self.lockerUID=casted
                }
            case "userHasBeenControlled":
                if let casted=value as? Bool{
                    self.userHasBeenControlled=casted
                }
            case "secondaryAuthFactorRequired":
                if let casted=value as? Bool{
                    self.secondaryAuthFactorRequired=casted
                }
            case "identificationMethod":
                if let casted=value as? DocumentMetadata.IdentificationMethod{
                    self.identificationMethod=casted
                }
            case "appGroup":
                if let casted=value as? String{
                    self.appGroup=casted
                }
            case "identificationValue":
                if let casted=value as? String{
                    self.identificationValue=casted
                }
            case "collaborationServerURL":
                if let casted=value as? URL{
                    self.collaborationServerURL=casted
                }
            case "registred":
                if let casted=value as? Bool{
                    self.registred=casted
                }
            case "changesAreInspectables":
                if let casted=value as? Bool{
                    self.changesAreInspectables=casted
                }
            case "cleanupBoxesWhenClosingDocument":
                if let casted=value as? Bool{
                    self.cleanupBoxesWhenClosingDocument=casted
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
                if let casted=value as? [KeyedData]{
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
    override  open func getExposedValueForKey(_ key:String) throws -> Any?{
        switch key {
            case "spaceUID":
               return self.spaceUID
            case "persistentUID":
               return self.persistentUID
            case "currentUserUID":
               return self.currentUserUID
            case "currentUserEmail":
               return self.currentUserEmail
            case "currentUserFullPhoneNumber":
               return self.currentUserFullPhoneNumber
            case "sugar":
               return self.sugar
            case "lockerUID":
               return self.lockerUID
            case "userHasBeenControlled":
               return self.userHasBeenControlled
            case "secondaryAuthFactorRequired":
               return self.secondaryAuthFactorRequired
            case "identificationMethod":
               return self.identificationMethod
            case "appGroup":
               return self.appGroup
            case "identificationValue":
               return self.identificationValue
            case "collaborationServerURL":
               return self.collaborationServerURL
            case "registred":
               return self.registred
            case "changesAreInspectables":
               return self.changesAreInspectables
            case "cleanupBoxesWhenClosingDocument":
               return self.cleanupBoxesWhenClosingDocument
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
    // MARK: - Initializable
     required public init() {
        super.init()
    }
}