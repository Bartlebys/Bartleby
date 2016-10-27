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
	import ObjectMapper
#endif

// MARK: Bartleby's Core: an object that encapsulate the whole http context , request, response
@objc(HTTPContext) open class HTTPContext : BartlebyObject, CollectibleHTTPContext{

    // Universal type support
    override open class func typeName() -> String {
        return "HTTPContext"
    }

	//A descriptive string for developper to identify the calling context
	dynamic open var caller:String = "\(Default.NO_NAME)"

	//A developer set code to provide filtering
	dynamic open var code:Int = Int.max

	//A developer set code to provide filtering
	dynamic open var httpStatusCode:Int = Int.max

	//The related url
	dynamic open var relatedURL:URL?

	//The response
	dynamic open var response:Any?

	//The result
	dynamic open var result:Any?

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["caller","code","httpStatusCode","relatedURL","response","result"])
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
            case "response":
                if let casted=value as? Any{
                    self.response=casted
                }
            case "result":
                if let casted=value as? Any{
                    self.result=casted
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
            case "caller":
               return self.caller
            case "code":
               return self.code
            case "httpStatusCode":
               return self.httpStatusCode
            case "relatedURL":
               return self.relatedURL
            case "response":
               return self.response
            case "result":
               return self.result
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
			self.caller <- ( map["caller"] )
			self.code <- ( map["code"] )
			self.httpStatusCode <- ( map["httpStatusCode"] )
			self.relatedURL <- ( map["relatedURL"], URLTransform() )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self.caller=String(describing: decoder.decodeObject(of: NSString.self, forKey: "caller")! as NSString)
			self.code=decoder.decodeInteger(forKey:"code") 
			self.httpStatusCode=decoder.decodeInteger(forKey:"httpStatusCode") 
			self.relatedURL=decoder.decodeObject(of: NSURL.self, forKey:"relatedURL") as URL?
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self.caller,forKey:"caller")
		coder.encode(self.code,forKey:"code")
		coder.encode(self.httpStatusCode,forKey:"httpStatusCode")
		if let relatedURL = self.relatedURL {
			coder.encode(relatedURL,forKey:"relatedURL")
		}
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

     required public init() {
        super.init()
    }

    // MARK: Identifiable

    override open class var collectionName:String{
        return "hTTPContexts"
    }

    override open var d_collectionName:String{
        return HTTPContext.collectionName
    }
}