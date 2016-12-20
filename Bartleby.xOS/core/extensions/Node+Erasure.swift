//
//  Node+Erasure.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/12/2016.
//
//

import Foundation

extension Node{

    override open func erase(commit: Bool=true) throws {
        if let document=self.referentDocument{
            // Cancel any Pending Operation

            
        }else{
            throw DocumentError.instanceNotFound
        }
        try super.erase(commit:commit)
    }
}
