//
//  ExternalReference.swift
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

// MARK: Bartleby's Core: an ExternalReference stores all the necessary data to find a unique resource.
@objc(ExternalReference) public class ExternalReference : JObject{

    // Universal type support
    override public class func typeName() -> String {
        return "ExternalReference"
    }

	//The UID of the referred instance
	public var iUID:String = "\(Default.NO_UID)"{	 
	    willSet { 
	       if iUID != newValue {
	            self.commitRequired() 
	       } 
	    }
	}

	//The typeName of the referred instance
	public var iTypeName:String = "\(Default.NO_UID)"{	 
	    willSet { 
	       if iTypeName != newValue {
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
		self.iUID <- ( map["iUID"] )
		self.iTypeName <- ( map["iTypeName"] )
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
		self.iUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "iUID")! as NSString)
		self.iTypeName=String(decoder.decodeObjectOfClass(NSString.self, forKey: "iTypeName")! as NSString)

    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		coder.encodeObject(self.iUID,forKey:"iUID")
		coder.encodeObject(self.iTypeName,forKey:"iTypeName")
    }


    override public class func supportsSecureCoding() -> Bool{
        return true
    }


    required public init() {
        super.init()
    }

    // MARK: Identifiable

    override public class var collectionName:String{
        return "externalReferences"
    }

    override public var d_collectionName:String{
        return ExternalReference.collectionName
    }


}

