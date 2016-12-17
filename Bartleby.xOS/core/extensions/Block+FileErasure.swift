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

    override public func erase(commit: Bool) throws {
        // Delete files.
        try super.erase()
    }
    
}
