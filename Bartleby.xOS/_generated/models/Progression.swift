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
#endif

// MARK: Bartleby's Commons: A progression state
@objc(Progression) open class Progression : UnManagedModel {

    // DeclaredTypeName support
    override open class func typeName() -> String {
        return "Progression"
    }


	//The start time of the progression state
	open var startTime:Double?

	//Index of the task
	@objc dynamic open var currentTaskIndex:Int = 0

	//Total number of tasks
	@objc dynamic open var totalTaskCount:Int = 0

	//0 to 100
	@objc dynamic open var currentPercentProgress:Double = 0

	//The Message
	@objc dynamic open var message:String = ""

	//The consolidated information (may include the message)
	@objc dynamic open var informations:String = ""

	//The associated data
	@objc dynamic open var data:Data?

	//A category to discriminate bunch of progression states
	@objc dynamic open var category:String = ""

	//An external identifier
	@objc dynamic open var externalIdentifier:String = ""


    // MARK: - Codable


    enum ProgressionCodingKeys: String,CodingKey{
		case startTime
		case currentTaskIndex
		case totalTaskCount
		case currentPercentProgress
		case message
		case informations
		case data
		case category
		case externalIdentifier
    }

    required public init(from decoder: Decoder) throws{
		try super.init(from: decoder)
        try self.quietThrowingChanges {
			let values = try decoder.container(keyedBy: ProgressionCodingKeys.self)
			self.startTime = try values.decodeIfPresent(Double.self,forKey:.startTime)
			self.currentTaskIndex = try values.decode(Int.self,forKey:.currentTaskIndex)
			self.totalTaskCount = try values.decode(Int.self,forKey:.totalTaskCount)
			self.currentPercentProgress = try values.decode(Double.self,forKey:.currentPercentProgress)
			self.message = try values.decode(String.self,forKey:.message)
			self.informations = try values.decode(String.self,forKey:.informations)
			self.data = try values.decodeIfPresent(Data.self,forKey:.data)
			self.category = try values.decode(String.self,forKey:.category)
			self.externalIdentifier = try values.decode(String.self,forKey:.externalIdentifier)
        }
    }

    override open func encode(to encoder: Encoder) throws {
		try super.encode(to:encoder)
		var container = encoder.container(keyedBy: ProgressionCodingKeys.self)
		try container.encodeIfPresent(self.startTime,forKey:.startTime)
		try container.encode(self.currentTaskIndex,forKey:.currentTaskIndex)
		try container.encode(self.totalTaskCount,forKey:.totalTaskCount)
		try container.encode(self.currentPercentProgress,forKey:.currentPercentProgress)
		try container.encode(self.message,forKey:.message)
		try container.encode(self.informations,forKey:.informations)
		try container.encodeIfPresent(self.data,forKey:.data)
		try container.encode(self.category,forKey:.category)
		try container.encode(self.externalIdentifier,forKey:.externalIdentifier)
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override  open var exposedKeys:[String] {
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
    override  open func setExposedValue(_ value:Any?, forKey key: String) throws {
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
    // MARK: - Initializable
     required public init() {
        super.init()
    }
}