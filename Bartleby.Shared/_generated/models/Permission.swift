//
//  Permission.swift
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

// MARK: Bartleby's Core: a dynamic permission (Bartleby's base ACL is static)
@objc(Permission) public class Permission : JObject{

    // Universal type support
    override public class func typeName() -> String {
        return "Permission"
    }

	//The call string e.g : DeleteOperation->call
	public var callString:String? {	 
	    willSet { 
	       if callString != newValue {
	            self.provisionChanges() 
	       } 
	    }
	}

	//The level of the permission (check Bartleby's doc)
	public var level:Int? {	 
	    willSet { 
	       if level != newValue {
	            self.provisionChanges() 
	       } 
	    }
	}

	public var rule:[String] = [String]()  {	 
	    willSet { 
	       if rule != newValue {
	            self.provisionChanges() 
	       } 
	    }
	}



    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
        self.lockAutoCommitObserver()
		self.callString <- ( map["callString"] )
		self.level <- ( map["level"] )
		self.rule <- ( map["rule"] )
        self.unlockAutoCommitObserver()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.lockAutoCommitObserver()
		self.callString=String(decoder.decodeObjectOfClass(NSString.self, forKey:"callString") as NSString?)
		self.level=decoder.decodeIntegerForKey("level") 
		self.rule=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),NSString.self]), forKey: "rule")! as! [String]
        self.unlockAutoCommitObserver()
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		if let callString = self.callString {
			coder.encodeObject(callString,forKey:"callString")
		}
		if let level = self.level {
			coder.encodeInteger(level,forKey:"level")
		}
		coder.encodeObject(self.rule,forKey:"rule")
    }


    override public class func supportsSecureCoding() -> Bool{
        return true
    }


    required public init() {
        super.init()
    }

    // MARK: Identifiable

    override public class var collectionName:String{
        return "permissions"
    }

    override public var d_collectionName:String{
        return Permission.collectionName
    }


}

