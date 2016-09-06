//
//  PushOperationTask.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 05/05/2016.

import Foundation

#if os(OSX)
    import AppKit
    import CoreMedia
#elseif os(iOS)
#elseif os(watchOS)
#elseif os(tvOS)
#endif

public class PushOperationTask: Task, ConcreteTask {

    public typealias ArgumentType=Operation

    // Universal type support
    override public class func typeName() -> String {
        return "PushOperationTask"
    }

    /**
     This initializer **MUST:** call configureWithArguments
     - parameter arguments: the arguments

     - returns: a well initialized task.
     */
    convenience required public init(arguments: ArgumentType) {
        self.init()
        self.configureWithArguments(arguments)
        self.summary=arguments.summary // Relay the summary
    }

    /**
     Pushes the operations and deletes the operation object on success.
     */
    public override func invoke() {
        super.invoke()
    }
    
}

