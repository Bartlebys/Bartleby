//
//  ProgressAndCompletionHandler.swift
//
//  Created by Benoit Pereira da silva on 22/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

// A composed Closure with a progress and acompletion section
public typealias ComposedProgressAndCompletionHandler = (taskIndex:Int,totalTaskCount:Int,taskProgress:Double,progressMessage:String?,data:NSData?,completed:Bool,successfulCompletion:Bool,completionMessage:String?)->()


//  Generally Used in XPC facades because we can pass only one block per XPC call
//  So we split the ComposedProgressAndCompletionHandler by calling ProgressAndCompletionHandler.handlersFrom(composed)
@objc(ProgressAndCompletionHandler) public class ProgressAndCompletionHandler:NSObject{
    
    /// The progress block
    public var progressBlock:((taskIndex:Int,totalTaskCount:Int,taskProgress:Double,message:String?,data:NSData?)->())?
    
    public func addProgressBlock(progressBlock:((taskIndex:Int,totalTaskCount:Int,taskProgress:Double,message:String?,data:NSData?)->())){
        self.progressBlock=progressBlock
    }
    /// The completion block
    public var completionBlock:((success:Bool,message:String?)->())
    
    public init(completionBlock:((success:Bool,message:String?)->())){
        self.completionBlock=completionBlock
    }

    /**
     XPC adapter used to split closure in two parts
     
     - parameter composedHandler: the composed handler
     - returns: an instance of ProgressAndCompletionHandler
     */
    public static func handlersFrom(composedHandler:ComposedProgressAndCompletionHandler)->ProgressAndCompletionHandler{
        
        // Those handlers produce an adaptation
        // From the unique handler form
        // progress and completion handlers.
        
        let handlers=ProgressAndCompletionHandler {(success, message) -> () in
            // This is the completion block
            // By convention we inject false progress information
            composedHandler(    taskIndex: 0,           // Dummy Progress section
                totalTaskCount: 0,      // Dummy
                taskProgress: 1,        // Dummy
                progressMessage: nil,
                data:nil,
                completed: true,
                successfulCompletion: success,
                completionMessage: message)
        }
        
        handlers.addProgressBlock { (taskIndex, totalTaskCount, taskProgress, message,data) -> () in
            composedHandler(    taskIndex: taskIndex,
                totalTaskCount: totalTaskCount,
                taskProgress: taskProgress,
                progressMessage: message,
                data:data,
                completed: false,               // Dummy Completion section
                successfulCompletion: false,    // Dummy
                completionMessage:nil )         // Dummy
        }
        return handlers
    
    }
    
}