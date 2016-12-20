//
//  Block+Facilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/11/2016.
//
//

import Foundation

extension Block{


    public var node:Node?{
        if let owner:Node = self.firstRelation(Relation.Relationship.ownedBy){
             return owner
        }else{
            return nil
        }
    }


    var data:Data?{
        do{
            return try self.referentDocument?.dataForBlock(identifiedBy: self.digest)
        }catch {
             self.referentDocument?.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
        }
        return nil
    }



    /// Computes the block relative Path
    ///
    /// - Returns: the relative path
    public func blockRelativePath()->String{
        return "/"+self.digest
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
