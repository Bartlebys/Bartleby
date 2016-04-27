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
            var tasks=[Task]()
            func childrens(parent:Task, inout tasks:[Task]){
                //tasks.appendContentsOf(parent.children)
            }
            childrens(self, tasks: &tasks)
            return tasks
        }
    }
    
    
}

@objc(TasksScheduler) public class TasksScheduler:NSObject {

    
    public func provisionTasks(_:[Task],under groupName:String){

    }
    
    public func startTaskGroup(groupName:String){
        
    }
    
    public func pauseTaskGroup(groupName:String, onPause:()->()){
        
    }
    
}