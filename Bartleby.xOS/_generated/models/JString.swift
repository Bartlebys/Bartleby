//
//  JString.swift
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

// MARK: Bartleby's Core: String Primitive Wrapper.
@objc(JString) open class JString : BartlebyObject{

    // Universal type support
    override open class func typeName() -> String {
        return "JString"
    }

	//the embedded String
	dynamic open var string:String? {
	 
	    didSet { 
	       if string != oldValue {
	            self.provisionChanges(forKey: "string",oldValue: oldValue,newValue: string) 
	       } 
	    }
	}

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["string"])
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
            case "string":
                if let casted=value as? String{
                    self.string=casted
                }
            default:
                throw ObjectExpositionError.UnknownKey(key: key)
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
            case "string":
               return self.string
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
			self.string <- ( map["string"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {super.init(coder: decoder)
        self.silentGroupedChanges {
			self.string=String(describing: decoder.decodeObject(of: NSString.self, forKey:"string") as NSString?)
        }
    }

    override open func encode(with coder: NSCoder) {super.encode(with:coder)
		if let string = self.string {
			coder.encode(string,forKey:"string")
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
        return "jStrings"
    }

    override open var d_collectionName:String{
        return JString.collectionName
    }

}
