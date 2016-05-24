//
//  TasksGroup.swift
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

// MARK: Bartleby's
@objc(TasksGroup) public class TasksGroup : JObject{

    // Universal type support
    override public class func typeName() -> String {
        return "TasksGroup"
    }

	//A non serializable reference to the hosting document
	public var document:BartlebyDocument? {	 
	    willSet { 
	       if document != newValue {
	            self.commitRequired() 
	       } 
	    }
	}

	//TasksGroup Status
	public enum Status:Int{
		case Paused
		case Running
	}
	public var status:Status = .Paused  {	 
	    willSet { 
	       if status != newValue {
	            self.commitRequired() 
	       } 
	    }
	}

	//The priority is equal to the parent task.
	public enum Priority:Int{
		case Background
		case Low
		case Default
		case High
	}
	public var priority:Priority = .Default  {	 
	    willSet { 
	       if priority != newValue {
	            self.commitRequired() 
	       } 
	    }
	}

	//The group dataspace
	public var spaceUID:String = "\(Default.NO_UID)"{	 
	    willSet { 
	       if spaceUID != newValue {
	            self.commitRequired() 
	       } 
	    }
	}

	//The root group Tasks (external references)
	public var tasks:[ExternalReference] = [ExternalReference]()  {	 
	    willSet { 
	       if tasks != newValue {
	            self.commitRequired() 
	       } 
	    }
	}

	//The last chained (sequential) task external reference. 
	public var lastChainedTask:ExternalReference? {	 
	    willSet { 
	       if lastChainedTask != newValue {
	            self.commitRequired() 
	       } 
	    }
	}

	//The progression state of the group
	public var progressionState:Progression? {	 
	    willSet { 
	       if progressionState != newValue {
	            self.commitRequired() 
	       } 
	    }
	}

	//The completion state of the group
	public var completionState:Completion? {	 
	    willSet { 
	       if completionState != newValue {
	            self.commitRequired() 
	       } 
	    }
	}

	//The group name
	public var name:String = "\(Default.NO_NAME)"{	 
	    willSet { 
	       if name != newValue {
	            self.commitRequired() 
	       } 
	    }
	}

	//A void handler to allow subscribers to register their own handlers
	public var handlers:Handlers = Handlers.withoutCompletion()  {	 
	    willSet { 
	       if handlers != newValue {
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
		self.status <- map["status"]
		self.priority <- map["priority"]
		self.spaceUID <- map["spaceUID"]
		self.tasks <- map["tasks"]
		self.lastChainedTask <- map["lastChainedTask"]
		self.progressionState <- map["progressionState"]
		self.completionState <- map["completionState"]
		self.name <- map["name"]
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
		self.status=TasksGroup.Status(rawValue:decoder.decodeIntegerForKey("status") )! 
		self.priority=TasksGroup.Priority(rawValue:decoder.decodeIntegerForKey("priority") )! 
		self.spaceUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "spaceUID")! as NSString)
		self.tasks=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),ExternalReference.classForCoder()]), forKey: "tasks")! as! [ExternalReference]
		self.lastChainedTask=decoder.decodeObjectOfClass(ExternalReference.self, forKey: "lastChainedTask") 
		self.progressionState=decoder.decodeObjectOfClass(Progression.self, forKey: "progressionState") 
		self.completionState=decoder.decodeObjectOfClass(Completion.self, forKey: "completionState") 
		self.name=String(decoder.decodeObjectOfClass(NSString.self, forKey: "name")! as NSString)

    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		coder.encodeInteger(self.status.rawValue ,forKey:"status")
		coder.encodeInteger(self.priority.rawValue ,forKey:"priority")
		coder.encodeObject(self.spaceUID,forKey:"spaceUID")
		coder.encodeObject(self.tasks,forKey:"tasks")
		if let lastChainedTask = self.lastChainedTask {
			coder.encodeObject(lastChainedTask,forKey:"lastChainedTask")
		}
		if let progressionState = self.progressionState {
			coder.encodeObject(progressionState,forKey:"progressionState")
		}
		if let completionState = self.completionState {
			coder.encodeObject(completionState,forKey:"completionState")
		}
		coder.encodeObject(self.name,forKey:"name")
    }


    override public class func supportsSecureCoding() -> Bool{
        return true
    }


    required public init() {
        super.init()
    }

    // MARK: Identifiable

    override public class var collectionName:String{
        return "tasksGroups"
    }

    override public var d_collectionName:String{
        return TasksGroup.collectionName
    }


}

