//
//  BartlebyObject.swift
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

// MARK: Bartleby's Core: The base object of any generated Object. Parts of the Collectible implementation is located the BaseObject class
@objc(BartlebyObject) open class BartlebyObject : NSObject, Collectible, Mappable, NSSecureCoding{

    // Universal type support
     open class func typeName() -> String {
        return "BartlebyObject"
    }

	//Auto commit availability
	dynamic internal var _autoCommitIsEnabled:Bool = true

	//The internal flag for auto commit
	dynamic internal var _shouldBeCommitted:Bool = false

	//Supervision availability
	dynamic internal var _supervisionIsEnabled:Bool = true

	//Reflects the index of of the item in the collection initial value is -1. During it life cycle the collection updates if necessary its real value. ‡It allow better perfomance in Collection Controllers ( e.g : random insertion and entity removal )
	dynamic open var collectedIndex:Int = -1

	//Collectible protocol: The Creator UID
	dynamic open var creatorUID:String = "\(Default.NO_UID)"{	 
	    didSet { 
	       if creatorUID != oldValue {
	            self.provisionChanges(forKey: "creatorUID",oldValue: oldValue,newValue: creatorUID) 
	       } 
	    }
	}


	//The object summary can be used for example by externalReferences to describe the JObject instance. If you want to disclose more information you can adopt the Descriptible protocol.
	dynamic open var summary:String? {	 
	    didSet { 
	       if summary != oldValue {
	            self.provisionChanges(forKey: "summary",oldValue: oldValue,newValue: summary) 
	       } 
	    }
	}


	//An instance Marked ephemeral will be destroyed server side on next ephemeral cleaning procedure.This flag allows for example to remove entities that have been for example created by unit-tests.
	dynamic open var ephemeral:Bool = false  {	 
	    didSet { 
	       if ephemeral != oldValue {
	            self.provisionChanges(forKey: "ephemeral",oldValue: oldValue,newValue: ephemeral)  
	       } 
	    }
	}


	//Collectible protocol: distributed
	dynamic open var distributed:Bool = false  {	 
	    didSet { 
	       if distributed != oldValue {
	            self.provisionChanges(forKey: "distributed",oldValue: oldValue,newValue: distributed)  
	       } 
	    }
	}


	//The version is incremented on each change (used to detect distributed divergences)
	dynamic open var version:Int = 0

	//MARK: - ChangesInspectable Protocol
	dynamic open var changedKeys:[KeyedChanges] = [KeyedChanges]()

    // MARK: - BaseObject Block

    // This  id is always  created locally and used as primary index by MONGODB
    internal var _id: String=Default.NO_UID{
        didSet {
            // tag ephemeral instance
            if Bartleby.ephemeral {
                self.ephemeral=true
            }
            // And register.
            Registry.register(self)
        }
    }

    /**
     The creation of a Unique Identifier is ressource intensive.
     We create the UID only if necessary.
     */
    open func defineUID() {
        if self._id == Default.NO_UID {
            self._id=Bartleby.createUID()
        }
    }

    final public var UID: String {
        get {
            self.defineUID()
            return  self._id
        }
    }
    
    //The supervisers container
    internal var _supervisers=[String:SupervisionClosure]()

    deinit{
        self._supervisers.removeAll()
    }
    // An optionnal Quick reference to the document
    open var document:BartlebyDocument?

    // On object insertion or Registry deserialization
    // We setup this collection reference
    // On newUser we setup directly user.document.
    open var collection:CollectibleCollection?{
        didSet{
            if let registry=collection?.document{
                self.document=registry
            }
        }
    }


    open var committed: Bool = false {
        willSet {
            if newValue==true{
                // The changes have been committed
                self._shouldBeCommitted=false
            }
        }
    }

    // MARK: UniversalType

    // Used to store the type name on serialization
    fileprivate lazy var _typeName: String = type(of: self).typeName()

    internal var _runTimeTypeName: String?

    // The runTypeName is used when deserializing the instance.
    open func runTimeTypeName() -> String {
        guard let _ = self._runTimeTypeName  else {
            self._runTimeTypeName = NSStringFromClass(type(of: self))
            return self._runTimeTypeName!
        }
        return self._runTimeTypeName!
    }

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
     open var exposedKeys:[String] {
        var exposed=[String]()
        exposed.append(contentsOf:["collectedIndex","creatorUID","summary","ephemeral","distributed","version","changedKeys"])
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
            case "distributed":
                if let casted=value as? Bool{
                    self.distributed=casted
                }
            case "version":
                if let casted=value as? Int{
                    self.version=casted
                }
            case "changedKeys":
                if let casted=value as? [KeyedChanges]{
                    self.changedKeys=casted
                }
            default:
                throw ObjectExpositionError.UnknownKey(key: key)
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
            case "distributed":
               return self.distributed
            case "version":
               return self.version
            case "changedKeys":
               return self.changedKeys
            default:
                throw ObjectExpositionError.UnknownKey(key: key)
        }
    }
    // MARK: - Mappable

    required public init?(map: Map) {
        
    }

     open func mapping(map: Map) {
        
        self.silentGroupedChanges {
			self.collectedIndex <- ( map["collectedIndex"] )
			self.creatorUID <- ( map["creatorUID"] )
			self.summary <- ( map["summary"] )
			self.ephemeral <- ( map["ephemeral"] )
			self.distributed <- ( map["distributed"] )
			self.version <- ( map["version"] )
            if map.mappingType == .toJSON {
                // Define if necessary the UID
                self.defineUID()
            }
            self._typeName <- map[Default.TYPE_NAME_KEY]
            self._id <- map[Default.UID_KEY]
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {super.init()
        self.silentGroupedChanges {
			self.collectedIndex=decoder.decodeInteger(forKey:"collectedIndex") 
			self.creatorUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "creatorUID")! as NSString)
			self.summary=String(describing: decoder.decodeObject(of: NSString.self, forKey:"summary") as NSString?)
			self.ephemeral=decoder.decodeBool(forKey:"ephemeral") 
			self.distributed=decoder.decodeBool(forKey:"distributed") 
			self.version=decoder.decodeInteger(forKey:"version") 
            self._typeName=type(of: self).typeName()
            self._id=String(describing: decoder.decodeObject(of: NSString.self, forKey: "_id")! as NSString)
        }
    }

     open func encode(with coder: NSCoder) {
		coder.encode(self.collectedIndex,forKey:"collectedIndex")
		coder.encode(self.creatorUID,forKey:"creatorUID")
		if let summary = self.summary {
			coder.encode(summary,forKey:"summary")
		}
		coder.encode(self.ephemeral,forKey:"ephemeral")
		coder.encode(self.distributed,forKey:"distributed")
		coder.encode(self.version,forKey:"version")
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

    // MARK: Identifiable

     open class var collectionName:String{
        return "bartlebyObjects"
    }

     open var d_collectionName:String{
        return BartlebyObject.collectionName
    }

}
