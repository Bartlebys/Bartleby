//
//  LocalizedDatum.swift
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

// MARK: An entity used to associate localized name and informations
@objc open class LocalizedDatum : ManagedModel{

    // Universal type support
    override open class func typeName() -> String {
        return "LocalizedDatum"
    }

	//the localized key
	@objc dynamic open var key:String = "" {
	    didSet { 
	       if !self.wantsQuietChanges && key != oldValue {
	            self.provisionChanges(forKey: "key",oldValue: oldValue,newValue: key) 
	       } 
	    }
	}

	//The localized string value
	@objc dynamic open var stringValue:String? {
	    didSet { 
	       if !self.wantsQuietChanges && stringValue != oldValue {
	            self.provisionChanges(forKey: "stringValue",oldValue: oldValue,newValue: stringValue) 
	       } 
	    }
	}

	//The localized data value
	@objc dynamic open var dataValue:Data? {
	    didSet { 
	       if !self.wantsQuietChanges && dataValue != oldValue {
	            self.provisionChanges(forKey: "dataValue",oldValue: oldValue,newValue: dataValue) 
	       } 
	    }
	}


    // MARK: - Codable


    fileprivate enum CodingKeys: String,CodingKey{
		case key
		case stringValue
		case dataValue
    }

    required public init(from decoder: Decoder) throws{
		try super.init(from: decoder)
        try self.quietThrowingChanges {
			let values = try decoder.container(keyedBy: CodingKeys.self)
			self.key = try values.decode(String.self,forKey:.key)
			self.stringValue = try values.decodeIfPresent(String.self,forKey:.stringValue)
			self.dataValue = try values.decodeIfPresent(Data.self,forKey:.dataValue)
        }
    }

    override open func encode(to encoder: Encoder) throws {
		try super.encode(to:encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.key,forKey:.key)
		try container.encodeIfPresent(self.stringValue,forKey:.stringValue)
		try container.encodeIfPresent(self.dataValue,forKey:.dataValue)
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override  open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["key","stringValue","dataValue"])
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
            case "key":
                if let casted=value as? String{
                    self.key=casted
                }
            case "stringValue":
                if let casted=value as? String{
                    self.stringValue=casted
                }
            case "dataValue":
                if let casted=value as? Data{
                    self.dataValue=casted
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
            case "key":
               return self.key
            case "stringValue":
               return self.stringValue
            case "dataValue":
               return self.dataValue
            default:
                return try super.getExposedValueForKey(key)
        }
    }
    // MARK: - Initializable
    required public init() {
        super.init()
    }

    // MARK: - UniversalType
    override  open class var collectionName:String{
        return "localizedData"
    }

    override  open var d_collectionName:String{
        return LocalizedDatum.collectionName
    }
}