//
//  ReactiveAbstractTask.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/04/2016.
//  Copyright © 2016 Lylo Media Group SA. All rights reserved.
//

import Foundation

enum ReactiveTaskError: ErrorType {
    case MissingTaskGroup
}

@objc(ReactiveTask) public class  ReactiveTask: Task {

    /**
     The convenience intializer that must be overriden.
     You should always serialize the argument during initialization phasse!

     - parameter arguments: the arguments to be serialized

     - returns: the task instance.
     */
    convenience required public init (arguments: Collectible) {
        self.init()
        self.configureWithArguments(arguments)
    }

    // MARK: Sequential Tasks

    private lazy var _lastSequentialTask: Task = self

    /**
     Appends a task to the last sequential task

     - parameter task: the task to be sequentially added
     */
    public func appendSequentialTask(task: Task) throws {
        if self._lastSequentialTask.group==nil {
            throw ReactiveTaskError.MissingTaskGroup
        }
        self._lastSequentialTask.addChildren(task)
        self._lastSequentialTask=task
    }


    // MARK: Reactive Handlers

    private var _reactiveHandlers: Handlers?

    // The reactive Handlers
    public var reactiveHandlers: Handlers {
        get {
            if let _ = _reactiveHandlers {
                return self._reactiveHandlers!
            }
            let onCompletion: CompletionHandler = { (completionState) in
                // We forward the completion to the scheduler.
                self.forward(completionState)
                // We use the main queue to dispatch the completion state
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotification(completionState.completionNotification)
                })
            }
            self._reactiveHandlers=Handlers(completionHandler: onCompletion)
            self._reactiveHandlers!.addProgressHandler({ (progressionState) in
                 // We use the main queue to dispatch the progression state
                 dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotification(progressionState.progressionNotification)
                })
            })
            return self._reactiveHandlers!
        }
    }

}
