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

            var erasableUIDS:[String]=[self.UID]

            // Erase recursively
            func __stageForErasure(_ UID:String)throws->(){
                if !erasableUIDS.contains(UID){
                    erasableUIDS.append(UID)
                    let target:ManagedModel = try Bartleby.registredObjectByUID(UID)
                    try target.erase(commit: commit)
                }
            }

            for relation in self._relations{
                switch relation.relationship {
                case Relation.Relationship.free:
                    // That's FreeDom! There is nothing to do
                    break
                case Relation.Relationship.owns:
                    try __stageForErasure(relation.UID)
                    break
                case Relation.Relationship.ownedBy:
                    // Remove the homologous relation
                    if let object:ManagedModel = try? Bartleby.registredObjectByUID(relation.UID){
                        object.removeRelation(Relation.Relationship.owns, to:self)
                    }
                    break
                case Relation.Relationship.coOwns:
                    // Count the owners to define if the object should be erased.
                    let m:[ManagedModel] = self.relations(Relation.Relationship.coOwns)
                    if m.count == 1{
                        try __stageForErasure(relation.UID)
                    }
                case Relation.Relationship.coOwnedBy:
                    // Remove the homologous relation
                    if let object:ManagedModel = try? Bartleby.registredObjectByUID(relation.UID){
                        object.removeRelation(Relation.Relationship.coOwns, to:self)
                    }
                    break
                case Relation.Relationship.fusional:
                    // Prevent Circularity
                    if let object:ManagedModel = try? Bartleby.registredObjectByUID(relation.UID){
                        object.removeRelation(Relation.Relationship.fusional, to:self)
                    }
                    try __stageForErasure(relation.UID)
                    break
                }
            }
            // Erase from managed collection
            if let collection=document.collectionByName(self.d_collectionName) as? CollectibleCollection {
                collection.removeObject(self, commit:commit)
            }

        }else{
            throw ErasingError.referentDocumentUndefined
        }
    }

}
