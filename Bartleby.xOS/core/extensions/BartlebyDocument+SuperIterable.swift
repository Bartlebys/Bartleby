//
//  Registry+SuperIterable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 23/06/2016.
//
//

import Foundation


extension BartlebyDocument:SuperIterable{

    // MARK : SuperIterable

    /**
     An iterator that permit dynamic approaches.
     The Registry ignore the real types.
     Currently we do not use SequenceType, Subscript, ...

     - parameter on: the closure
     */
    public func superIterate(_ on:@escaping (_ element: Collectible)->()) {
        // We want to super superIterate on each collection
        for (_, collection) in self._collections {
            collection.superIterate({ (element) in
                on(element: element)
            })
        }
    }
}
