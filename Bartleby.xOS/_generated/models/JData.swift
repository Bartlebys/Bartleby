//
//  JData.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for b@bartlebys.org
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  Bartleby's | https://bartlebys.org  All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
import Alamofire
import ObjectMapper
#endif

// MARK: Bartleby's Core: Data Primitive Wrapper.
@objc(JData) public class JData : JObject{

    // Universal type support
    override public class func typeName() -> String {
        return "JData"
    }

	//the data
	dynamic public var data:NSData? {	 
	    didSet { 
	       if data != oldValue {
	            self.provisionChanges(forKey: "data",oldValue: oldValue,newValue: data) 
	       } 
	    }
	}



    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
        self.disableSupervisionAndCommit()
		self.data <- ( map["data"], Base64DataTransform() )
        self.enableSuperVisionAndCommit()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.disableSupervisionAndCommit()
		self.data=decoder.decodeObjectOfClass(NSData.self, forKey:"data") as NSData?

        self.enableSuperVisionAndCommit()
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

