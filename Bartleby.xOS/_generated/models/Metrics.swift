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
#endif

// MARK: Bartleby's Core: a value object used to record metrics
@objc open class Metrics : UnManagedModel {

    // DeclaredTypeName support
    override open class func typeName() -> String {
        return "Metrics"
    }


	//The referent document
	@objc dynamic open var referentDocument:BartlebyDocument?

	//The action name e.g: UpdateUser
	@objc dynamic open var operationName:String = Default.NO_NAME

	//The metrics entry counter
	@objc dynamic open var counter:Int = -1

	//The elasped time since app started up.
	@objc dynamic open var elapsed:Double = 0

	//The time interval in seconds from the time the request started to the initial response from the server.
	@objc dynamic open var latency:Double = 0

	//The time interval in seconds from the time the request started to the time the request completed.
	@objc dynamic open var requestDuration:Double = 0

	// The time interval in seconds from the time the request completed to the time response serialization completed.
	@objc dynamic open var serializationDuration:Double = 0

	//The time interval in seconds from the time the request started to the time response serialization completed.
	@objc dynamic open var totalDuration:Double = 0

	//The full http context
	@objc dynamic open var httpContext:HTTPContext?

	//the verification method
	public enum StreamOrientation:String{
		case upStream = "upStream"
		case downStream = "downStream"
	}
	open var streamOrientation:StreamOrientation = .upStream


    // MARK: - Codable


    public enum MetricsCodingKeys: String,CodingKey{
		case referentDocument
		case operationName
		case counter
		case elapsed
		case latency
		case requestDuration
		case serializationDuration
		case totalDuration
		case httpContext
		case streamOrientation
    }

    required public init(from decoder: Decoder) throws{
		try super.init(from: decoder)
        try self.quietThrowingChanges {
			let values = try decoder.container(keyedBy: MetricsCodingKeys.self)
			self.operationName = try values.decode(String.self,forKey:.operationName)
			self.counter = try values.decode(Int.self,forKey:.counter)
			self.elapsed = try values.decode(Double.self,forKey:.elapsed)
			self.latency = try values.decode(Double.self,forKey:.latency)
			self.requestDuration = try values.decode(Double.self,forKey:.requestDuration)
			self.serializationDuration = try values.decode(Double.self,forKey:.serializationDuration)
			self.totalDuration = try values.decode(Double.self,forKey:.totalDuration)
			self.httpContext = try values.decodeIfPresent(HTTPContext.self,forKey:.httpContext)
			self.streamOrientation = Metrics.StreamOrientation(rawValue: try values.decode(String.self,forKey:.streamOrientation)) ?? .upStream
        }
    }

    override open func encode(to encoder: Encoder) throws {
		try super.encode(to:encoder)
		var container = encoder.container(keyedBy: MetricsCodingKeys.self)
		try container.encode(self.operationName,forKey:.operationName)
		try container.encode(self.counter,forKey:.counter)
		try container.encode(self.elapsed,forKey:.elapsed)
		try container.encode(self.latency,forKey:.latency)
		try container.encode(self.requestDuration,forKey:.requestDuration)
		try container.encode(self.serializationDuration,forKey:.serializationDuration)
		try container.encode(self.totalDuration,forKey:.totalDuration)
		try container.encodeIfPresent(self.httpContext,forKey:.httpContext)
		try container.encode(self.streamOrientation.rawValue ,forKey:.streamOrientation)
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override  open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["referentDocument","operationName","counter","elapsed","latency","requestDuration","serializationDuration","totalDuration","httpContext","streamOrientation"])
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
            case "referentDocument":
                if let casted=value as? BartlebyDocument{
                    self.referentDocument=casted
                }
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
            case "streamOrientation":
                if let casted=value as? Metrics.StreamOrientation{
                    self.streamOrientation=casted
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
            case "referentDocument":
               return self.referentDocument
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
            case "streamOrientation":
               return self.streamOrientation
            default:
                return try super.getExposedValueForKey(key)
        }
    }
    // MARK: - Initializable
     required public init() {
        super.init()
    }
}