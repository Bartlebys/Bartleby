//
//  Node+Facilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/11/2016.
//
//

import Foundation

extension Node: ConsolidableProgression {
    public var filePath: String {
        if let document = self.referentDocument {
            return document.bsfs.assemblyPath(for: self)
        }
        return Default.NO_PATH
    }

    public var isAssembled: Bool {
        if let document = self.referentDocument {
            return document.bsfs.isAssembled(self)
        }
        return false
    }

    /// true if the node can be assembled
    public var isAssemblable: Bool {
        if let document = self.referentDocument {
            let blocks: [Block] = relations(Relationship.owns)
            if blocks.count != numberOfBlocks {
                return false
            }
            // Do we have all the required blocks?
            for block in blocks {
                if !document.blockIsAvailable(identifiedBy: block.digest) {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }

    /// The parent box
    public var box: Box? {
        if let owner: Box = self.firstRelation(Relationship.ownedBy) {
            return owner
        } else {
            return nil
        }
    }

    public func addBlock(_ block: Block) {
        declaresOwnership(of: block)
        numberOfBlocks += 1
    }

    /// the currently referenced blocks
    public var blocks: [Block] {
        let ownedBlocks: [Block] = relations(Relationship.owns)
        return ownedBlocks
    }

    // MARK: ConsolidableProgression

    /// Return it own progression State
    ///
    /// - Parameter category: the category to be consolidated
    /// - Returns: return the progression state.
    public func progressionState(for category: String) -> Progression? {
        if category == Default.CATEGORY_DOWNLOADS {
            if downloadInProgress {
                return downloadProgression
            }
        } else if category == Default.CATEGORY_UPLOADS {
            if uploadInProgress {
                return uploadProgression
            }
        }
        return nil
    }

    /// Return all the children Progression states to be consolidated
    ///
    /// - Parameter category: the category
    /// - Returns: the array of Progression states
    public func childrensProgression(for category: String) -> [Progression]? {
        var progressions = [Progression]()
        for node in blocks {
            node.consolidateProgression(for: category)
            if let progression = node.progressionState(for: category) {
                progressions.append(progression)
            }
        }
        if progressions.count > 0 {
            return progressions
        } else {
            return nil
        }
    }

    /// Consolidate the progressions of children progression state by category
    /// Each unique task is responsible to compute a consistent currentPercentProgress
    ///
    /// - Parameter category: the category to be consolidated
    public func consolidateProgression(for category: String) {
        if let progression = self.progressionState(for: category) {
            if let childrensProgressions = self.childrensProgression(for: category) {
                var counter = 0
                var currentPercent: Double = 0
                var currentTaskIndex = 0
                var totalTaskCount = 0
                for childProgression in childrensProgressions {
                    counter += 1
                    currentPercent += childProgression.currentPercentProgress
                    currentTaskIndex += childProgression.currentTaskIndex
                    totalTaskCount += childProgression.totalTaskCount
                    // If there is nothing to do let's say it's done :)
                    if childProgression.currentTaskIndex == 0 && childProgression.totalTaskCount == 0 {
                        currentPercent += 100
                    }
                }
                progression.quietChanges {
                    progression.currentTaskIndex = currentTaskIndex / counter
                    progression.totalTaskCount = totalTaskCount / counter
                }
                progression.currentPercentProgress = currentPercent / Double(counter)
            }
        }
    }
}
