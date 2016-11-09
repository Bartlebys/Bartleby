//
//  JData.swift
//  Bsync
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for Benoit Pereira da Silva https://pereira-da-silva.com/contact
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  Bartleby's https://bartlebys.org   All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
	import Alamofire
	import ObjectMapper
	import BartlebyKit
#endif

// MARK: Bartleby's Core: Data Primitive Wrapper.
@objc(JData) open class JData : BartlebyObject{

    // Universal type support
    override open class func typeName() -> String {
        return "JData"
    }

	//the data
	dynamic open var data:Data? {
	    didSet { 
	       if data != oldValue {
	            self.provisionChanges(forKey: "data",oldValue: oldValue,newValue: data) 
	       } 
	    }
	}

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["data"])
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
            case "data":
                if let casted=value as? Data{
                    self.data=casted
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
            case "data":
               return self.data
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
			self.data <- ( map["data"], DataTransform() )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self.data=decoder.decodeObject(of: NSData.self, forKey:"data") as Data?
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		if let data = self.data {
			coder.encode(data,forKey:"data")
		}
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

     required public init() {
        super.init()
    }

    override open class var collectionName:String{
        return "jDatas"
    }

    override open var d_collectionName:String{
        return JData.collectionName
    }
}


// MARK: Shadow

open class JDataShadow :JData,Shadow{

    static func from(_ entity:JData)->JDataShadow{
        let shadow=JDataShadow()
            shadow.silentGroupedChanges {
            for k in entity.exposedKeys{
                try? shadow.setExposedValue(entity.getExposedValueForKey(k), forKey: k)
            }
            try? shadow.setShadowUID(UID: entity.UID)
        }
        return shadow
    }

    // MARK: Universal type support

    override open class func typeName() -> String {
        return "JDataShadow"
    }

    // MARK: Collectible

    override open class var collectionName:String{
        return "jDatasShadow"
    }

    override open var d_collectionName:String{
        return JDataShadow.collectionName
    }
}