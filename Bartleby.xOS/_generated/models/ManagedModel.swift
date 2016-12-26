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
	import Alamofire
	import ObjectMapper
#endif

// MARK: Bartleby's Core: The base of any ManagedModel
@objc(ManagedModel) open class ManagedModel : NSObject, Collectible, Mappable, NSSecureCoding{

    // Universal type support
     open class func typeName() -> String {
        return "ManagedModel"
    }

	//An external unique identifier
	dynamic open var externalID:String? {
	    didSet { 
	       if !self.wantsQuietChanges && externalID != oldValue {
	            self.provisionChanges(forKey: "externalID",oldValue: oldValue,newValue: externalID) 
	       } 
	    }
	}

	//Collectible protocol: The Creator UID - Can be used for ACL purposes automatically injected in new entities Factories
	dynamic open var creatorUID:String = "\(Default.NO_UID)"

	//The UIDS of the owners
	dynamic open var ownedBy:[String] = [String]()  {
	    didSet { 
	       if !self.wantsQuietChanges && ownedBy != oldValue {
	            self.provisionChanges(forKey: "ownedBy",oldValue: oldValue,newValue: ownedBy)  
	       } 
	    }
	}

	//The UIDS of the free relations
	dynamic open var freeRelations:[String] = [String]()  {
	    didSet { 
	       if !self.wantsQuietChanges && freeRelations != oldValue {
	            self.provisionChanges(forKey: "freeRelations",oldValue: oldValue,newValue: freeRelations)  
	       } 
	    }
	}

	//The UIDS of the owned entities (Neither supervised nor serialized)
	dynamic open var owns:[String] = [String]()

	//The object summary can be used for example by externalReferences to describe the ManagedObject instance. If you want to disclose more information you can adopt the Descriptible protocol.
	dynamic open var summary:String? {
	    didSet { 
	       if !self.wantsQuietChanges && summary != oldValue {
	            self.provisionChanges(forKey: "summary",oldValue: oldValue,newValue: summary) 
	       } 
	    }
	}

	//An instance Marked ephemeral will be destroyed server side on next ephemeral cleaning procedure.This flag allows for example to remove entities that have been for example created by unit-tests.
	dynamic open var ephemeral:Bool = false

	//MARK: - ChangesInspectable Protocol
	dynamic open var changedKeys:[KeyedChanges] = [KeyedChanges]()

	//Internal flag used not to propagate changes for example during deserialization (it blocks provisionChanges)
	dynamic internal var _quietChanges:Bool = false

	//Auto commit availability
	dynamic internal var _autoCommitIsEnabled:Bool = true

	//Is supervision enabled?
	dynamic internal var _supervisionIsEnabled:Bool = true

	//The internal commit provisionning counter to discriminate Creation from Update and for possible frequency analysis
	dynamic open var commitCounter:Int = 0

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
                glog("Referent document is not set on \(collection?.runTimeTypeName())", file: #file, function: #function, line: #line, category: Default.LOG_FAULT, decorative: false)
            }
        }
    }

    // The internal _id
    internal lazy var _id: String = Bartleby.createUID()

    // Returns the UID
    public var UID: String { return  self._id }


    //The supervisers container
    internal var _supervisers=[String:SupervisionClosure]()
    // MARK: UniversalType

    // Used to store the type name on serialization
    fileprivate lazy var _typeName: String = type(of: self).typeName()

    // The Run time Type name (can be different to typeName)
    internal var _runTimeTypeName: String?


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
     open var exposedKeys:[String] {
        var exposed=[String]()
        exposed.append(contentsOf:["externalID","creatorUID","ownedBy","freeRelations","owns","summary","ephemeral","changedKeys","commitCounter"])
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
            case "externalID":
                if let casted=value as? String{
                    self.externalID=casted
                }
            case "creatorUID":
                if let casted=value as? String{
                    self.creatorUID=casted
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
            case "externalID":
               return self.externalID
            case "creatorUID":
               return self.creatorUID
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
    // MARK: - Mappable

    required public init?(map: Map) {
        
    }

     open func mapping(map: Map) {
        
        self.quietChanges {
			self.externalID <- ( map["externalID"] )
			self.creatorUID <- ( map["creatorUID"] )
			self.ownedBy <- ( map["ownedBy"] )
			self.freeRelations <- ( map["freeRelations"] )
			self.summary <- ( map["summary"] )
			self.ephemeral <- ( map["ephemeral"] )
			self.commitCounter <- ( map["commitCounter"] )
            self._typeName <- map[Default.TYPE_NAME_KEY]
            self._id <- map[Default.UID_KEY]
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init()
        self.quietChanges {
			self.externalID=String(describing: decoder.decodeObject(of: NSString.self, forKey:"externalID") as NSString?)
			self.creatorUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "creatorUID")! as NSString)
			self.ownedBy=decoder.decodeObject(of: [NSArray.classForCoder(),NSString.self], forKey: "ownedBy")! as! [String]
			self.freeRelations=decoder.decodeObject(of: [NSArray.classForCoder(),NSString.self], forKey: "freeRelations")! as! [String]
			self.summary=String(describing: decoder.decodeObject(of: NSString.self, forKey:"summary") as NSString?)
			self.ephemeral=decoder.decodeBool(forKey:"ephemeral") 
			self.commitCounter=decoder.decodeInteger(forKey:"commitCounter") 
            self._typeName=type(of: self).typeName()
            self._id=String(describing: decoder.decodeObject(of: NSString.self, forKey: "_id")! as NSString)
        }
    }

     open func encode(with coder: NSCoder) {
        
		if let externalID = self.externalID {
			coder.encode(externalID,forKey:"externalID")
		}
		coder.encode(self.creatorUID,forKey:"creatorUID")
		coder.encode(self.ownedBy,forKey:"ownedBy")
		coder.encode(self.freeRelations,forKey:"freeRelations")
		if let summary = self.summary {
			coder.encode(summary,forKey:"summary")
		}
		coder.encode(self.ephemeral,forKey:"ephemeral")
		coder.encode(self.commitCounter,forKey:"commitCounter")
        self._typeName=type(of: self).typeName()// Store the universal type name on serialization
        coder.encode(self._typeName, forKey: Default.TYPE_NAME_KEY)
        coder.encode(self._id, forKey: Default.UID_KEY)
        
    }

     open class var supportsSecureCoding:Bool{
        return true
    }

    override required public init() {
        super.init()
    }

     open class var collectionName:String{
        return "managedModels"
    }

     open var d_collectionName:String{
        return ManagedModel.collectionName
    }
}