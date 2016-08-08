//
//  Task.swift
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

// MARK: Bartleby's Commons A task (abstract)
@objc(Task) public class Task : JObject{

    // Universal type support
    override public class func typeName() -> String {
        return "Task"
    }

	//The Task group. External reference to a TaskGroup instance
	public var group:ExternalReference?
	//Task Status
	public enum Status:Int{
		case Runnable
		case Running
		case Completed
	}
	public var status:Status = .Runnable
	//The Task parent. 
	public var parent:ExternalReference?
	//A collection of children Task external references (in the same group)
	public var children:[ExternalReference] = [ExternalReference]()
	//The progression state of the task
	public var progressionState:Progression?
	//The completion state of the task
	public var completionState:Completion?
	//The serialized arguments
	public var argumentsData:NSData?
	//The serialized result
	public var resultData:NSData?


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
        self.disableSupervisionAndCommit()
		self.group <- ( map["group"] )
		self.status <- ( map["status"] )
		self.parent <- ( map["parent"] )
		self.children <- ( map["children"] )
		self.progressionState <- ( map["progressionState"] )
		self.completionState <- ( map["completionState"] )
		self.argumentsData <- ( map["argumentsData"], Base64DataTransform() )
		self.resultData <- ( map["resultData"], Base64DataTransform() )
        self.enableSuperVisionAndCommit()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.disableSupervisionAndCommit()
		self.group=decoder.decodeObjectOfClass(ExternalReference.self, forKey: "group") 
		self.status=Task.Status(rawValue:decoder.decodeIntegerForKey("status") )! 
		self.parent=decoder.decodeObjectOfClass(ExternalReference.self, forKey: "parent") 
		self.children=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),ExternalReference.classForCoder()]), forKey: "children")! as! [ExternalReference]
		self.progressionState=decoder.decodeObjectOfClass(Progression.self, forKey: "progressionState") 
		self.completionState=decoder.decodeObjectOfClass(Completion.self, forKey: "completionState") 
		self.argumentsData=decoder.decodeObjectOfClass(NSData.self, forKey:"argumentsData") as NSData?
		self.resultData=decoder.decodeObjectOfClass(NSData.self, forKey:"resultData") as NSData?

        self.enableSuperVisionAndCommit()
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		if let group = self.group {
			coder.encodeObject(group,forKey:"group")
		}
		coder.encodeInteger(self.status.rawValue ,forKey:"status")
		if let parent = self.parent {
			coder.encodeObject(parent,forKey:"parent")
		}
		coder.encodeObject(self.children,forKey:"children")
		if let progressionState = self.progressionState {
			coder.encodeObject(progressionState,forKey:"progressionState")
		}
		if let completionState = self.completionState {
			coder.encodeObject(completionState,forKey:"completionState")
		}
		if let argumentsData = self.argumentsData {
			coder.encodeObject(argumentsData,forKey:"argumentsData")
		}
		if let resultData = self.resultData {
			coder.encodeObject(resultData,forKey:"resultData")
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
        return "tasks"
    }

    override public var d_collectionName:String{
        return Task.collectionName
    }


}
