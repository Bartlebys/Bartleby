//
//  Block+Facilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/11/2016.
//
//

import Foundation

extension Block: ConsolidableProgression {
    public var node: Node? {
        if let owner: Node = self.firstRelation(Relationship.ownedBy) {
            return owner
        } else {
            return nil
        }
    }

    public var data: Data? {
        do {
            return try referentDocument?.dataForBlock(identifiedBy: digest)
        } catch {
            referentDocument?.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
        }
        return nil
    }

    /// Computes the block relative Path
    ///
    /// - Returns: the relative path
    public func blockRelativePath() -> String {
        return "/" + digest
    }

    // MARK: - ConsolidableProgression

    /// Return it own progression State
    ///
    /// - Parameter category: the category to be consolidated
    /// - Returns: return the progression state.
    public func progressionState(for category: String) -> Progression? {
        if category == Default.CATEGORY_DOWNLOADS {
            if downloadInProgress {
                return downloadProgression
            }
        } else {
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
    public func childrensProgression(for _: String) -> [Progression]? {
        return nil
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
