//
//  HTTPRequest.swift
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

// MARK: Bartleby's Core: an object that encapsulate the URL Request information
@objc open class HTTPRequest : UnManagedModel {

    // DeclaredTypeName support
    override open class func typeName() -> String {
        return "HTTPRequest"
    }


	//The url
	@objc dynamic open var url:URL?

	//The HTTP method
	@objc dynamic open var httpMethod:String = "GET"

	//The Headers
	@objc dynamic open var headers:[String:String]?

	//This data is sent as the message body of the request
	@objc dynamic open var httpBody:Data?

	//The timeout
	@objc dynamic open var timeout:Double = 10


    // MARK: - Codable


    public enum HTTPRequestCodingKeys: String,CodingKey{
		case url
		case httpMethod
		case headers
		case httpBody
		case timeout
    }

    required public init(from decoder: Decoder) throws{
		try super.init(from: decoder)
        try self.quietThrowingChanges {
			let values = try decoder.container(keyedBy: HTTPRequestCodingKeys.self)
			self.url = try values.decodeIfPresent(URL.self,forKey:.url)
			self.httpMethod = try values.decode(String.self,forKey:.httpMethod)
			self.headers = try values.decodeIfPresent([String:String].self,forKey:.headers)
			self.httpBody = try values.decodeIfPresent(Data.self,forKey:.httpBody)
			self.timeout = try values.decode(Double.self,forKey:.timeout)
        }
    }

    override open func encode(to encoder: Encoder) throws {
		try super.encode(to:encoder)
		var container = encoder.container(keyedBy: HTTPRequestCodingKeys.self)
		try container.encodeIfPresent(self.url,forKey:.url)
		try container.encode(self.httpMethod,forKey:.httpMethod)
		try container.encodeIfPresent(self.headers,forKey:.headers)
		try container.encodeIfPresent(self.httpBody,forKey:.httpBody)
		try container.encode(self.timeout,forKey:.timeout)
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override  open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["url","httpMethod","headers","httpBody","timeout"])
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
            case "url":
                if let casted=value as? URL{
                    self.url=casted
                }
            case "httpMethod":
                if let casted=value as? String{
                    self.httpMethod=casted
                }
            case "headers":
                if let casted=value as? [String:String]{
                    self.headers=casted
                }
            case "httpBody":
                if let casted=value as? Data{
                    self.httpBody=casted
                }
            case "timeout":
                if let casted=value as? Double{
                    self.timeout=casted
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
            case "url":
               return self.url
            case "httpMethod":
               return self.httpMethod
            case "headers":
               return self.headers
            case "httpBody":
               return self.httpBody
            case "timeout":
               return self.timeout
            default:
                return try super.getExposedValueForKey(key)
        }
    }
    // MARK: - Initializable
     required public init() {
        super.init()
    }
}