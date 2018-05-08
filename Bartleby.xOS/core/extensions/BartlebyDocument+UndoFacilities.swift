//
//  BartlebyDocument+UndoFacilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/07/2017.
//
//

import Foundation

extension BartlebyDocument {
    /// This extenion Allows to record undo action using the serialized state of ManagedModels
    /// It is a very powerful technique to implement undo redo
    ///
    /// How to use it ?
    ///
    ///     1- call registerUndoChangesOn() - With the serialized states.
    ///     2- Then modify the instances.
    ///     That's all folks...
    ///
    /// - Parameters:
    ///   - serializedRelationalObjects: the serialized managed Models instances
    ///   - undoActionName: the name of the action to undo
    ///   - doAfterAction: a closure called after undo / redo (e.g to update the UI)
    public func registerUndoChangesOn<TargetType, ModelType>(withTarget target: TargetType,
                                                             modelType: ModelType.Type,
                                                             serializedRelationalObjects: [SerializedRelationalObject],
                                                             undoActionName: String,
                                                             doAfterAction: @escaping (TargetType) -> (Swift.Void)) where TargetType: AnyObject, ModelType: Collectible {
        do {
            if let undoManager: UndoManager = self.undoManager {
                if undoManager.groupingLevel > 0 {
                    // Close the last group
                    undoManager.endUndoGrouping()
                    // Open a new group
                    undoManager.beginUndoGrouping()
                }
                // @TODO control that implementation
                for serialized in serializedRelationalObjects {
                    let deserializedModel: ModelType = try serialized.instanciate()
                    let currentModel: ModelType = try Bartleby.registredObjectByUID(deserializedModel.UID)
                    try currentModel.mergeWith(deserializedModel)
                }
                undoManager.registerUndo(withTarget: self, handler: { targetSelf in
                    targetSelf.registerUndoChangesOn(withTarget: target,
                                                     modelType: modelType,
                                                     serializedRelationalObjects: serializedRelationalObjects,
                                                     undoActionName: undoActionName,
                                                     doAfterAction: doAfterAction)
                    if Bartleby.configuration.DEVELOPER_MODE {
                        Swift.print("Invocation of doAfterAction on \(target)")
                    }
                    // Invoke the closure
                    doAfterAction(target)
                })
                if !undoManager.isUndoing {
                    undoManager.setActionName(undoActionName)
                }
            }
        } catch {
            log("\(error)")
        }
    }
}
