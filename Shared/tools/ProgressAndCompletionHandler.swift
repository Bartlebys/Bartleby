//
//  ProgressAndCompletionHandler.swift
//
//  Created by Benoit Pereira da silva on 22/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation


// MARK: - TypeAliases

//A composed Closure
//with a progress and acompletion section
public typealias ComposedProgressAndCompletionHandler = (currentTaskIndex:Int,totalTaskCount:Int,currentTaskProgress:Double,message:String,data:NSData?,completed:Bool,success:Bool)->()

//ProgressHandler
public typealias ProgressHandler = (_: Progression) -> ()

//CompletionHandler
public typealias CompletionHandler = (_: Completion) -> ()


// MARK: -

//  Generally Used in XPC facades because we can pass only one handler per XPC call
//  So we split the ComposedProgressAndCompletionHandler by calling ProgressAndCompletionHandler.handlersFrom(composed)
@objc(ProgressAndCompletionHandler) public class ProgressAndCompletionHandler:NSObject{
    
    /// The progress handler
    public var notify: ProgressHandler?
    
    public func addProgressHandler(progressHandler: ProgressHandler){
        self.notify = progressHandler
    }
    /// The completion handler
    public var on:(CompletionHandler)
    
    public required init(completionHandler: CompletionHandler){
        self.on = completionHandler
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
        
        let handlers=ProgressAndCompletionHandler {(completion) -> () in
            // This is the completion handler
            // By convention we inject false progress information
            composedHandler(currentTaskIndex: 0,   // Dummy Progress section
                totalTaskCount: 0,              // Dummy
                currentTaskProgress: 0,                // Dummy
                message: completion.message,   // Dummy
                data:nil,
                completed: true,
                success: true
            )
        }
        
        handlers.addProgressHandler { (progression) -> () in
            composedHandler(currentTaskIndex: progression.currentTaskIndex,
                totalTaskCount: progression.totalTaskCount,
                currentTaskProgress: progression.currentTaskProgress,
                message: progression.message,
                data:progression.data,
                completed: false,   // Dummy Completion section
                success: false      // Dummy
                )
        }
        return handlers
    
    }
    
    // We need to provide a unique handler to be compatible with the XPC context
    // So we use an handler adapter that relays to the progress and completion handlers
    // to mask the constraint.
    public func composedHandlers() -> ComposedProgressAndCompletionHandler {
        let handler: ComposedProgressAndCompletionHandler = {(currentTaskIndex,totalTaskCount,currentTaskProgress,message,data,completed,success)-> Void in
            
            if completed {
                self.on(Completion(success: success,message: message))
            }else{
                self.notify?(Progression(currentTaskIndex:currentTaskIndex,
                                              totalTaskCount:totalTaskCount,
                                              currentTaskProgress:currentTaskProgress,
                                              message:message,
                                              data: data))
            }
        }
        return handler
    }
}




