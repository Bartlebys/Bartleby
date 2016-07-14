//
//  Completion.swift
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

// MARK: Bartleby's Commons: A completion state
@objc(Completion) public class Completion : JObject{

    // Universal type support
    override public class func typeName() -> String {
        return "Completion"
    }

	//Success if set to true
	public var success:Bool = true  {	 
	    didSet { 
	       if success != oldValue {
	            self.provisionChanges(forKey: "success",oldValue: oldValue,newValue: success)  
	       } 
	    }
	}

	//The status
	public var statusCode:Int = StatusOfCompletion.Undefined.rawValue  {	 
	    didSet { 
	       if statusCode != oldValue {
	            self.provisionChanges(forKey: "statusCode",oldValue: oldValue,newValue: statusCode)  
	       } 
	    }
	}

	//The Message
	public var message:String = ""{	 
	    didSet { 
	       if message != oldValue {
	            self.provisionChanges(forKey: "message",oldValue: oldValue,newValue: message) 
	       } 
	    }
	}

	//completion data
	public var data:NSData? {	 
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
        self.lockAutoCommitObserver()
		self.success <- ( map["success"] )
		self.statusCode <- ( map["statusCode"] )
		self.message <- ( map["message"] )
		self.data <- ( map["data"], Base64DataTransform() )
        self.unlockAutoCommitObserver()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.lockAutoCommitObserver()
		self.success=decoder.decodeBoolForKey("success") 
		self.statusCode=decoder.decodeIntegerForKey("statusCode") 
		self.message=String(decoder.decodeObjectOfClass(NSString.self, forKey: "message")! as NSString)
		self.data=decoder.decodeObjectOfClass(NSData.self, forKey:"data") as NSData?
        self.unlockAutoCommitObserver()
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		coder.encodeBool(self.success,forKey:"success")
		coder.encodeInteger(self.statusCode,forKey:"statusCode")
		coder.encodeObject(self.message,forKey:"message")
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
        return "completions"
    }

    override public var d_collectionName:String{
        return Completion.collectionName
    }


}

