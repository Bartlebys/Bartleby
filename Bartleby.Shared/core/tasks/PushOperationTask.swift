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

#if !DUSE_EMBEDDED_MODULES

public class  PushOperationTask: ReactiveTask, ConcreteTask {

    // Universal type support
    override public class func typeName() -> String {
        return "PushOperationTask"
    }


    /**
     This initializer **MUST:** call configureWithArguments
     - parameter arguments: the arguments

     - returns: a well initialized task.
     */
    convenience required public init (arguments: Collectible) {
        self.init()
        self.configureWithArguments(arguments)
    }

    /**
     Pushes the operations
     */
    public func invoke() {
        if let arguments: Operation = try? self.arguments() {
            let operation=arguments
            if let serialized=operation.toDictionary {
                //dispatch_async(dispatch_get_main_queue(), {
                    if let command=JSerializer.deserializeFromDictionary(serialized) as? JHTTPCommand {
                        command.push(sucessHandler: { (context) in
                            let completion=Completion.successState()
                            completion.setResult(context as! JHTTPResponse)
                            self.reactiveHandlers.on(completion)

                            }, failureHandler: { (context) in
                                let completion=Completion.failureState("", statusCode: completionStatusFromExitCodes(context.httpStatusCode))
                                completion.setResult(context as! JHTTPResponse)
                                self.reactiveHandlers.on(completion)
                        })
                    } else {
                        self.reactiveHandlers.on(Completion.failureState("Deserialization error \(#file)", statusCode: CompletionStatus.Expectation_Failed))
                    }

               // })
            }

        } else {
            self.reactiveHandlers.on(Completion.failureState("Invocation argument type missmatch \(#file)", statusCode: CompletionStatus.Precondition_Failed))
        }
    }

}
#endif
