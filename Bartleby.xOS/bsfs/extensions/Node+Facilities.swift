//
//  Node+Facilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/11/2016.
//
//

import Foundation



extension Node{


    /// true if the node can be assembled
    public var isAssemblable:Bool{
        if let document=self.referentDocument{
            // Do we have all the required blocks?
            for uid in self.blocksUIDS{
                if let block = try? Bartleby.registredObjectByUID(uid) as Block{
                    if !document.blockIsAvailable(identifiedBy:block.digest){
                        return false
                    }
                }else{
                    return false
                }
            }
            return true
        }else{
            return false
        }
    }

    /// The parent box
    var box:Box?{
        if let owner:Box = self.relations(Relationship.ownedBy){
            return owner
        }else{
            return nil
        }
    }


    /// the currently referenced blocks
    var blocks:[Block]{
        if let ownedBlocks:[Block]=self.relations(Relationship.owns){
            return ownedBlocks
        }else{
            return [Block]()
        }
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
        }
        return nil
    }



    /// Return all the children Progression states to be consolidated
    ///
    /// - Parameter category: the category
    /// - Returns: the array of Progression states
    override func childrensProgression(for category:String)->[Progression]?{
        var progressions=[Progression]()
        for node in self.blocks{
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
