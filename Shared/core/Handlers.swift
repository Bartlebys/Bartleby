//
//  Handlers.swift
//
//  Created by Benoit Pereira da silva on 22/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation


// MARK: - TypeAliases

//A composed Closure
//with a progress and acompletion section
public typealias ComposedHandler = (progressionState: Progression?, completionState: Completion?)->()

 //public typealias ComposedHandler = (currentTaskIndex:Int,totalTaskCount:Int,currentTaskProgress:Double,message:String,data:NSData?,completed:Bool,success:Bool)->()

//ProgressHandler
public typealias ProgressHandler = (_: Progression) -> ()

//CompletionHandler
public typealias CompletionHandler = (_: Completion) -> ()

// MARK: -

//  Generally Used in XPC facades because we can pass only one handler per XPC call
//  So we split the ComposedHandler by calling Handlers.handlersFrom(composed)
@objc(Handlers) public class Handlers: NSObject {

    // MARK: Progression handlers
    private var progressionHandlers: [ProgressHandler] = []

    public func addProgressHandler(progressHandler: ProgressHandler) {
        self.progressionHandlers.append(progressHandler)
    }

    // Call all the progression handlers
    public func notify(progressionState: Progression) {
        for handler in self.progressionHandlers {
            handler(progressionState)
        }
    }

    // MARK: Completion handlers
    private var completionHandlers: [CompletionHandler] = []

    public func addCompletionHandler(handler: CompletionHandler) {
        self.completionHandlers.append(handler)
    }

    // Call all the completion handlers
    public func on(completionState: Completion) {
        for handler in self.completionHandlers {
            handler(completionState)
        }
    }

    public required init(completionHandler: CompletionHandler) {
        self.completionHandlers.append(completionHandler)
    }

    /**
     XPC adapter used to split closure in two parts

     - parameter composedHandler: the composed handler
     - returns: an instance of Handlers
     */
    public static func handlersFrom(composedHandler: ComposedHandler)->Handlers {

        // Those handlers produce an adaptation
        // From the unique handler form
        // progress and completion handlers.

        let handlers=Handlers {(onCompletion) -> () in
            composedHandler(progressionState:nil, completionState:onCompletion)
        }

        handlers.addProgressHandler { (onProgression) -> () in
            composedHandler(progressionState:onProgression, completionState:nil)
        }
        return handlers
    }

    // We need to provide a unique handler to be compatible with the XPC context
    // So we use an handler adapter that relays to the progress and completion handlers
    // to mask the constraint.
    public func composedHandlers() -> ComposedHandler {
        let handler: ComposedHandler = {(progressionState, completionState)-> Void in
            if let progressionState=progressionState {
                 self.notify(progressionState)
            }
            if let completion=completionState {
                 self.on(completion)
            }
        }
        return handler
    }
}
