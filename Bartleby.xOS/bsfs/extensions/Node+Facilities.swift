//
//  Node+Facilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/11/2016.
//
//

import Foundation



public extension Node{

    public var filePath:String{
        if let document=self.referentDocument{
            return document.bsfs.assemblyPath(for: self)
        }
        return Default.NO_PATH
    }

    public var isAssembled:Bool{
        if let document=self.referentDocument{
            return document.bsfs.isAssembled(self)
        }
        return false
    }

    /// true if the node can be assembled
    public var isAssemblable:Bool{
        if let document=self.referentDocument{
            let blocks:[Block] = self.relations(Relationship.owns)
            if blocks.count != self.numberOfBlocks{
                return false
            }
            // Do we have all the required blocks?
            for block in blocks{
                if !document.blockIsAvailable(identifiedBy:block.digest){
                    return false
                }
            }
            return true
        }else{
            return false
        }
    }

    /// The parent box
    public var box:Box?{
        if let owner:Box = self.firstRelation(Relationship.ownedBy){
            return owner
        }else{
            return nil
        }
    }


    public func addBlock(_ block:Block){
        self.declaresOwnership(of: block)
        self.numberOfBlocks += 1
    }


    /// the currently referenced blocks
    public var blocks:[Block]{
        let ownedBlocks:[Block]=self.relations(Relationship.owns)
        return ownedBlocks
    }


    // MARK: ConsolidableProgression


    /// Return it own progression State
    ///
    /// - Parameter category: the category to be consolidated
    /// - Returns: return the progression state.
    @objc override public func progressionState(for category:String)->Progression?{
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
    @objc override public func childrensProgression(for category:String)->[Progression]?{
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
