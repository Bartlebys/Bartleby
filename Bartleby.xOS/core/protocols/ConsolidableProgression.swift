//
//  ConsolidableProgression.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/11/2016.
//
//

import Foundation


protocol ConsolidableProgression {


    /// Consolidate the progressions of children progression state by category in its own progression State
    /// Each unique task is responsible to compute a consistent currentPercentProgress
    ///
    /// - Parameter category: the category to be consolidated
    func consolidateProgression(for category:String)


    /// Return it own progression State
    ///
    /// - Parameter category: the category to be consolidated
    /// - Returns: return the progression state.
    func progressionState(for category:String)->Progression?


    /// Return all the children Progression states to be consolidated
    ///
    /// - Parameter category: the category
    /// - Returns: the array of Progression states
    func childrensProgression(for category:String)->[Progression]?
    
}
