//
//  Completion.swift
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

// MARK: Bartleby's Commons: A completion state
@objc(Completion) open class Completion : BartlebyObject{

    // Universal type support
    override open class func typeName() -> String {
        return "Completion"
    }

	//Success if set to true
	dynamic open var success:Bool = true  {
	    didSet { 
	       if !self.wantsQuietChanges && success != oldValue {
	            self.provisionChanges(forKey: "success",oldValue: oldValue,newValue: success)  
	       } 
	    }
	}

	//The status
	dynamic open var statusCode:Int = StatusOfCompletion.undefined.rawValue  {
	    didSet { 
	       if !self.wantsQuietChanges && statusCode != oldValue {
	            self.provisionChanges(forKey: "statusCode",oldValue: oldValue,newValue: statusCode)  
	       } 
	    }
	}

	//The Message
	dynamic open var message:String = ""{
	    didSet { 
	       if !self.wantsQuietChanges && message != oldValue {
	            self.provisionChanges(forKey: "message",oldValue: oldValue,newValue: message) 
	       } 
	    }
	}

	//completion data
	dynamic open var data:Data? {
	    didSet { 
	       if !self.wantsQuietChanges && data != oldValue {
	            self.provisionChanges(forKey: "data",oldValue: oldValue,newValue: data) 
	       } 
	    }
	}

	//A category to discriminate bunch of completion states
	dynamic open var category:String = ""

	//An external identifier
	dynamic open var externalIdentifier:String = ""

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["success","statusCode","message","data","category","externalIdentifier"])
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
            case "success":
                if let casted=value as? Bool{
                    self.success=casted
                }
            case "statusCode":
                if let casted=value as? Int{
                    self.statusCode=casted
                }
            case "message":
                if let casted=value as? String{
                    self.message=casted
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
    override open func getExposedValueForKey(_ key:String) throws -> Any?{
        switch key {
            case "success":
               return self.success
            case "statusCode":
               return self.statusCode
            case "message":
               return self.message
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
        self.quietChanges {
			self.success <- ( map["success"] )
			self.statusCode <- ( map["statusCode"] )
			self.message <- ( map["message"] )
			self.data <- ( map["data"], DataTransform() )
			self.category <- ( map["category"] )
			self.externalIdentifier <- ( map["externalIdentifier"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.quietChanges {
			self.success=decoder.decodeBool(forKey:"success") 
			self.statusCode=decoder.decodeInteger(forKey:"statusCode") 
			self.message=String(describing: decoder.decodeObject(of: NSString.self, forKey: "message")! as NSString)
			self.data=decoder.decodeObject(of: NSData.self, forKey:"data") as Data?
			self.category=String(describing: decoder.decodeObject(of: NSString.self, forKey: "category")! as NSString)
			self.externalIdentifier=String(describing: decoder.decodeObject(of: NSString.self, forKey: "externalIdentifier")! as NSString)
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self.success,forKey:"success")
		coder.encode(self.statusCode,forKey:"statusCode")
		coder.encode(self.message,forKey:"message")
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

    override open class var collectionName:String{
        return "completions"
    }

    override open var d_collectionName:String{
        return Completion.collectionName
    }
}