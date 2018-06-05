//
//  Handlers.swift
//
//  Created by Benoit Pereira da silva on 22/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation


/*
 
# Notes on Handlers
 
## We expose 6 Handlers

 - CompletionHandler : a closure with a completion state
 - ProgressionHandler : a closure with a progression state
 - Handlers : a class that allows to compose completion an progression Handlers.
 - ComposedHandler : a composed closure
 - VoidCompletionHandler : a void handler that can be used as place holder
 - VoidProgressionHandler : a void handler that can be used as place holder

 ## We should not use ComposedHandler in XPC context (!)

 Only one closure can be called per XPC call.
 So to monitor progression from an XPC : **we use Bidirectionnal XPC + Monitoring protocol for the progress**

 ## You can create a code Snippets for  :
 
     ```
         let onCompletion:CompletionHandler = { completion in
         }
    ```
    ```
        let onProgression:ProgressHandler = { progression in
        }
    ```
 ## Chaining Handlers:

    You can chain an handler but keep in mind it can produce retain cycle
 ```
     let onCompletion:CompletionHandler = { completion in
        previousHandler(completion) //<--- you can chain a previous handler
     }  
 ```
 
 ## You can instanciate a ComposedHandler :

     ```
         let handler: ComposedHandler = {(progressionState, completionState) -> Void in
            if let progression=progressionState {
            }
            if let completion=completionState {
            }
         }
     ```
*/



// MARK: -

/*
 ProgressionHandler

```
let onProgression:ProgressionHandler = { progression in
    previousHandler(progression)// Invoke
    ...
}
```
*/
public typealias ProgressionHandler = (_ progressionState: Progression) -> ()

/*
 CompletionHandler
 You can chain handlers:
 
 ```
 let onCompletion:CompletionHandler = { completion in
    previousHandler(completion)// Invoke
    ...
 }
 ```
 */
public typealias CompletionHandler = (_ conpletionState: Completion) -> ()

public var VoidCompletionHandler:CompletionHandler = { completion in }

public var VoidProgressionHandler:ProgressionHandler = { progression in }


/**
 A composed Closure with a progress and acompletion section
 Generally Used in XPC facades because we can pass only one handler per XPC call
 To consume and manipulate we generally split the ComposedHandler by calling Handlers.handlersFrom(composed)
 You can instanciate a ComposedHandler :
 ```
 let handler: ComposedHandler = {(progressionState, completionState) -> Void in
    if let progression=progressionState {
    }
    if let completion=completionState {
    }
 }
 ```
 Or you can create one from a Handlers instance by calling `composedHandler()`
 */
public typealias ComposedHandler = (_ progressionState: Progression?, _ completionState: Completion?)->()




// MARK: - Handlers

/**
 * Composable handlers
 * You can compose multiple completion and progression
 */
open class Handlers: NSObject {

    // MARK: Progression handlers

    open var progressionHandlersCount: Int {
        get {
            return self._progressionHandlers.count
        }
    }


    fileprivate var _progressionHandlers: [ProgressionHandler] = []

    open func appendProgressHandler(_ ProgressionHandler: @escaping ProgressionHandler) {
        self._progressionHandlers.append(ProgressionHandler)
    }

    // Call all the progression handlers
    open func notify(_ progressionState: Progression) {
        for handler in self._progressionHandlers {
            handler(progressionState)
        }
    }

    // MARK: Completion handlers


    open var completionHandlersCount: Int {
        get {
            return self._completionHandlers.count
        }
    }

    fileprivate var _completionHandlers: [CompletionHandler] = []

    open func appendCompletionHandler(_ handler: @escaping CompletionHandler) {
        self._completionHandlers.append(handler)
    }

    // Call all the completion handlers
    open func on(_ completionState: Completion) {
        for handler in self._completionHandlers {
            handler(completionState)
        }
    }



    /**
     A factory to declare an explicit Handlers with no completion.

     - returns: an Handlers instance
     */
    public static func withoutCompletion() -> Handlers {
        return Handlers.init(completionHandler: nil)
    }


    /**
     Appends the chained handlers to the current Handlers
     All The chained closure will be called sequentially.

     - parameter chainedHandlers: the handlers to be chained.
     */
    open func appendChainedHandlers(_ chainedHandlers: Handlers) {
        self.appendCompletionHandler(chainedHandlers.on)
        self.appendProgressHandler(chainedHandlers.notify)


    }


    /**
     Designated initializer
     You Should pass a completion Handler (that's the best practice)
     It is optionnal for rare situations like (TaskGroup placeholder Handlers)
     - parameter completionHandler: the completion Handler

     - returns: the instance.
     */
    public required init(completionHandler: CompletionHandler?) {
        if let completionHandler=completionHandler {
            self._completionHandlers.append(completionHandler)
        }
    }

    /**
     A convenience initializer

     - parameter completionHandler:  the completion Handler
     - parameter progressionHandler: the progression Handler

     - returns: the instance
     */
    public convenience init(completionHandler: CompletionHandler?, progressionHandler: ProgressionHandler?) {
        self.init(completionHandler:completionHandler)
        if let progressionHandler=progressionHandler {
            self._progressionHandlers.append(progressionHandler)
        }
    }

    /**
     XPC adapter used to split closure in two parts
     - parameter composedHandler: the composed handler

     - returns: an instance of Handlers
     */
    public static func handlersFrom(_ composedHandler: @escaping ComposedHandler) -> Handlers {

        // Those handlers produce an adaptation
        // From the unique handler form
        // progress and completion handlers.

        let handlers=Handlers {(onCompletion) -> () in
            composedHandler(nil, onCompletion)
        }

        handlers.appendProgressHandler { (onProgression) -> () in
            composedHandler(onProgression, nil)
        }
        return handlers
    }

    /**

     We need to provide a unique handler to be compatible with the XPC context
     So we use an handler adapter that relays to the progress and completion handlers
     to mask the constraint.

     - returns: the composed Handler
     */
    open func composedHandler() -> ComposedHandler {
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
