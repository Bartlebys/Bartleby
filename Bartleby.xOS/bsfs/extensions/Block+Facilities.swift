//
//  Block+Facilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/11/2016.
//
//

import Foundation

extension Block{


    /// the block path baseFolder/blocks/<relatifvePath>/shA1
    var absolutePath:String{
        if let bsfs=self.document?.bsfs{
            return bsfs.blocksFolderPath+"/"+self.blockRelativePath()
        }else{
            return Default.NO_PATH
        }
    }

    var url:URL{
        return URL(fileURLWithPath: self.absolutePath)
    }


    public var node:Node?{
       return try? Bartleby.registredObjectByUID(self.nodeUID) as Node
    }


    /// Computes the block relative Path
    ///
    /// - Returns: the relative path
    public func blockRelativePath()->String{
        // Generate a Classified Block Tree.
        let c1=PString.substr(digest, 0, 1)
        let c2=PString.substr(digest, 1, 1)
        let c3=PString.substr(digest, 2, 1)
        return "\(c1)/\(c2)/\(c3)/+\(digest)"
    }


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

}
