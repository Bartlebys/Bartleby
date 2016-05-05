//
//  Registry+Operations.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 05/05/2016.
//
//

import Foundation


extension Registry {
    // MARK: - Operations


    /**
     Pushes the operation

     - parameter operations: the provionned operations
     - parameter iterator:   the iteraror reference for recursive calls.
     */
    private func _pushChainedOperation(operations: [Operation], inout iterator: IndexingGenerator<[Operation]>) {
        if let currentOperation=iterator.next() {
            self.pushOperation(currentOperation, sucessHandler: { (context) -> () in
                if let operationDictionary=currentOperation.toDictionary {
                    if let referenceName=operationDictionary[Default.REFERENCE_NAME_KEY],
                        uid=operationDictionary[Default.UID_KEY] {
                        self.delete(currentOperation)
                        do {
                            let ic: OperationsCollectionController = try self.getCollection()
                            bprint("\(ic.UID)->OPCOUNT_AFTER_EXEC=\(ic.items.count) \(referenceName) \(uid)", file: #file, function: #function, line: #line)
                        } catch {
                            bprint("OperationsCollectionController getCollection \(error)", file: #file, function: #function, line: #line)
                        }
                    }
                }
                Bartleby.executeAfter(Bartleby.configuration.DELAY_BETWEEN_OPERATIONS_IN_SECONDS, closure: {
                    self._pushChainedOperation(operations, iterator: &iterator)
                })
                }, failureHandler: { (context) -> () in
                    // Stop the chain
            })
        }
    }

    /**
     Pushes the operations
     Is a wrapper that pushes chained operations
     - parameter operations: the operations
     */
    public func pushOperations(operations: [Operation]) {
        var iterator=operations.generate()
        self._pushChainedOperation(operations, iterator: &iterator)
    }



    /**
     Pushes a unique operation
     On success the operation is deleted.
     - parameter operation: the operation
     */
    public func pushOperation(operation: Operation) {
        self.pushOperation(operation, sucessHandler: { (context) -> () in
            self.delete(operation)
        }) { (context) -> () in

        }
    }

    /**
     Pushes an operation with success and failure handlers

     - parameter operation: the operation
     - parameter success:   the success handler
     - parameter failure:   the failure handler
     */
    public func pushOperation(operation: Operation, sucessHandler success:(context: HTTPResponse)->(), failureHandler failure:(context: HTTPResponse)->()) {
        if let serialized=operation.toDictionary {
            if let command=self.serializer.deserializeFromDictionary(serialized) as? JHTTPCommand {
                command.push(sucessHandler:success, failureHandler:failure)
            } else {
                //TODO: @bpds what should be done
            }
        }
    }


    /**

     Deletes, aggregates and generates operations to reduce the push and subscribe load.

     - parameter operations: the operations

     - returns: the reduced operations + a trigger
     */
    public func optimizeOperations(operations: [Operation]) -> [Operation] {
        /*
         var toBeDeleted=[Operation]()
         var groups=[String:[Operation]]()
         for operation in operations{

         }*/

        // TODO: @bpds Append a Trigger

        return operations
    }


    // MARK: markAsDistributed

    /**
     Marks the instance as distributed (on Push).

     - parameter instances: the collectible instances
     */
    public func markAsDistributed<T: Collectible>(inout instance: T) {
        instance.distributed=true
    }

    /**
     Marks the instances as distributed  (on Push).

     - parameter instances: the collectible instances
     */
    public func markAsDistributed<T: Collectible>(inout instances: [T]) {
        for var instance in instances {
            instance.distributed=true
        }
    }


}
