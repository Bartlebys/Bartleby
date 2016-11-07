//
//  Box+Facilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/11/2016.
//
//

import Foundation


extension Box{

    ///
    /// baseFolder/boxes/<boxUID>
    ///
    /// - Returns: the mounted folder path
    func absoluteFolderPath()->String{
        if let bsfs=self.document?.bsfs{
            return bsfs.boxesFolderPath()+self.UID
        }else{
            return Default.NO_PATH
        }
    }


    /// Returns the currently referenced local nodes
    ///
    /// - Returns: the blocks
    func localNodes()->[Node]{
        if let d=self.document{
            return d.metadata.localNodes.filter({ (node) -> Bool in
                return node.boxUID==self.UID
            })
        }else{
            return [Node]()
        }
    }

    /// Returns the currently referenced distant nodes
    ///
    /// - Returns: the blocks
    func distantNodes()->[Node]{
        if let d=self.document{
            return d.nodes.filter({ (node) -> Bool in
                return node.boxUID==self.UID
            })
        }else{
            return [Node]()
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
        }else{
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
        if category==Default.CATEGORY_DOWNLOADS{
            for node in self.distantNodes(){
                node.consolidateProgression(for: category)
                if let progression=node.progressionState(for: category){
                    progressions.append(progression)
                }
            }
        }else{
            for node in self.localNodes(){
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
