//
//  ReactiveAbstractTask.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/04/2016.
//  Copyright © 2016 Lylo Media Group SA. All rights reserved.
//

import Foundation

public class  AbstractReactiveTask: Task {

    /**
     The convenience intializer that must be overriden.
     You should always serialize the argument during initialization phasse!

     - parameter arguments: the arguments to be serialized

     - returns: the task instance.
     */
    convenience required public init (arguments: Serializable) {
        self.init()
        self.argumentsData=arguments.serialize()
    }

    // MARK: Sequential Tasks

    internal lazy var lastSequentialTask: Task=self

    /**
     Appends a task to the last sequential task

     - parameter task: the task to be sequentially added
     */
    public func appendSequentialTask(task: Task) {
        lastSequentialTask.addChildren(task)
        lastSequentialTask=task
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
                NSNotificationCenter.defaultCenter().postNotification(completionState.completionNotification)
            }
            self._reactiveHandlers=Handlers(completionHandler: onCompletion)
            self._reactiveHandlers!.addProgressHandler({ (progressionState) in
                NSNotificationCenter.defaultCenter().postNotification(progressionState.progressionNotification)
            })
            return self._reactiveHandlers!
        }
    }

}
