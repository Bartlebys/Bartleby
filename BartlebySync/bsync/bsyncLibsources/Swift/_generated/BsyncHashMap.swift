//
//  BsyncHashMap.swift
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

// MARK: Swift Adapter to Objective C Hash Map
@objc(BsyncHashMap) open class BsyncHashMap : BartlebyObject{

    // Universal type support
    override open class func typeName() -> String {
        return "BsyncHashMap"
    }

	dynamic open var pathToHash:[String:Any] = [String:Any]()

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["pathToHash"])
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
            case "pathToHash":
                if let casted=value as? [String:Any]{
                    self.pathToHash=casted
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
            case "pathToHash":
               return self.pathToHash
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
			self.pathToHash <- ( map["pathToHash"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self.pathToHash=decoder.decodeObject(of: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()], forKey: "pathToHash")as! [String:Any]
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self.pathToHash,forKey:"pathToHash")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

     required public init() {
        super.init()
    }

    // MARK: Identifiable

    override open class var collectionName:String{
        return "bsyncHashMaps"
    }

    override open var d_collectionName:String{
        return BsyncHashMap.collectionName
    }
}


// The class shadow
open class BsyncHashMapShadow :BsyncHashMap,Shadow{

    static func from(_ entity:BsyncHashMap)->BsyncHashMapShadow{
        let shadow=BsyncHashMapShadow()
            shadow.silentGroupedChanges {
            for k in entity.exposedKeys{
                try? shadow.setExposedValue(entity.getExposedValueForKey(k), forKey: k)
            }
            try? shadow.setShadowUID(UID: entity.UID)
        }
        return shadow
    }
}