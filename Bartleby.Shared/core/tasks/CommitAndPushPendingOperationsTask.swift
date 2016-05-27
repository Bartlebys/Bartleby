//
//  CommitPendingOperationsTask.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 25/05/2016.
//
//

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


public class  CommitAndPushPendingOperationsTask: Task, ConcreteTask {


        public typealias ArgumentType=JString

        // Universal type support
        override public class func typeName() -> String {
            return "CommitPendingOperationTask"
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
            #1 this task commit the pending tasks.
            #2 Optimize the operations
            #3 Append the Push operation tasks
         */
        public override func invoke() {
            super.invoke()
            if let jstring: ArgumentType = try? self.arguments() {
                let spaceUID=jstring.string ?? Default.NO_UID
                    if let document = Bartleby.sharedInstance.getRegistryByUID(spaceUID) as? BartlebyDocument {

                        // #1 commit the pending Changes
                        do {
                            try document.commitPendingChanges()
                        } catch {
                            let completion=Completion.failureState(NSLocalizedString( "Unexpected Commit pending changes error", tableName:"operations", comment:"Unexpected Commit pending changes error"), statusCode: CompletionStatus.Precondition_Failed)
                            bprint(completion, file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                            self.complete(completion)
                        }

                        // #2 Optimize the operations
                        document.optimizeOperations()

                        // #3 Append the operations tasks.
                        do {
                            if let groupReference=self.group {
                                if let group: TasksGroup=groupReference.toLocalInstance() {
                                    // Let's add all the operations to the group.
                                    // #2 add the operations tasks.
                                    for operation in document.operations.items {

                                        // @bpds DO NOT RE ADD OPERATION ALLREADY PLANIFIED
                                        let task=PushOperationTask(arguments:operation)
                                        try group.appendChainedTask(task)
                                    }
                                    let completion=Completion.successState()
                                    self.complete(completion)
                                } else {
                                    // No valid group
                                    let completion=Completion.failureState(NSLocalizedString( "No valid task group found external reference is missing", tableName:"operations", comment:"No valid task group found external reference is missing"), statusCode: CompletionStatus.Precondition_Failed)
                                    bprint(completion, file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                                    self.complete(completion)
                                }
                            } else {
                                // No external reference
                                let completion=Completion.failureState(NSLocalizedString( "No external reference for TaskGroup", tableName:"operations", comment:"No external reference for TaskGroup"), statusCode: CompletionStatus.Precondition_Failed)
                                bprint(completion, file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                                self.complete(completion)
                            }
                        } catch {
                            let completion=Completion.failureState(NSLocalizedString( "Unexpected Operation task appending error", tableName:"operations", comment:"Unexpected Commit pending changes error"), statusCode: CompletionStatus.Precondition_Failed)
                            bprint(completion, file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                            self.complete(completion)
                        }

                    } else {
                        let completion=Completion.failureState(NSLocalizedString( "Document dataspace not found", tableName:"operations", comment:"Document dataspace not found"), statusCode: CompletionStatus.Precondition_Failed)
                        bprint(completion, file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                        self.complete(completion)
                }
            } else {
                let completion=Completion.failureState(NSLocalizedString( "Commit pending operations Invocation argument type missmatch", tableName:"operations", comment:"Task operation Invocation argument type missmatch"), statusCode: CompletionStatus.Precondition_Failed)
                bprint(completion, file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                self.complete(completion)
            }
        }

    }
#endif
