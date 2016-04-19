//
//  TasksScheduler.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 19/04/2016.
//
//

import Foundation


class Task:NSObject{
}

class GroupOfTask:NSObject{
}


@objc(TasksScheduler) class TasksScheduler:NSObject {
    
    // MARK: - Bartleby's task scheduler
    
    /// The tasks group can be binded
    public dynamic var tasksGroups:[GroupOfTask]=[GroupOfTask]()
    
    /*
        DISPATCH_QUEUE_PRIORITY_BACKGROUND
        DISPATCH_QUEUE_PRIORITY_DEFAULT
        DISPATCH_QUEUE_PRIORITY_HIGH
        DISPATCH_QUEUE_PRIORITY_LOW
     */
    public enum Priority{
        case Background
        case Default
        case High
        case Low
    }
    
    /**
     Description
     
     - parameter groupName: groupName description
     */
    public func provisionTasks(_:GroupOfTask, groupName:String){

    }
    
    public func startTaskGroup(groupName:String){
        
    }
    
    public func pauseTaskGroup(groupName:String, onPause:()->()){
        
    }
    
    /**
     Pushes the operation
     
     - parameter operations: the provionned operations
     - parameter iterator:   the iteraror reference for recursive calls.
     */
    public func startTasks(operations:[Operation],inout iterator:IndexingGenerator<[Operation]>){
        /*
         if let currentOperation=iterator.next(){
         self.pushOperation(currentOperation, sucessHandler: { (context) -> () in
         if let operationDictionary=currentOperation.data{
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
         */
    }
    
    /**
     Pushes the operations
     Is a wrapper that pushes chained operations
     - parameter operations: the operations
     */
    public func pushOperations(operations:[Operation]) {
        var iterator=operations.generate()
        //self.pushChainedOperation(operations, iterator: &iterator)
    }
    
}