//
//  BartlebyDocument+UndoFacilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/07/2017.
//
//

import Foundation

extension BartlebyDocument{


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
    ///   - serializedManagedModels: the serialized managed Models instances
    ///   - undoActionName: the name of the action to undo
    ///   - doAfterAction: a closure called after undo / redo (e.g to update the UI)
    public func registerUndoChangesOn<TargetType,ModelType>(withTarget target: TargetType,
                                                            modelType:ModelType,
                                                            serializedManagedModels:[Data],
                                                            undoActionName:String,
                                                            doAfterAction:@escaping(TargetType)->(Swift.Void)) where TargetType : AnyObject , ModelType:Collectible {
        do{
            if let undoManager: UndoManager = self.undoManager{
                if undoManager.groupingLevel > 0 {
                    // Close the last group
                    undoManager.endUndoGrouping()
                    // Open a new group
                    undoManager.beginUndoGrouping()
                }
                var serializedData  = [Data]()
                for data in serializedManagedModels{
                    let deserializedModel:ModelType = try self.serializer.deserialize(data, register: false)
                    let currentModel:ManagedModel = try Bartleby.registredObjectByUID(deserializedModel.UID)
                    serializedData.append(currentModel.serialize())
                    try currentModel.mergeWith(deserializedModel)

                }
                undoManager.registerUndo(withTarget: self, handler: { (targetSelf) in
                    targetSelf.registerUndoChangesOn(withTarget:target,
                                                     modelType:modelType,
                                                     serializedManagedModels:serializedData,
                                                     undoActionName: undoActionName,
                                                     doAfterAction: doAfterAction)
                })
                if !undoManager.isUndoing {
                    undoManager.setActionName(undoActionName)
                }
                // Invoke the closure
                doAfterAction(target)
            }
        }catch{
            self.log("\(error)")
        }
    }

}
