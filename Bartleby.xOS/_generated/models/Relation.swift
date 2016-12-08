//
//  Relation.swift
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

// MARK: Bartleby's Core: used to store a specific relation between instances
@objc(Relation) open class Relation : NSObject, Mappable, NSSecureCoding {


	//the relationship
	dynamic open var relationship:String = "\(Relationship.free)"

	//the UID of the entity
	dynamic open var UID:String = "\(Default.NO_UID)"


    // MARK: - Mappable

    required public init?(map: Map) {
        
    }

     open func mapping(map: Map) {
        
        self.quietChanges {
			self.relationship <- ( map["relationship"] )
			self.UID <- ( map["UID"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init()
        self.quietChanges {
			self.relationship=String(describing: decoder.decodeObject(of: NSString.self, forKey: "relationship")! as NSString)
			self.UID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "UID")! as NSString)
        }
    }

     open func encode(with coder: NSCoder) {
        
		coder.encode(self.relationship,forKey:"relationship")
		coder.encode(self.UID,forKey:"UID")
    }

     open class var supportsSecureCoding:Bool{
        return true
    }

    override required public init() {
        super.init()
    }

    // TODO to be removed
    public func quietChanges(_ changes:()->()){
    }
}