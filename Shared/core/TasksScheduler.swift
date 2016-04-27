//
//  TasksScheduler.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 19/04/2016.
//
//

import Foundation

extension Task{
    dynamic var linearTaskList:[Task]{
        get{
            // Return a linear task List
            var tasks=[Task]()
            func childrens(parent:Task, inout tasks:[Task]){
                tasks.append(parent)
                for child in parent.children{
                    childrens(child, tasks: &tasks)
                }
            }
            childrens(self, tasks: &tasks)
            return tasks
        }
    }
}

public extension TasksGroup{
    
    public func start() throws {
        // We start all the tasks
        // TODO @bpds(#FEATURE) support tasks graphs
        for task in self.tasks{
            task.invoke()
        }

    }
    
    /*
    public func pause(onPause:()->())throws {
        try Bartleby.scheduler.pauseTaskGroup(self.groupUID, onPause: onPause)
    }
    */
    
}


enum TasksSchedulerError:ErrorType {
    case DataSpaceNotFound
    case TaskGroupNotFound
}


@objc(TasksScheduler) public class TasksScheduler:NSObject {

    
    public func provisionTasks(parentTask:Task,groupName:String,inDataSpace spaceUID:String) throws -> TasksGroup{
        let group=TasksGroup()
        group.name=groupName
        group.tasks=parentTask.linearTaskList
        group.priority=parentTask.priority.rawValue
        group.status=parentTask.status.rawValue
        if let document=Bartleby.sharedInstance.getRegistryByUID(spaceUID) as? BartlebyDocument{
            document.tasksGroups.add(group)
        }else{
           throw TasksSchedulerError.DataSpaceNotFound
        }
        return group
    }

    /*
    public func startTaskGroup(groupUID:String)throws{
        if let group:TasksGroup=Bartleby.objectByUID(groupUID){
            // We start all the tasks
            for task in group.tasks{
                task.invoke()
            }
        }else{
            throw TasksSchedulerError.TaskGroupNotFound
        }
    }
    public func pauseTaskGroup(groupUID:String, onPause:()->())throws{
    
    }
    */
    
}