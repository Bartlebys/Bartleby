//
//  HTTPContext.swift
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

// MARK: Bartleby's Core: an object that encapsulate the whole http context , request, response
@objc(HTTPContext) open class HTTPContext : UnManagedModel, Consignable {


	//A descriptive string for developer to identify the calling context
	@objc dynamic open var caller:String = "\(Default.NO_NAME)"

	// A developer set code to provide filtering
	@objc dynamic open var code:Int = Default.MAX_INT

	//The responded HTTP status code
	@objc dynamic open var httpStatusCode:Int = Default.MAX_INT

	//The related url
	@objc dynamic open var relatedURL:URL?

	//The full http request
	@objc dynamic open var request:HTTPRequest?

	//The responded data stringifyed
	@objc dynamic open var responseString:String?

	//An optional message
	@objc dynamic open var message:String?


    // MARK: - Codable


    enum HTTPContextCodingKeys: String,CodingKey{
		case caller
		case code
		case httpStatusCode
		case relatedURL
		case request
		case responseString
		case message
    }

    required public init(from decoder: Decoder) throws{
		try super.init(from: decoder)
        try self.quietThrowingChanges {
			let values = try decoder.container(keyedBy: HTTPContextCodingKeys.self)
			self.caller = try values.decode(String.self,forKey:.caller)
			self.code = try values.decode(Int.self,forKey:.code)
			self.httpStatusCode = try values.decode(Int.self,forKey:.httpStatusCode)
			self.relatedURL = try values.decode(URL.self,forKey:.relatedURL)
			self.request = try values.decode(HTTPRequest.self,forKey:.request)
			self.responseString = try values.decode(String.self,forKey:.responseString)
			self.message = try values.decode(String.self,forKey:.message)
        }
    }

    override open func encode(to encoder: Encoder) throws {
		try super.encode(to:encoder)
		var container = encoder.container(keyedBy: HTTPContextCodingKeys.self)
		try container.encodeIfPresent(self.caller,forKey:.caller)
		try container.encodeIfPresent(self.code,forKey:.code)
		try container.encodeIfPresent(self.httpStatusCode,forKey:.httpStatusCode)
		try container.encodeIfPresent(self.relatedURL,forKey:.relatedURL)
		try container.encodeIfPresent(self.request,forKey:.request)
		try container.encodeIfPresent(self.responseString,forKey:.responseString)
		try container.encodeIfPresent(self.message,forKey:.message)
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override  open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["caller","code","httpStatusCode","relatedURL","request","responseString","message"])
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
            case "caller":
                if let casted=value as? String{
                    self.caller=casted
                }
            case "code":
                if let casted=value as? Int{
                    self.code=casted
                }
            case "httpStatusCode":
                if let casted=value as? Int{
                    self.httpStatusCode=casted
                }
            case "relatedURL":
                if let casted=value as? URL{
                    self.relatedURL=casted
                }
            case "request":
                if let casted=value as? HTTPRequest{
                    self.request=casted
                }
            case "responseString":
                if let casted=value as? String{
                    self.responseString=casted
                }
            case "message":
                if let casted=value as? String{
                    self.message=casted
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
            case "caller":
               return self.caller
            case "code":
               return self.code
            case "httpStatusCode":
               return self.httpStatusCode
            case "relatedURL":
               return self.relatedURL
            case "request":
               return self.request
            case "responseString":
               return self.responseString
            case "message":
               return self.message
            default:
                return try super.getExposedValueForKey(key)
        }
    }
    // MARK: - Initializable
     required public init() {
        super.init()
    }
}