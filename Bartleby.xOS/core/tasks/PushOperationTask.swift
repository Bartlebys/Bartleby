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

    public class  PushOperationTask: Task, ConcreteTask {

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
        if let operation: ArgumentType = try? self.arguments() {
            if let serialized=operation.toDictionary {
                if let command = try? JSerializer.deserializeFromDictionary(serialized) {
                    if let jCommand=command as? JHTTPCommand {
                        // Push the command.
                        jCommand.push(sucessHandler: { (context) in
                            let completion=Completion.successStateFromJHTTPResponse(context)
                            completion.setResult(context)
                            bprint(completion, file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                            // Clean up the successful task.
                            let registryUID=operation.registryUID
                            if let document=Bartleby.sharedInstance.getDocumentByUID(registryUID){
                                bprint("Deleting \(operation.summary ?? operation.UID)", file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                                document.delete(operation)
                            }
                            self.complete(completion)
                        }, failureHandler: { (context) in
                            let completion=Completion.failureStateFromJHTTPResponse(context)
                            completion.setResult(context)
                            bprint(completion, file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                            self.complete(completion)
                        })
                    } else {
                        let completion=Completion.failureState(NSLocalizedString("Error of operation casting", tableName:"operations", comment: "Error of operation casting"), statusCode: StatusOfCompletion.Expectation_Failed)
                        bprint(completion, file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                        self.complete(completion)
                    }
                } else {
                    let completion=Completion.failureState(NSLocalizedString( "Error on operation deserialization", tableName:"operations", comment:  "Error on operation deserialization"), statusCode: StatusOfCompletion.Expectation_Failed)
                    bprint(completion, file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                    self.complete(completion)
                }
            } else {
                let completion=Completion.failureState(NSLocalizedString( "Error when converting the operation to dictionnary", tableName:"operations", comment: "Error when converting the operation to dictionnary"), statusCode: StatusOfCompletion.Precondition_Failed)
                bprint(completion, file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                self.complete(completion)
            }
        } else {
            let completion=Completion.failureState(NSLocalizedString( "Task operation Invocation argument type missmatch", tableName:"operations", comment:"Task operation Invocation argument type missmatch"), statusCode: StatusOfCompletion.Precondition_Failed)
            bprint(completion, file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
            self.complete(completion)
        }
    }

}
#endif