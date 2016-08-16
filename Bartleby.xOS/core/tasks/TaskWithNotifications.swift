//
//  TaskWithNotifications.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 27/05/2016.
//
//

import Foundation

// MARK: TaskWithNotifications

// Reactive Task that relay the completion and progression by NSNotifications
public class  TaskWithNotifications: Task, Reactive {

    // Universal type support
    override public class func typeName() -> String {
        return "TaskWithNotifications"
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
                self.relayCompletionState(completionState)
            }
            self._reactiveHandlers=Handlers(completionHandler: onCompletion)
            self._reactiveHandlers!.appendProgressHandler({ (progressionState) in
                self.relayProgressionState(progressionState)
            })
            return self._reactiveHandlers!
        }
    }

    public func relayCompletionState(state: Completion) {
        // We use the main queue to dispatch the completion state
        dispatch_async(dispatch_get_main_queue(), {
            NSNotificationCenter.defaultCenter().postNotification(state.completionNotification)
        })
    }


    public func relayProgressionState(state: Progression) {

        // We use the main queue to dispatch the progression state
        dispatch_async(dispatch_get_main_queue(), {
            NSNotificationCenter.defaultCenter().postNotification(state.progressionNotification)
        })
    }
    
}