//
//  ManagedModel.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for [Benoit Pereira da Silva] (https://pereira-da-silva.com/contact)
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  [Bartleby's org] (https://bartlebys.org)   All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
	#endif

// MARK: Bartleby's Core: The base of any ManagedModel
@objc open class ManagedModel : NSObject, Collectible, Codable{

    // Universal type support
    open class func typeName() -> String {
        return "ManagedModel"
    }

	//The object unique Identifier is named _id to gains native support in MongoDB - you can use UID as accessor 
	@objc dynamic open var _id:String = Default.NO_UID

	//An external unique identifier
	@objc dynamic open var externalID:String = "" {
	    didSet { 
	       if !self.wantsQuietChanges && externalID != oldValue {
	            self.provisionChanges(forKey: "externalID",oldValue: oldValue,newValue: externalID) 
	       } 
	    }
	}

	//Collectible protocol: The Creator UID - Can be used for ACL purposes automatically injected in new entities Factories
	@objc dynamic open var creatorUID:String = Default.NO_UID

	//The I18N base language code
	@objc dynamic open var languageCode:String = Bartleby.defaultLanguageCode

	//The UIDS of the owners
	@objc dynamic open var ownedBy:[String] = [String]()  {
	    didSet { 
	       if !self.wantsQuietChanges && ownedBy != oldValue {
	            self.provisionChanges(forKey: "ownedBy",oldValue: oldValue,newValue: ownedBy)  
	       } 
	    }
	}

	//The UIDS of the free relations
	@objc dynamic open var freeRelations:[String] = [String]()  {
	    didSet { 
	       if !self.wantsQuietChanges && freeRelations != oldValue {
	            self.provisionChanges(forKey: "freeRelations",oldValue: oldValue,newValue: freeRelations)  
	       } 
	    }
	}

	//The UIDS of the owned entities (Neither supervised nor serialized check appendToDeferredOwnershipsList for explanations)
	@objc dynamic open var owns:[String] = [String]()

	//A human readable model summary. If you want to disclose more information you can adopt the Descriptible protocol.
	@objc dynamic open var summary:String? {
	    didSet { 
	       if !self.wantsQuietChanges && summary != oldValue {
	            self.provisionChanges(forKey: "summary",oldValue: oldValue,newValue: summary) 
	       } 
	    }
	}

	//An instance Marked ephemeral will be destroyed server side on next ephemeral cleaning procedure.This flag allows for example to remove entities that have been for example created by unit-tests.
	@objc dynamic open var ephemeral:Bool = false

	//MARK: - ChangesInspectable Protocol
	@objc dynamic open var changedKeys:[KeyedChanges] = [KeyedChanges]()

	////Internal flag used not to propagate changes (for example during deserialization) -> Check ManagedModel + ProvisionChanges for detailled explanantions
	@objc dynamic internal var _quietChanges:Bool = false

	////Auto commit availability -> Check ManagedModel + ProvisionChanges for detailed explanantions
	@objc dynamic internal var _autoCommitIsEnabled:Bool = true

	//The internal commit provisioning counter to discriminate Creation from Update and for possible frequency analysis
	@objc dynamic open var commitCounter:Int = 0


    // A reference to the document that currently holds this Managed Model.
    // Most of the time set by its collection (with notable exclusion of currentUser, and a few other special cases)
    public var referentDocument:BartlebyDocument?

    // Set by propagation or when using the document factory
    // It connects the instance to its collection and document
    public var collection:CollectibleCollection?{
        didSet{
            if let document=collection?.referentDocument{
                self.referentDocument = document
                // tag ephemeral instance
                if Bartleby.ephemeral {
                    self.ephemeral=true
                }
                // And register to Bartleby
                Bartleby.register(self)
            }else{
                glog("Referent document is not set on \(String(describing: collection?.runTimeTypeName()))", file: #file, function: #function, line: #line, category: Default.LOG_FAULT, decorative: false)
            }
        }
    }

    //The supervisers container
    internal var _supervisers=[String:SupervisionClosure]()
    // MARK: UniversalType

    // Used to store the type name on serialization
    fileprivate lazy var _typeName: String = type(of: self).typeName()

    // The Run time Type name (can be different to typeName)
    internal var _runTimeTypeName: String?

    // The UID is stored in _id to match MongoDB convention so we use a computed property
    // UID is a dynamic @objc to be available for cocoa bindings
    @objc open dynamic var UID:String { get{ return self._id } set{  self._id = newValue } }

    // The key value localization proxy (original values are stored in the model, and localized in separate localized datum)
    lazy open var localized:Localized = Localized(reference:self)

    // MARK: - Codable


    public enum ManagedModelCodingKeys: String,CodingKey{
		case _id
		case externalID
		case creatorUID
		case languageCode
		case ownedBy
		case freeRelations
		case owns
		case summary
		case ephemeral
		case changedKeys
		case _quietChanges
		case _autoCommitIsEnabled
		case commitCounter
		case typeName
    }

    required public init(from decoder: Decoder) throws{
		super.init()
        try self.quietThrowingChanges {
			let values = try decoder.container(keyedBy: ManagedModelCodingKeys.self)
			self._id = try values.decode(String.self,forKey:._id)
			self.externalID = try values.decode(String.self,forKey:.externalID)
			self.creatorUID = try values.decode(String.self,forKey:.creatorUID)
			self.languageCode = try values.decode(String.self,forKey:.languageCode)
			self.ownedBy = try values.decode([String].self,forKey:.ownedBy)
			self.freeRelations = try values.decode([String].self,forKey:.freeRelations)
			self.summary = try values.decodeIfPresent(String.self,forKey:.summary)
			self.ephemeral = try values.decode(Bool.self,forKey:.ephemeral)
			self.commitCounter = try values.decode(Int.self,forKey:.commitCounter)
            self._typeName = try values.decode(String.self,forKey:.typeName)
        }
    }

    open func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: ManagedModelCodingKeys.self)
		try container.encode(self._id,forKey:._id)
		try container.encode(self.externalID,forKey:.externalID)
		try container.encode(self.creatorUID,forKey:.creatorUID)
		try container.encode(self.languageCode,forKey:.languageCode)
		try container.encode(self.ownedBy,forKey:.ownedBy)
		try container.encode(self.freeRelations,forKey:.freeRelations)
		try container.encodeIfPresent(self.summary,forKey:.summary)
		try container.encode(self.ephemeral,forKey:.ephemeral)
		try container.encode(self.commitCounter,forKey:.commitCounter)
        try container.encode(self._typeName,forKey:.typeName)
        
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
     open var exposedKeys:[String] {
        var exposed=[String]()
        exposed.append(contentsOf:["_id","externalID","creatorUID","languageCode","ownedBy","freeRelations","owns","summary","ephemeral","changedKeys","commitCounter"])
        return exposed
    }


    /// Set the value of the given key
    ///
    /// - parameter value: the value
    /// - parameter key:   the key
    ///
    /// - throws: throws an Exception when the key is not exposed
     open func setExposedValue(_ value:Any?, forKey key: String) throws {
        switch key {
            case "_id":
                if let casted=value as? String{
                    self._id=casted
                }
            case "externalID":
                if let casted=value as? String{
                    self.externalID=casted
                }
            case "creatorUID":
                if let casted=value as? String{
                    self.creatorUID=casted
                }
            case "languageCode":
                if let casted=value as? String{
                    self.languageCode=casted
                }
            case "ownedBy":
                if let casted=value as? [String]{
                    self.ownedBy=casted
                }
            case "freeRelations":
                if let casted=value as? [String]{
                    self.freeRelations=casted
                }
            case "owns":
                if let casted=value as? [String]{
                    self.owns=casted
                }
            case "summary":
                if let casted=value as? String{
                    self.summary=casted
                }
            case "ephemeral":
                if let casted=value as? Bool{
                    self.ephemeral=casted
                }
            case "changedKeys":
                if let casted=value as? [KeyedChanges]{
                    self.changedKeys=casted
                }
            case "commitCounter":
                if let casted=value as? Int{
                    self.commitCounter=casted
                }
            default:
                throw ObjectExpositionError.unknownKey(key: key,forTypeName: ManagedModel.typeName())
        }
    }


    /// Returns the value of an exposed key.
    ///
    /// - parameter key: the key
    ///
    /// - throws: throws Exception when the key is not exposed
    ///
    /// - returns: returns the value
     open func getExposedValueForKey(_ key:String) throws -> Any?{
        switch key {
            case "_id":
               return self._id
            case "externalID":
               return self.externalID
            case "creatorUID":
               return self.creatorUID
            case "languageCode":
               return self.languageCode
            case "ownedBy":
               return self.ownedBy
            case "freeRelations":
               return self.freeRelations
            case "owns":
               return self.owns
            case "summary":
               return self.summary
            case "ephemeral":
               return self.ephemeral
            case "changedKeys":
               return self.changedKeys
            case "commitCounter":
               return self.commitCounter
            default:
                throw ObjectExpositionError.unknownKey(key: key,forTypeName: ManagedModel.typeName())
        }
    }
    // MARK: - Initializable
   override  required public init() {
        super.init()
    }

    // MARK: - UniversalType
     open class var collectionName:String{
        return "managedModels"
    }

     open var d_collectionName:String{
        return ManagedModel.collectionName
    }
}