//
//  Progression.swift
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

// MARK: Bartleby's Commons: A progression state
@objc(Progression) open class Progression : BartlebyObject{

    // Universal type support
    override open class func typeName() -> String {
        return "Progression"
    }

	//The start time of the progression state
	open var startTime:Double?

	//Index of the task
	dynamic open var currentTaskIndex:Int = 0  {
	 
	    didSet { 
	       if currentTaskIndex != oldValue {
	            self.provisionChanges(forKey: "currentTaskIndex",oldValue: oldValue,newValue: currentTaskIndex)  
	       } 
	    }
	}

	//Total number of tasks
	dynamic open var totalTaskCount:Int = 0  {
	 
	    didSet { 
	       if totalTaskCount != oldValue {
	            self.provisionChanges(forKey: "totalTaskCount",oldValue: oldValue,newValue: totalTaskCount)  
	       } 
	    }
	}

	//0 to 100
	dynamic open var currentPercentProgress:Double = 0  {
	 
	    didSet { 
	       if currentPercentProgress != oldValue {
	            self.provisionChanges(forKey: "currentPercentProgress",oldValue: oldValue,newValue: currentPercentProgress)  
	       } 
	    }
	}

	//The Message
	dynamic open var message:String = ""{
	 
	    didSet { 
	       if message != oldValue {
	            self.provisionChanges(forKey: "message",oldValue: oldValue,newValue: message) 
	       } 
	    }
	}

	//The consolidated information (may include the message)
	dynamic open var informations:String = ""{
	 
	    didSet { 
	       if informations != oldValue {
	            self.provisionChanges(forKey: "informations",oldValue: oldValue,newValue: informations) 
	       } 
	    }
	}

	//The associated data
	dynamic open var data:Data? {
	 
	    didSet { 
	       if data != oldValue {
	            self.provisionChanges(forKey: "data",oldValue: oldValue,newValue: data) 
	       } 
	    }
	}

	//A category to discriminate bunch of progression states
	dynamic open var category:String = ""

	//An external identifier
	dynamic open var externalIdentifier:String = ""

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["startTime","currentTaskIndex","totalTaskCount","currentPercentProgress","message","informations","data","category","externalIdentifier"])
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
            case "startTime":
                if let casted=value as? Double{
                    self.startTime=casted
                }
            case "currentTaskIndex":
                if let casted=value as? Int{
                    self.currentTaskIndex=casted
                }
            case "totalTaskCount":
                if let casted=value as? Int{
                    self.totalTaskCount=casted
                }
            case "currentPercentProgress":
                if let casted=value as? Double{
                    self.currentPercentProgress=casted
                }
            case "message":
                if let casted=value as? String{
                    self.message=casted
                }
            case "informations":
                if let casted=value as? String{
                    self.informations=casted
                }
            case "data":
                if let casted=value as? Data{
                    self.data=casted
                }
            case "category":
                if let casted=value as? String{
                    self.category=casted
                }
            case "externalIdentifier":
                if let casted=value as? String{
                    self.externalIdentifier=casted
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
    override open func getExposedValueForKey(_ key:String) throws -> Any?{
        switch key {
            case "startTime":
               return self.startTime
            case "currentTaskIndex":
               return self.currentTaskIndex
            case "totalTaskCount":
               return self.totalTaskCount
            case "currentPercentProgress":
               return self.currentPercentProgress
            case "message":
               return self.message
            case "informations":
               return self.informations
            case "data":
               return self.data
            case "category":
               return self.category
            case "externalIdentifier":
               return self.externalIdentifier
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
        self.silentGroupedChanges {
			self.startTime <- ( map["startTime"] )
			self.currentTaskIndex <- ( map["currentTaskIndex"] )
			self.totalTaskCount <- ( map["totalTaskCount"] )
			self.currentPercentProgress <- ( map["currentPercentProgress"] )
			self.message <- ( map["message"] )
			self.informations <- ( map["informations"] )
			self.data <- ( map["data"], DataTransform() )
			self.category <- ( map["category"] )
			self.externalIdentifier <- ( map["externalIdentifier"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {super.init(coder: decoder)
        self.silentGroupedChanges {
			self.startTime=decoder.decodeDouble(forKey:"startTime") 
			self.currentTaskIndex=decoder.decodeInteger(forKey:"currentTaskIndex") 
			self.totalTaskCount=decoder.decodeInteger(forKey:"totalTaskCount") 
			self.currentPercentProgress=decoder.decodeDouble(forKey:"currentPercentProgress") 
			self.message=String(describing: decoder.decodeObject(of: NSString.self, forKey: "message")! as NSString)
			self.informations=String(describing: decoder.decodeObject(of: NSString.self, forKey: "informations")! as NSString)
			self.data=decoder.decodeObject(of: NSData.self, forKey:"data") as Data?
			self.category=String(describing: decoder.decodeObject(of: NSString.self, forKey: "category")! as NSString)
			self.externalIdentifier=String(describing: decoder.decodeObject(of: NSString.self, forKey: "externalIdentifier")! as NSString)
        }
    }

    override open func encode(with coder: NSCoder) {super.encode(with:coder)
		if let startTime = self.startTime {
			coder.encode(startTime,forKey:"startTime")
		}
		coder.encode(self.currentTaskIndex,forKey:"currentTaskIndex")
		coder.encode(self.totalTaskCount,forKey:"totalTaskCount")
		coder.encode(self.currentPercentProgress,forKey:"currentPercentProgress")
		coder.encode(self.message,forKey:"message")
		coder.encode(self.informations,forKey:"informations")
		if let data = self.data {
			coder.encode(data,forKey:"data")
		}
		coder.encode(self.category,forKey:"category")
		coder.encode(self.externalIdentifier,forKey:"externalIdentifier")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }


     required public init() {
        super.init()
    }

    // MARK: Identifiable

    override open class var collectionName:String{
        return "progressions"
    }

    override open var d_collectionName:String{
        return Progression.collectionName
    }

}
