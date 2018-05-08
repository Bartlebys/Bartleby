//
//  SuperIterable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 20/07/2016.
//
//

import Foundation

public protocol SuperIterable {
    /**

     An iterator that permit dynamic approaches. (SequenceType uses Generics)

     - parameter on: the iteration closure

     - returns: return value description
     */
    func superIterate(_ on: @escaping (_ element: Collectible) -> Void)
}
