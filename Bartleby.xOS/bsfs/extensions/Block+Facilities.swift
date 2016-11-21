//
//  Block+Facilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/11/2016.
//
//

import Foundation

extension Block{


    /// If embedded /digest
    /// the block path baseFolder/blocks/<relatifvePath>/digest
    var absolutePath:String{
        if let bsfs=self.document?.bsfs{
            if self.embedded{
                return self.blockRelativePath()
            }else{
                return bsfs.blocksFolderPath+self.blockRelativePath()
            }

        }else{
            return Default.NO_PATH
        }
    }


    public var node:Node?{
        return try? Bartleby.registredObjectByUID(self.nodeUID) as Node
    }


    var data:Data?{
        do{
            if self.embedded{
                return try self.document?.dataForBlock(identifiedBy: self.digest)
            }else{
                let url=URL(fileURLWithPath: self.absolutePath)
                return try Data(contentsOf: url)
            }
        }catch {
             self.document?.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
        }
        return nil
    }



    /// Computes the block relative Path
    ///
    /// - Returns: the relative path
    public func blockRelativePath()->String{
        if self.embedded{
            return "/"+self.digest
        }else{
            // Generate a Classified Block Tree.
            let c1=PString.substr(digest, 0, 1)
            let c2=PString.substr(digest, 1, 1)
            let c3=PString.substr(digest, 2, 1)
            return "/\(c1)/\(c2)/\(c3)/+\(digest)"
        }
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
