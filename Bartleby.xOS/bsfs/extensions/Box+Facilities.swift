//
//  Box+Facilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/11/2016.
//
//

import Foundation

extension Box:ConsolidableProgression{


    /// The nodes folder path
    public var nodesFolderPath:String{
        if let bsfs=self.referentDocument?.bsfs{
            return bsfs.boxesFolderPath+"/"+self.UID
        }else{
            return Default.NO_PATH
        }
    }

    /// the currently referenced  nodes
    public var nodes:[Node]{
        let ownedNodes:[Node]=self.relations(Relationship.owns)
        return ownedNodes
    }


    // MARK: - ConsolidableProgression


    /// Return it own progression State
    ///
    /// - Parameter category: the category to be consolidated
    /// - Returns: return the progression state.
    @objc public func progressionState(for category:String)->Progression?{
        if category==Default.CATEGORY_DOWNLOADS{
            if downloadInProgress{
                return self.downloadProgression
            }
        }else if category==Default.CATEGORY_UPLOADS{
            if uploadInProgress{
                return self.uploadProgression
            }
        }else if category==Default.CATEGORY_ASSEMBLIES{
            if assemblyInProgress{
                return self.assemblyProgression
            }
        }
        return nil
    }


    /// Return all the children Progression states to be consolidated
    ///
    /// - Parameter category: the category
    /// - Returns: the array of Progression states
    public func childrensProgression(for category:String)->[Progression]?{
        var progressions=[Progression]()
        for node in self.nodes{
            node.consolidateProgression(for: category)
            if let progression=node.progressionState(for: category){
                progressions.append(progression)
            }
        }
        if progressions.count>0{
            return progressions
        }else{
            return nil
        }
    }

    /// Consolidate the progressions of children progression state by category
    /// Each unique task is responsible to compute a consistent currentPercentProgress
    ///
    /// - Parameter category: the category to be consolidated
    public func consolidateProgression(for category:String){
        if let progression = self.progressionState(for: category){
            if let childrensProgressions=self.childrensProgression(for: category){
                var counter=0
                var currentPercent:Double=0
                var currentTaskIndex=0
                var totalTaskCount=0
                for childProgression in childrensProgressions{
                    counter += 1
                    currentPercent += childProgression.currentPercentProgress
                    currentTaskIndex += childProgression.currentTaskIndex
                    totalTaskCount += childProgression.totalTaskCount
                    // If there is nothing to do let's say it's done :)
                    if childProgression.currentTaskIndex==0 && childProgression.totalTaskCount==0{
                        currentPercent += 100
                    }
                }
                progression.quietChanges{
                    progression.currentTaskIndex = currentTaskIndex/counter
                    progression.totalTaskCount = totalTaskCount/counter
                }
                progression.currentPercentProgress = counter > 0 ? currentPercent / Double(counter) : -1
            }
        }
    }

    
    
}
