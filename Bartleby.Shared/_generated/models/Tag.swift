//
//  Tag.swift
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

// MARK: Bartleby's Core: a tag can be used to classify instances.
@objc(Tag) public class Tag : JObject{

    // Universal type support
    override public class func typeName() -> String {
        return "Tag"
    }

	public var creationDate:String? {	 
	    didSet { 
	       if creationDate != oldValue {
	            self.provisionChanges(forKey: "creationDate",oldValue: oldValue,newValue: creationDate) 
	       } 
	    }
	}

	public var color:String? {	 
	    didSet { 
	       if color != oldValue {
	            self.provisionChanges(forKey: "color",oldValue: oldValue,newValue: color) 
	       } 
	    }
	}

	public var icon:String? {	 
	    didSet { 
	       if icon != oldValue {
	            self.provisionChanges(forKey: "icon",oldValue: oldValue,newValue: icon) 
	       } 
	    }
	}



    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
        self.disableSupervision()
        self.disableAutoCommit()
		self.creationDate <- ( map["creationDate"] )
		self.color <- ( map["color"] )
		self.icon <- ( map["icon"] )
        self.enableSupervision()
        self.enableAutoCommit()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.disableSupervision()
        self.disableAutoCommit()
		self.creationDate=String(decoder.decodeObjectOfClass(NSString.self, forKey:"creationDate") as NSString?)
		self.color=String(decoder.decodeObjectOfClass(NSString.self, forKey:"color") as NSString?)
		self.icon=String(decoder.decodeObjectOfClass(NSString.self, forKey:"icon") as NSString?)

        self.enableSupervision()
        self.enableAutoCommit()
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		if let creationDate = self.creationDate {
			coder.encodeObject(creationDate,forKey:"creationDate")
		}
		if let color = self.color {
			coder.encodeObject(color,forKey:"color")
		}
		if let icon = self.icon {
			coder.encodeObject(icon,forKey:"icon")
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
        return "tags"
    }

    override public var d_collectionName:String{
        return Tag.collectionName
    }


}

