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
     Pushes the operations
     */
    public override func invoke() throws {
        try super.invoke()
        if let operation: ArgumentType = try? self.arguments() {
            if let serialized=operation.toDictionary {
                if let command = try? JSerializer.deserializeFromDictionary(serialized) {
                    if let jCommand=command as? JHTTPCommand {
                        // Push the command.
                        jCommand.push(sucessHandler: { (context) in
                            let completion=Completion.successState()
                            completion.setResult(context as! JHTTPResponse)

                            // Clean up the successful task.
                            let spaceUID=operation.spaceUID
                            if let registry=Bartleby.sharedInstance.getRegistryByUID(spaceUID) {
                                registry.delete(operation)
                            }
                            // !!!  we should be able to throw.
                            if let _ = try? self.forward(completion) {
                                // SILENT
                            }
                            self.reactiveHandlers.on(completion)
                        }, failureHandler: { (context) in
                            let completion=Completion.failureState("", statusCode: completionStatusFromExitCodes(context.httpStatusCode))
                            completion.setResult(context as! JHTTPResponse)
                            // !!!  we should be able to throw.
                            if let _ = try? self.forward(completion) {
                                // SILENT
                            }
                            self.reactiveHandlers.on(completion)
                        })
                    } else {
                        self.reactiveHandlers.on(Completion.failureState("Casting error \(#file)", statusCode: CompletionStatus.Expectation_Failed))

                    }
                } else {
                    self.reactiveHandlers.on(Completion.failureState("Deserialization error \(#file)", statusCode: CompletionStatus.Expectation_Failed))
                }
            } else {
                self.reactiveHandlers.on(Completion.failureState("To dictionnary \(#file)", statusCode: CompletionStatus.Precondition_Failed))
            }
        } else {
            self.reactiveHandlers.on(Completion.failureState("Invocation argument type missmatch \(#file)", statusCode: CompletionStatus.Precondition_Failed))
        }
    }

}
#endif
