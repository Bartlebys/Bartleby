//
//  RelayingTask.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 27/05/2016.
//
//

import Foundation


// MARK: RelayingTask

// A Reactive Task that relays it completion an progression.
public class  RelayingTask: Task, Reactive {

    // Universal type support
    override public class func typeName() -> String {
        return "RelayingTask"
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
                self.complete(completionState)
            }
            self._reactiveHandlers=Handlers(completionHandler: onCompletion)
            self._reactiveHandlers!.appendProgressHandler({ (progressionState) in
                self.transmit(progressionState)
            })
            return self._reactiveHandlers!
        }
    }
}
