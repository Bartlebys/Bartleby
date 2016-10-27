//
//  Metrics.swift
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

// MARK: Bartleby's Core: an object used to record metrics
@objc(Metrics) open class Metrics : BartlebyObject{

    // Universal type support
    override open class func typeName() -> String {
        return "Metrics"
    }

	//The action name e.g: UpdateUser
	dynamic open var operationName:String = "\(Default.NO_NAME)"

	//The metrics entry counter
	dynamic open var counter:Int = -1

	//The elasped time since app started up.
	dynamic open var elapsed:Double = 0

	//The time interval in seconds from the time the request started to the initial response from the server.
	dynamic open var latency:Double = 0

	//The time interval in seconds from the time the request started to the time the request completed.
	dynamic open var requestDuration:Double = 0

	// The time interval in seconds from the time the request completed to the time response serialization completed.
	dynamic open var serializationDuration:Double = 0

	//The time interval in seconds from the time the request started to the time response serialization completed.
	dynamic open var totalDuration:Double = 0

	//The full http context
	dynamic open var httpContext:HTTPContext?

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["operationName","counter","elapsed","latency","requestDuration","serializationDuration","totalDuration","httpContext"])
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
            case "operationName":
                if let casted=value as? String{
                    self.operationName=casted
                }
            case "counter":
                if let casted=value as? Int{
                    self.counter=casted
                }
            case "elapsed":
                if let casted=value as? Double{
                    self.elapsed=casted
                }
            case "latency":
                if let casted=value as? Double{
                    self.latency=casted
                }
            case "requestDuration":
                if let casted=value as? Double{
                    self.requestDuration=casted
                }
            case "serializationDuration":
                if let casted=value as? Double{
                    self.serializationDuration=casted
                }
            case "totalDuration":
                if let casted=value as? Double{
                    self.totalDuration=casted
                }
            case "httpContext":
                if let casted=value as? HTTPContext{
                    self.httpContext=casted
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
            case "operationName":
               return self.operationName
            case "counter":
               return self.counter
            case "elapsed":
               return self.elapsed
            case "latency":
               return self.latency
            case "requestDuration":
               return self.requestDuration
            case "serializationDuration":
               return self.serializationDuration
            case "totalDuration":
               return self.totalDuration
            case "httpContext":
               return self.httpContext
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
			self.operationName <- ( map["operationName"] )
			self.counter <- ( map["counter"] )
			self.elapsed <- ( map["elapsed"] )
			self.latency <- ( map["latency"] )
			self.requestDuration <- ( map["requestDuration"] )
			self.serializationDuration <- ( map["serializationDuration"] )
			self.totalDuration <- ( map["totalDuration"] )
			self.httpContext <- ( map["httpContext"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self.operationName=String(describing: decoder.decodeObject(of: NSString.self, forKey: "operationName")! as NSString)
			self.counter=decoder.decodeInteger(forKey:"counter") 
			self.elapsed=decoder.decodeDouble(forKey:"elapsed") 
			self.latency=decoder.decodeDouble(forKey:"latency") 
			self.requestDuration=decoder.decodeDouble(forKey:"requestDuration") 
			self.serializationDuration=decoder.decodeDouble(forKey:"serializationDuration") 
			self.totalDuration=decoder.decodeDouble(forKey:"totalDuration") 
			self.httpContext=decoder.decodeObject(of:HTTPContext.self, forKey: "httpContext") 
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self.operationName,forKey:"operationName")
		coder.encode(self.counter,forKey:"counter")
		coder.encode(self.elapsed,forKey:"elapsed")
		coder.encode(self.latency,forKey:"latency")
		coder.encode(self.requestDuration,forKey:"requestDuration")
		coder.encode(self.serializationDuration,forKey:"serializationDuration")
		coder.encode(self.totalDuration,forKey:"totalDuration")
		if let httpContext = self.httpContext {
			coder.encode(httpContext,forKey:"httpContext")
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
        return "metrics"
    }

    override open var d_collectionName:String{
        return Metrics.collectionName
    }
}