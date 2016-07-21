//
//  ReactiveTask.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/04/2016.
//  Copyright © 2016 Lylo Media Group SA. All rights reserved.
//

import Foundation

// MARK: ReactiveTask

// A Reactive Task that allows to append handlers.
@objc(ReactiveTask) public class  ReactiveTask: Task, Reactive {

    // Universal type support
    override public class func typeName() -> String {
        return "ReactiveTask"
    }

    // The reactive Handlers
    public var reactiveHandlers: Handlers=Handlers.withoutCompletion()
}
