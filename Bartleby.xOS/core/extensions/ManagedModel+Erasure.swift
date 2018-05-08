//
//  ManagedModel+Erasure.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 21/12/2016.
//
//
import Foundation

extension ManagedModel {
    /// Erases globally the instance and its dependent relations.
    /// Throws  ErasingError.referentDocumentUndefined
    /// You may invoke sanitizing routines on document.willErase (e.g:  purge files  Node, Block, ...)
    /// - Parameters:
    ///   - commit: set to true by default (we set to false only  not to commit triggered Deletion)
    ///   - eraserUID: the eraser UID (used by recursive calls to determinate if co-owned children must be erased)
    /// - Returns: N/A
    public func erase(commit: Bool = true, eraserUID: String = Default.NO_UID) throws {
        if let document = self.referentDocument {
            // #TODO write specific Unit test for real cases validation (in BSFS and YD)

            // Co-ownership (used by recursive calls)
            // Preserves ownees with multiple Owners
            if ownedBy.count > 1 && eraserUID != Default.NO_UID {
                if let idx = self.ownedBy.index(of: eraserUID) {
                    // Remove the homologous relation
                    if let owner: ManagedModel = try? Bartleby.registredObjectByUID(eraserUID) {
                        owner.removeRelation(Relationship.owns, to: self)
                        return
                    }
                }
            }

            // Call the overridable cleaning method
            document.willErase(self)

            // Erase from managed collection first
            // The collection may register the homologous action in the document UndoManager
            if let collection = document.collectionByName(self.d_collectionName) {
                collection.removeObject(self, commit: commit)
            }

            var erasableUIDS: [String] = [self.UID]

            // Erase recursively
            func __stageForErasure(_ objectUID: String, eraserUID _: String = Default.NO_UID) throws {
                if !erasableUIDS.contains(objectUID) {
                    erasableUIDS.append(objectUID)
                    let target: ManagedModel = try Bartleby.registredObjectByUID(objectUID)
                    try target.erase(commit: commit)
                }
            }

            try owns.forEach({ objectUID in
                try __stageForErasure(objectUID, eraserUID: self.UID)
            })

            ownedBy.forEach({ ownerObjectUID in
                // Remove the homologous relation
                if let owner: ManagedModel = try? Bartleby.registredObjectByUID(ownerObjectUID) {
                    owner.removeRelation(Relationship.owns, to: self)
                }
            })

            // What should we do for free relations?
            // That's FreeDom! There is nothing to do with self.free

        } else {
            throw ErasingError.referentDocumentUndefined
        }
    }
}
