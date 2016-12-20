//
//  Block+FileErasure.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/12/2016.
//
//

import Foundation


extension Block{

    /// We deal with Bsfs before deleting instances.

    override open func erase(commit: Bool=true) throws {
        if let document=self.referentDocument{
            // Delete files.
            document.bsfs.deleteBlockFile(self)
        }else{
            throw DocumentError.instanceNotFound
        }
        try super.erase(commit:commit)
    }
    
}
