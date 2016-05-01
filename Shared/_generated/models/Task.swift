//
//  Task.swift
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

// MARK: Model Task
@objc(Task) public class Task : BaseObject{


	//TasksGroup Status
	public enum Status:Int{
		case New
		case Pending
		case Running
		case Paused
		case Completed
	}
	public var status:Status = .New
	//The priority is equal to the parent task.
	public enum Priority:Int{
		case Background
		case Low
		case Default
		case High
	}
	public var priority:Priority = .Default
	//The parent task
	public var parent:Task?
	//A collection of Concrete Tasks
	public var children:[Task] = [Task]()
	//The progression state of the task
	public var progressionState:Progression = Progression()
	//The completion state of the task
	public var completionState:Completion = Completion()
	//The serialized arguments
	public var argumentsData:NSData?
	//The serialized result
	public var resultData:NSData?
	//The task class name
	public var taskClassName:String?
	//The argument class name
	public var argumentClassName:String?


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
        mapping(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
		self.status <- map["status"]
		self.priority <- map["priority"]
		self.parent <- map["parent"]
		self.children <- map["children"]
		self.progressionState <- map["progressionState"]
		self.completionState <- map["completionState"]
		self.argumentsData <- (map["argumentsData"],Base64DataTransform())
		self.resultData <- (map["resultData"],Base64DataTransform())
		self.taskClassName <- map["taskClassName"]
		self.argumentClassName <- map["argumentClassName"]
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
		self.status=Task.Status(rawValue:decoder.decodeIntegerForKey("status") )! 
		self.priority=Task.Priority(rawValue:decoder.decodeIntegerForKey("priority") )! 
		self.parent=decoder.decodeObjectOfClass(Task.self, forKey: "parent") 
		self.children=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),Task.classForCoder()]), forKey: "children")! as! [Task]
		self.progressionState=decoder.decodeObjectOfClass(Progression.self, forKey: "progressionState")! 
		self.completionState=decoder.decodeObjectOfClass(Completion.self, forKey: "completionState")! 
		self.argumentsData=decoder.decodeObjectOfClass(NSData.self, forKey:"argumentsData") as NSData?
		self.resultData=decoder.decodeObjectOfClass(NSData.self, forKey:"resultData") as NSData?
		self.taskClassName=String(decoder.decodeObjectOfClass(NSString.self, forKey:"taskClassName") as NSString?)
		self.argumentClassName=String(decoder.decodeObjectOfClass(NSString.self, forKey:"argumentClassName") as NSString?)

    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		coder.encodeInteger(self.status.rawValue ,forKey:"status")
		coder.encodeInteger(self.priority.rawValue ,forKey:"priority")
		if let parent = self.parent {
			coder.encodeObject(parent,forKey:"parent")
		}
		coder.encodeObject(self.children,forKey:"children")
		coder.encodeObject(self.progressionState,forKey:"progressionState")
		coder.encodeObject(self.completionState,forKey:"completionState")
		if let argumentsData = self.argumentsData {
			coder.encodeObject(argumentsData,forKey:"argumentsData")
		}
		if let resultData = self.resultData {
			coder.encodeObject(resultData,forKey:"resultData")
		}
		if let taskClassName = self.taskClassName {
			coder.encodeObject(taskClassName,forKey:"taskClassName")
		}
		if let argumentClassName = self.argumentClassName {
			coder.encodeObject(argumentClassName,forKey:"argumentClassName")
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


    // MARK: Persistent

    override public func toPersistentRepresentation()->(UID:String,collectionName:String,serializedUTF8String:String,A:Double,B:Double,C:Double,D:Double,E:Double,S:String){
        var r=super.toPersistentRepresentation()
        r.A=NSDate().timeIntervalSince1970
        return r
    }

}

