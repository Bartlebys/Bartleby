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
#elseif os(iOS)
#elseif os(watchOS)
#elseif os(tvOS)
#endif

public class PushPendingOperationsTask: Task, ConcreteTask {


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
     Adds all pending operation to the task group
     */
    public override func invoke() {
        super.invoke()
        if let jstring: ArgumentType = try? self.arguments() {
            let registryUID=jstring.string ?? Default.NO_UID
            if let document = Bartleby.sharedInstance.getDocumentByUID(registryUID){
                //  Append the operations tasks.
                do {
                    if let groupReference=self.group {
                        if let _: TasksGroup=groupReference.toLocalInstance() {
                            // Let's add all the operations to the group
                            for operation in document.operations.items {
                                try self.addOperationIfNecessary(operation)
                            }
                            let completion=Completion.successState()
                            self.complete(completion)
                        } else {
                            // No valid group
                            let completion=Completion.failureState(NSLocalizedString( "No valid task group found external reference is missing", tableName:"operations", comment:"No valid task group found external reference is missing"), statusCode: StatusOfCompletion.Precondition_Failed)
                            bprint(completion, file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                            self.complete(completion)
                        }
                    } else {
                        // No external reference
                        let completion=Completion.failureState(NSLocalizedString( "No external reference for TaskGroup", tableName:"operations", comment:"No external reference for TaskGroup"), statusCode: StatusOfCompletion.Precondition_Failed)
                        bprint(completion, file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                        self.complete(completion)
                    }
                } catch {
                    let completion=Completion.failureState(NSLocalizedString( "Unexpected Operation task appending error", tableName:"operations", comment:"Unexpected Commit pending changes error"), statusCode: StatusOfCompletion.Precondition_Failed)
                    bprint(completion, file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                    self.complete(completion)
                }

            } else {
                let completion=Completion.failureState(NSLocalizedString( "Document dataspace not found", tableName:"operations", comment:"Document dataspace not found"), statusCode: StatusOfCompletion.Precondition_Failed)
                bprint(completion, file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                self.complete(completion)
            }
        } else {
            let completion=Completion.failureState(NSLocalizedString( "Commit pending operations Invocation argument type missmatch", tableName:"operations", comment:"Task operation Invocation argument type missmatch"), statusCode: StatusOfCompletion.Precondition_Failed)
            bprint(completion, file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
            self.complete(completion)
        }
    }

    /**
     Adds the operation to the Push tasks if required.
     - parameter operation: operation description
     */
    public func addOperationIfNecessary(operation:Operation)throws{
        if let groupReference=self.group {
            if let group: TasksGroup=groupReference.toLocalInstance() {
                if !self.containsOperation(operation){
                    self._plannedOperations.append(operation)
                    let task=PushOperationTask(arguments:operation)
                    try group.appendChainedTask(task)
                }
            }
        }
    }



    // We keep track of the planned operations.
    // to allow to add other task to the group during its execution.
    private var _plannedOperations=[Operation]()

    public func containsOperation(operation:Operation)->Bool{
        return self._plannedOperations.contains({$0.UID==operation.UID})
    }
    
}