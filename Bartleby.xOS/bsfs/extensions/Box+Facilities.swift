//
//  Box+Facilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/11/2016.
//
//

import Foundation


extension Box{


    /// The nodes folder path
    public var nodesFolderPath:String{
        if let bsfs=self.referentDocument?.bsfs{
            return bsfs.boxesFolderPath+"/"+self.UID
        }else{
            return Default.NO_PATH
        }
    }

    /// the currently referenced  nodes
    var nodes:[Node]{
        let ownedNodes:[Node]=self.relations(Relation.Relationship.owns)
        return ownedNodes
    }


    // MARK: ConsolidableProgression


    /// Return it own progression State
    ///
    /// - Parameter category: the category to be consolidated
    /// - Returns: return the progression state.
    override func progressionState(for category:String)->Progression?{
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
    override func childrensProgression(for category:String)->[Progression]?{
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
    
    
    
}
