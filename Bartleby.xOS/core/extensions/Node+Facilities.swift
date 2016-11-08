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
    var isAssemblable:Bool{
        // Do we have all the required blocks?
        for uid in self.blocksUIDS{
            guard let _ = self.localBlocks.index(where: { $0.UID==uid }) else{
                return false
            }
        }
        return true
    }

    /// The parent box
    var box:Box?{
        if let boxUID=self.boxUID{
            if let box = try? Bartleby.registredObjectByUID(boxUID) as Box{
                return box
            }
        }
        return nil
    }


    /// the currently referenced local blocks
    var localBlocks:[Block]{
        if let d=self.document{
            return d.metadata.localBlocks.filter({ (block) -> Bool in
                return block.nodeUID==self.UID
            })
        }else{
            return [Block]()
        }
    }


    /// the currently referenced distant blocks
    var distantBlocks:[Block]{
        if let d=self.document{
            return d.blocks.filter({ (block) -> Bool in
                return block.nodeUID==self.UID
            })
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
        if category==Default.CATEGORY_DOWNLOADS {
            for node in self.distantBlocks{
                node.consolidateProgression(for: category)
                if let progression=node.progressionState(for: category){
                    progressions.append(progression)
                }
            }
        }else if category==Default.CATEGORY_UPLOADS {
            for node in self.localBlocks{
                node.consolidateProgression(for: category)
                if let progression=node.progressionState(for: category){
                    progressions.append(progression)
                }
            }
        }
        if progressions.count>0{
            return progressions
        }else{
            return nil
        }
    }
    
    
    
}
