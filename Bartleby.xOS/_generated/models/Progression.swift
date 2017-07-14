//
//  Progression.swift
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

// MARK: Bartleby's Commons: A progression state
@objc(Progression) open class Progression : UnManagedModel {


	//The start time of the progression state
	open var startTime:Double?

	//Index of the task
	dynamic open var currentTaskIndex:Int = 0

	//Total number of tasks
	dynamic open var totalTaskCount:Int = 0

	//0 to 100
	dynamic open var currentPercentProgress:Double = 0

	//The Message
	dynamic open var message:String = ""

	//The consolidated information (may include the message)
	dynamic open var informations:String = ""

	//The associated data
	dynamic open var data:Data?

	//A category to discriminate bunch of progression states
	dynamic open var category:String = ""

	//An external identifier
	dynamic open var externalIdentifier:String = ""


    // MARK: - Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }

    override open func mapping(map: Map) {
        super.mapping(map: map)
        self.quietChanges {
			self.startTime <- ( map["startTime"] )
			self.currentTaskIndex <- ( map["currentTaskIndex"] )
			self.totalTaskCount <- ( map["totalTaskCount"] )
			self.currentPercentProgress <- ( map["currentPercentProgress"] )
			self.message <- ( map["message"] )
			self.informations <- ( map["informations"] )
			self.data <- ( map["data"], DataTransform() )
			self.category <- ( map["category"] )
			self.externalIdentifier <- ( map["externalIdentifier"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.quietChanges {
			self.startTime=decoder.decodeDouble(forKey:"startTime") 
			self.currentTaskIndex=decoder.decodeInteger(forKey:"currentTaskIndex") 
			self.totalTaskCount=decoder.decodeInteger(forKey:"totalTaskCount") 
			self.currentPercentProgress=decoder.decodeDouble(forKey:"currentPercentProgress") 
			self.message=String(describing: decoder.decodeObject(of: NSString.self, forKey: "message")! as NSString)
			self.informations=String(describing: decoder.decodeObject(of: NSString.self, forKey: "informations")! as NSString)
			self.data=decoder.decodeObject(of: NSData.self, forKey:"data") as Data?
			self.category=String(describing: decoder.decodeObject(of: NSString.self, forKey: "category")! as NSString)
			self.externalIdentifier=String(describing: decoder.decodeObject(of: NSString.self, forKey: "externalIdentifier")! as NSString)
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		if let startTime = self.startTime {
			coder.encode(startTime,forKey:"startTime")
		}
		coder.encode(self.currentTaskIndex,forKey:"currentTaskIndex")
		coder.encode(self.totalTaskCount,forKey:"totalTaskCount")
		coder.encode(self.currentPercentProgress,forKey:"currentPercentProgress")
		coder.encode(self.message,forKey:"message")
		coder.encode(self.informations,forKey:"informations")
		if let data = self.data {
			coder.encode(data,forKey:"data")
		}
		coder.encode(self.category,forKey:"category")
		coder.encode(self.externalIdentifier,forKey:"externalIdentifier")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

     required public init() {
        super.init()
    }
}