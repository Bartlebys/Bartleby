//
//  ManagedModel+Erasure.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 21/12/2016.
//
//

import Foundation


extension ManagedModel{

    /// Erases globally the instance and its dependent relations.
    /// Throws ErasingError and DocumentError
    /// You may Override this method to purge files (e.g: Node, Block, ...)
    /// Erase the collectible instance (and its dependent relations)
    /// - Parameter commit: set to true by default (we do not commit triggered Deletion)
    open func erase(commit:Bool=true)throws->(){
        if let document=self.referentDocument{

            // Call the overridable cleaning method
            document.willErase(self)

            // Erase from managed collection first
            // The collection may register the homologous action in the document UndoManager
            if let collection=document.collectionByName(self.d_collectionName) {
                collection.removeObject(self, commit:commit)
            }

            var erasableUIDS:[String]=[self.UID]

            // Erase recursively
            func __stageForErasure(_ objectUID:String)throws->(){
                if !erasableUIDS.contains(objectUID){
                    erasableUIDS.append(objectUID)
                    let target:ManagedModel = try Bartleby.registredObjectByUID(objectUID)
                    try target.erase(commit: commit)
                }
            }

            try self.owns.forEach({ (objectUID) in
                try __stageForErasure(objectUID)
            })

            // That's FreeDom! There is nothing to do with self.free

            self.ownedBy.forEach({ (objectUID) in
                // Remove the homologous relation
                if let object:ManagedModel = try? Bartleby.registredObjectByUID(objectUID){
                    object.removeRelation(Relationship.owns, to:self)
                }
            })


        }else{
            throw ErasingError.referentDocumentUndefined
        }
    }
    
}
