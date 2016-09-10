//
//  JString.swift
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

// MARK: Bartleby's Core: String Primitive Wrapper.
@objc(JString) open class JString : JObject{

    // Universal type support
    override open class func typeName() -> String {
        return "JString"
    }

	//the embedded String
	dynamic open var string:String? {	 
	    didSet { 
	       if string != oldValue {
	            self.provisionChanges(forKey: "string",oldValue: oldValue as AnyObject?,newValue: string as AnyObject?) 
	       } 
	    }
	}



    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override open func mapping(_ map: Map) {
        super.mapping(map)
        self.disableSupervisionAndCommit()
		self.string <- ( map["string"] )
        self.enableSuperVisionAndCommit()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.disableSupervisionAndCommit()
		self.string=String(describing: decoder.decodeObject(of: NSString.self, forKey:"string") as NSString?)

        self.enableSuperVisionAndCommit()
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with: coder)
		if let string = self.string {
			coder.encode(string,forKey:"string")
		}
    }


    override open class func supportsSecureCoding() -> Bool{
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

