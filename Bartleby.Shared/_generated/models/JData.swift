//
//  JData.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for benoit@pereira-da-silva.com
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
// WE TRY TO GENERATE ANY REPETITIVE CODE AND TO IMPROVE THE QUALITY ITERATIVELY
//
// Copyright (c) 2015  Chaosmos | https://chaosmos.fr  All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
import Alamofire
import ObjectMapper
#endif

// MARK: Bartleby's Core: Data Primitive Wrapper. (Used for example to pass task Arguments)
@objc(JData) public class JData : JObject{

    // Universal type support
    override public class func typeName() -> String {
        return "JData"
    }

	//the data
	public var data:NSData? {	 
	    willSet { 
	       if data != newValue {
	            self.commitRequired() 
	       } 
	    }
	}



    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
		self.data <- (map["data"],Base64DataTransform())
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
		self.data=decoder.decodeObjectOfClass(NSData.self, forKey:"data") as NSData?

    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		if let data = self.data {
			coder.encodeObject(data,forKey:"data")
		}
    }


    override public class func supportsSecureCoding() -> Bool{
        return true
    }


    required public init() {
        super.init()
    }

    // MARK: Identifiable

    override public class var collectionName:String{
        return "jDatas"
    }

    override public var d_collectionName:String{
        return JData.collectionName
    }


}
