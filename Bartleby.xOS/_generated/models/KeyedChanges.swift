//
//  KeyedChanges.swift
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

// MARK: Bartleby's Core: used to keep track of changes in memory when inspecting an App (Value Object)
@objc open class KeyedChanges : UnManagedModel {

    // DeclaredTypeName support
    override open class func typeName() -> String {
        return "KeyedChanges"
    }


	//the elapsed time since the app has been launched
	@objc dynamic open var elapsed:Double = Bartleby.elapsedTime

	//the key
	@objc dynamic open var key:String = Default.NO_KEY

	//A description of the changes that have occured
	@objc dynamic open var changes:String = Default.NO_MESSAGE


    // MARK: - Codable


    public enum KeyedChangesCodingKeys: String,CodingKey{
		case elapsed
		case key
		case changes
    }

    required public init(from decoder: Decoder) throws{
		try super.init(from: decoder)
        try self.quietThrowingChanges {
			let values = try decoder.container(keyedBy: KeyedChangesCodingKeys.self)
			self.elapsed = try values.decode(Double.self,forKey:.elapsed)
			self.key = try values.decode(String.self,forKey:.key)
			self.changes = try values.decode(String.self,forKey:.changes)
        }
    }

    override open func encode(to encoder: Encoder) throws {
		try super.encode(to:encoder)
		var container = encoder.container(keyedBy: KeyedChangesCodingKeys.self)
		try container.encode(self.elapsed,forKey:.elapsed)
		try container.encode(self.key,forKey:.key)
		try container.encode(self.changes,forKey:.changes)
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override  open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["elapsed","key","changes"])
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
            case "elapsed":
                if let casted=value as? Double{
                    self.elapsed=casted
                }
            case "key":
                if let casted=value as? String{
                    self.key=casted
                }
            case "changes":
                if let casted=value as? String{
                    self.changes=casted
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
            case "elapsed":
               return self.elapsed
            case "key":
               return self.key
            case "changes":
               return self.changes
            default:
                return try super.getExposedValueForKey(key)
        }
    }
    // MARK: - Initializable
     required public init() {
        super.init()
    }
}