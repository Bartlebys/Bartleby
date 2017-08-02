//
//  ManagedModel+ConsolidableProgression.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/11/2016.
//
//

import Foundation

 // #TODO Remove..?
/*

extension ManagedModel:ConsolidableProgression{


    /// Consolidate the progressions of children progression state by category
    /// Each unique task is responsible to compute a consistent currentPercentProgress
    ///
    /// - Parameter category: the category to be consolidated
    func consolidateProgression(for category:String){
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
                    progression.currentTaskIndex=currentTaskIndex/counter
                    progression.totalTaskCount=totalTaskCount/counter
                }
                progression.currentPercentProgress=currentPercent/Double(counter)
            }
        }
    }


    /// Return it own progression State
    ///
    /// - Parameter category: the category to be consolidated
    /// - Returns: return the progression state.
    func progressionState(for category:String)->Progression?{
        return nil
    }


    /// Return all the children Progression states to be consolidated
    ///
    /// - Parameter category: the category
    /// - Returns: the array of Progression states
    func childrensProgression(for category:String)->[Progression]?{
        return nil
    }
    
}
*/
