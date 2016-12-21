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

	//Reflects the index of of the item in the collection initial value is -1. During it life cycle the collection updates if necessary its real value. ‡It allow better perfomance in Collection Controllers ( e.g : random insertion and entity removal )
	dynamic open var collectedIndex:Int = -1

	//Collectible protocol: The Creator UID - Can be used for ACL purposes automatically injected in new entities Factories
	dynamic open var creatorUID:String = "\(Default.NO_UID)"

	//Used to store inter objects relationships
	dynamic internal var _relations:[Relation] = [Relation]()  {
	    didSet { 
	       if !self.wantsQuietChanges && _relations != oldValue {
	            self.provisionChanges(forKey: "_relations",oldValue: oldValue,newValue: _relations)  
	       } 
	    }
	}

	//The object summary can be used for example by externalReferences to describe the JObject instance. If you want to disclose more information you can adopt the Descriptible protocol.
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

	//The internal flag for auto commit
	dynamic internal var _shouldBeCommitted:Bool = false

	//The internal commit provisionning counter to discriminate Creation from Update and for possible frequency analysis
	dynamic internal var _commitCounter:Int = 0

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
        exposed.append(contentsOf:["collectedIndex","creatorUID","summary","ephemeral","changedKeys"])
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
            case "collectedIndex":
                if let casted=value as? Int{
                    self.collectedIndex=casted
                }
            case "creatorUID":
                if let casted=value as? String{
                    self.creatorUID=casted
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
            default:
                throw ObjectExpositionError.UnknownKey(key: key,forTypeName: ManagedModel.typeName())
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
            case "collectedIndex":
               return self.collectedIndex
            case "creatorUID":
               return self.creatorUID
            case "summary":
               return self.summary
            case "ephemeral":
               return self.ephemeral
            case "changedKeys":
               return self.changedKeys
            default:
                throw ObjectExpositionError.UnknownKey(key: key,forTypeName: ManagedModel.typeName())
        }
    }
    // MARK: - Mappable

    required public init?(map: Map) {
        
    }

     open func mapping(map: Map) {
        
        self.quietChanges {
			self.collectedIndex <- ( map["collectedIndex"] )
			self.creatorUID <- ( map["creatorUID"] )
			self._relations <- ( map["_relations"] )
			self.summary <- ( map["summary"] )
			self.ephemeral <- ( map["ephemeral"] )
			self._commitCounter <- ( map["_commitCounter"] )
            self._typeName <- map[Default.TYPE_NAME_KEY]
            self._id <- map[Default.UID_KEY]
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init()
        self.quietChanges {
			self.collectedIndex=decoder.decodeInteger(forKey:"collectedIndex") 
			self.creatorUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "creatorUID")! as NSString)
			self._relations=decoder.decodeObject(of: [NSArray.classForCoder(),Relation.classForCoder()], forKey: "_relations")! as! [Relation]
			self.summary=String(describing: decoder.decodeObject(of: NSString.self, forKey:"summary") as NSString?)
			self.ephemeral=decoder.decodeBool(forKey:"ephemeral") 
			self._commitCounter=decoder.decodeInteger(forKey:"_commitCounter") 
            self._typeName=type(of: self).typeName()
            self._id=String(describing: decoder.decodeObject(of: NSString.self, forKey: "_id")! as NSString)
        }
    }

     open func encode(with coder: NSCoder) {
        
		coder.encode(self.collectedIndex,forKey:"collectedIndex")
		coder.encode(self.creatorUID,forKey:"creatorUID")
		coder.encode(self._relations,forKey:"_relations")
		if let summary = self.summary {
			coder.encode(summary,forKey:"summary")
		}
		coder.encode(self.ephemeral,forKey:"ephemeral")
		coder.encode(self._commitCounter,forKey:"_commitCounter")
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