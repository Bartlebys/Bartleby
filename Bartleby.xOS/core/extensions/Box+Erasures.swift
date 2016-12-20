//
//  Box+FileErasure.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/12/2016.
//
//

import Foundation


extension Box{

    /// We deal with Bsfs before deleting instances.

    override public func erase(commit: Bool=true) throws {
        if self.isMounted{
            if let document=self.referentDocument{
                // Un mount the Box
                document.bsfs.unMount(boxUID: self.UID, completed: { (completed) in })
            }else{
                throw DocumentError.instanceNotFound
            }
        }
        try super.erase(commit:commit)

    }
}
