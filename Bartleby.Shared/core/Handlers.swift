//
//  Handlers.swift
//
//  Created by Benoit Pereira da silva on 22/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation


// MARK: - TypeAliases

//  A composed Closure with a progress and acompletion section
//  Generally Used in XPC facades because we can pass only one handler per XPC call
//  To consume and manipulate we generally split the ComposedHandler by calling Handlers.handlersFrom(composed)
public typealias ComposedHandler = (progressionState: Progression?, completionState: Completion?)->()

//ProgressHandler
public typealias ProgressHandler = (_: Progression) -> ()

//CompletionHandler
public typealias CompletionHandler = (_: Completion) -> ()

// MARK: -

/**
 * Composable handlers with at least one Completion Handler
 * You can compose multiple completion and progression
 */
public class Handlers: NSObject {

    // MARK: Progression handlers
    private var _progressionHandlers: [ProgressHandler] = []

    public func appendProgressHandler(progressHandler: ProgressHandler) {
        self._progressionHandlers.append(progressHandler)
    }

    // Call all the progression handlers
    public func notify(progressionState: Progression) {
        for handler in self._progressionHandlers {
            handler(progressionState)
        }
    }

    // MARK: Completion handlers
    private var _completionHandlers: [CompletionHandler] = []

    public func appendCompletionHandler(handler: CompletionHandler) {
        self._completionHandlers.append(handler)
    }

    // Call all the completion handlers
    public func on(completionState: Completion) {
        for handler in self._completionHandlers {
            handler(completionState)
        }
    }

    /**
     Designated initializer
     You must pass a completion Handler.
     - parameter completionHandler: the completion Handler

     - returns: the instance.
     */
    public required init(completionHandler: CompletionHandler) {
        self._completionHandlers.append(completionHandler)
    }

    /**
     XPC adapter used to split closure in two parts
     - parameter composedHandler: the composed handler

     - returns: an instance of Handlers
     */
    public static func handlersFrom(composedHandler: ComposedHandler) -> Handlers {

        // Those handlers produce an adaptation
        // From the unique handler form
        // progress and completion handlers.

        let handlers=Handlers {(onCompletion) -> () in
            composedHandler(progressionState:nil, completionState:onCompletion)
        }

        handlers.appendProgressHandler { (onProgression) -> () in
            composedHandler(progressionState:onProgression, completionState:nil)
        }
        return handlers
    }

    /**

     We need to provide a unique handler to be compatible with the XPC context
     So we use an handler adapter that relays to the progress and completion handlers
     to mask the constraint.

     - returns: the composed Handler
     */
    public func composedHandlers() -> ComposedHandler {
        let handler: ComposedHandler = {(progressionState, completionState) -> Void in
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
