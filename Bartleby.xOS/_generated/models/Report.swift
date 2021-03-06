//
//  Report.swift
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

// MARK: Bartleby's Core: a Report object that can be used for analytics and support purposes
@objc open class Report : ManagedModel{

    // Universal type support
    override open class func typeName() -> String {
        return "Report"
    }

	//The document Metadata (contains highly sensitive data)
	@objc dynamic open var metadata:DocumentMetadata?

	//A collection logs
	@objc dynamic open var logs:[LogEntry] = [LogEntry]()

	//A collection metrics
	@objc dynamic open var metrics:[Metrics] = [Metrics]()


    // MARK: - Codable


    public enum ReportCodingKeys: String,CodingKey{
		case metadata
		case logs
		case metrics
    }

    required public init(from decoder: Decoder) throws{
		try super.init(from: decoder)
        try self.quietThrowingChanges {
			let values = try decoder.container(keyedBy: ReportCodingKeys.self)
			self.metadata = try values.decodeIfPresent(DocumentMetadata.self,forKey:.metadata)
			self.logs = try values.decode([LogEntry].self,forKey:.logs)
			self.metrics = try values.decode([Metrics].self,forKey:.metrics)
        }
    }

    override open func encode(to encoder: Encoder) throws {
		try super.encode(to:encoder)
		var container = encoder.container(keyedBy: ReportCodingKeys.self)
		try container.encodeIfPresent(self.metadata,forKey:.metadata)
		try container.encode(self.logs,forKey:.logs)
		try container.encode(self.metrics,forKey:.metrics)
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override  open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["metadata","logs","metrics"])
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
            case "metadata":
                if let casted=value as? DocumentMetadata{
                    self.metadata=casted
                }
            case "logs":
                if let casted=value as? [LogEntry]{
                    self.logs=casted
                }
            case "metrics":
                if let casted=value as? [Metrics]{
                    self.metrics=casted
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
            case "metadata":
               return self.metadata
            case "logs":
               return self.logs
            case "metrics":
               return self.metrics
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
        return "reports"
    }

    override  open var d_collectionName:String{
        return Report.collectionName
    }
}