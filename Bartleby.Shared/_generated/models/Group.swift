//
//  Group.swift
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

// MARK: Bartleby's Core: a group of user
@objc(Group) public class Group : JObject{

    // Universal type support
    override public class func typeName() -> String {
        return "Group"
    }

	public var creationDate:String? {	 
	    willSet { 
	       if creationDate != newValue {
	            self.provisionChanges() 
	       } 
	    }
	}

	public var color:String? {	 
	    willSet { 
	       if color != newValue {
	            self.provisionChanges() 
	       } 
	    }
	}

	public var icon:String? {	 
	    willSet { 
	       if icon != newValue {
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
		self.creationDate <- ( map["creationDate"] )
		self.color <- ( map["color"] )
		self.icon <- ( map["icon"] )
        self.unlockAutoCommitObserver()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.lockAutoCommitObserver()
		self.creationDate=String(decoder.decodeObjectOfClass(NSString.self, forKey:"creationDate") as NSString?)
		self.color=String(decoder.decodeObjectOfClass(NSString.self, forKey:"color") as NSString?)
		self.icon=String(decoder.decodeObjectOfClass(NSString.self, forKey:"icon") as NSString?)
        self.unlockAutoCommitObserver()
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
        return "groups"
    }

    override public var d_collectionName:String{
        return Group.collectionName
    }


}

