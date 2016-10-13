//
//  ExternalReference.swift
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

// MARK: Bartleby's Core: an ExternalReference stores all the necessary data to find a unique resource.
@objc(ExternalReference) open class ExternalReference : JObject{

    // Universal type support
    override open class func typeName() -> String {
        return "ExternalReference"
    }


	//The UID of the referred instance
	dynamic open var iUID:String = "\(Default.NO_UID)"{	 
	    didSet { 
	       if iUID != oldValue {
	            self.provisionChanges(forKey: "iUID",oldValue: oldValue,newValue: iUID) 
	       } 
	    }
	}


	//The typeName of the referred instance
	dynamic open var iTypeName:String = "\(Default.NO_UID)"{	 
	    didSet { 
	       if iTypeName != oldValue {
	            self.provisionChanges(forKey: "iTypeName",oldValue: oldValue,newValue: iTypeName) 
	       } 
	    }
	}


    // MARK: Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }

    override open func mapping(map: Map) {
        super.mapping(map: map)
        self.silentGroupedChanges {
			self.iUID <- ( map["iUID"] )
			self.iTypeName <- ( map["iTypeName"] )
        }
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self.iUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "iUID")! as NSString)
			self.iTypeName=String(describing: decoder.decodeObject(of: NSString.self, forKey: "iTypeName")! as NSString)
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self.iUID,forKey:"iUID")
		coder.encode(self.iTypeName,forKey:"iTypeName")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }


    required public init() {
        super.init()
    }

    // MARK: Identifiable

    override open class var collectionName:String{
        return "externalReferences"
    }

    override open var d_collectionName:String{
        return ExternalReference.collectionName
    }


}
