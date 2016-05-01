//
//  TasksScheduler.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 19/04/2016.
//
//

import Foundation


// MARK: - TasksScheduler

enum TasksSchedulerError:ErrorType {
    case DataSpaceNotFound
    case TaskGroupNotFound
}



@objc(TasksScheduler) public class TasksScheduler:NSObject {
    
    //Storage
    private var _groups=Dictionary<String,TasksGroup>()
    
    /**
     Provision a task in a given Group.
     
     - parameter parentTask: the task to provision.
     - parameter groupName:  its group name
     - parameter spaceUID:   the relevent DataSpace
     
     - throws: DataSpace Not found
     
     - returns: the Task group
     */
    public func provisionTasks(parentTask:Task,groupedBy groupName:String,inDataSpace spaceUID:String) throws -> TasksGroup{
        let group=try self.taskGroupByName(groupName,inDataSpace: spaceUID)
        group.tasks.append(parentTask)
        group.priority=parentTask.priority
        group.status=parentTask.status
        if let document=Bartleby.sharedInstance.getRegistryByUID(spaceUID) as? BartlebyDocument{
            document.tasksGroups.add(group)
        }else{
            throw TasksSchedulerError.DataSpaceNotFound
        }
        return group
    }
    
    
    /**
     Returns a TaskGroup by its name.
     If necessary it creates the group
     
     - parameter groupName: the group name
     
     - returns: a task group
     */
    public func taskGroupByName(groupName:String,inDataSpace spaceUID:String) throws ->TasksGroup{
        if let group=_groups[groupName]{
            return group
        }else{
            if let document=Bartleby.sharedInstance.getRegistryByUID(spaceUID) as? BartlebyDocument{
                
                if let groups:[TasksGroup]=document.tasksGroups.filter({ (group) -> Bool in
                    return group.name==groupName}){
                    
                    if groups.count>0{
                        _groups[groups.first!.name]=groups.first!
                        return groups.first!
                    }
                    
                    let group=TasksGroup()
                    group.name=groupName
                    _groups[groupName]=group
                    return group
                    
                }else{
                    throw TasksSchedulerError.DataSpaceNotFound
                }
            }
        }
         throw TasksSchedulerError.TaskGroupNotFound
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
        
        
        
        
        /*
         public func pushChainedOperation(operations:[Operation],inout iterator:IndexingGenerator<[Operation]>){
         if let currentOperation=iterator.next(){
         self.pushOperation(currentOperation, sucessHandler: { (context) -> () in
         if let operationDictionary=currentOperation.toDictionary{
         if let referenceName=operationDictionary[Default.REFERENCE_NAME_KEY],
         uid=operationDictionary[Default.UID_KEY]{
         self.delete(currentOperation)
         do{
         let ic:OperationsCollectionController = try self.getCollection()
         bprint("\(ic.UID)->OPCOUNT_AFTER_EXEC=\(ic.items.count) \(referenceName) \(uid)",file: #file,function: #function,line: #line)
         }catch{
         bprint("OperationsCollectionController getCollection \(error)",file: #file,function: #function,line: #line)
         }
         }
         }
         Bartleby.executeAfter(Bartleby.configuration.DELAY_BETWEEN_OPERATIONS_IN_SECONDS, closure: {
         self.pushChainedOperation(operations, iterator: &iterator)
         })
         }, failureHandler: { (context) -> () in
         // Stop the chain
         })
         }
         }
         
         
         
         public func pushOperations(operations:[Operation]) {
         var iterator=operations.generate()
         self.pushChainedOperation(operations, iterator: &iterator)
         }
         
         
         
         
         public func pushOperation(operation:Operation){
         self.pushOperation(operation, sucessHandler: { (context) -> () in
         self.delete(operation)
         }) { (context) -> () in
         
         }
         }
         
         public func pushOperation(operation:Operation,sucessHandler success:(context:HTTPResponse)->(),failureHandler failure:(context:HTTPResponse)->()){
         if let serialized=operation.toDictionary{
         if let command=self.serializer.deserializeFromDictionary(serialized) as? JHTTPCommand{
         command.push(sucessHandler:success, failureHandler:failure)
         }else{
         //TODO: @bpds what should be done
         }
         }
         }
         */
}


// MARK: - TasksGroup Extension

enum TasksGroupError:ErrorType {
    case NonInvocableTask(task:Task)
}


public extension TasksGroup{
    
    
    /**
     Starts the task group
     
     - throws: Error on Non Invocable task
     
     - returns: the number of entry tasks if >1 there is something to do.
     */
    public func start() throws -> Int{
        let entryTasks=self.findEntryTasks()
        for task in entryTasks{
            if let invocableTask = task as? Invocable{
                invocableTask.invoke()
            }else{
                throw TasksGroupError.NonInvocableTask(task: task)
            }
        }
        return entryTasks.count
    }
    
    /**
     All the running tasks will be finished
     But not their children tasks.
     */
    public func pause(){
        self.status = .Paused
    }
    
    
    // MARK: Find entry Tasks
    
    /**
     Determines the bunch of task to use to start or resume a TaskGroup.
     The entry tasks may be deeply nested if the graph has already been partially running
     
     - returns: a collection of tasks
     */
    public func findEntryTasks()->[Task]{
        //Top level of the graph.
        var topLevelTasks=[Task]()
        for task in self.tasks{
            if task.status != Task.Status.Completed{
                topLevelTasks.append(task)
            }
        }
        if topLevelTasks.count==0{
            for task in self.tasks{
                self._findTasksUnCompletedSubTask(task, topLevelTasks: &topLevelTasks)
            }
        }
        return topLevelTasks
    }
    
    
    private func _findTasksUnCompletedSubTask(task:Task,inout topLevelTasks:[Task]){
        if topLevelTasks.count==0{
            for childTask in task.children{
                if childTask.status != Task.Status.Completed{
                    topLevelTasks.append(childTask)
                }
            }
            if topLevelTasks.count==0{
                for task in task.children{
                    self._findTasksUnCompletedSubTask(task, topLevelTasks: &topLevelTasks)
                }
            }
        }
    }
    
    // MARK: Find tasks with status
    
    public func findTasksWithStatus(status:Task.Status)->[Task]{
        var matching=[Task]()
        let rootTasks=self.tasks.filter { (task) -> Bool in
            return task.status==status
        }
        matching.appendContentsOf(rootTasks)
        for task in self.tasks{
            self._findChildrenTasksWithStatus(task,status:status,tasks:&matching)
        }
        return matching
    }
    
    
    private func _findChildrenTasksWithStatus(task:Task,status:Task.Status,inout tasks:[Task]){
        let matchingChildren=task.children.filter { (subTask) -> Bool in
            return subTask.status==status
        }
        tasks.appendContentsOf(matchingChildren)
    }
    
}


