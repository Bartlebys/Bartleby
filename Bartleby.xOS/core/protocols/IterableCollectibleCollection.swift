//
//  IterableCollectibleCollection.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/10/2016.
//
//

import Foundation


// We add SequenceType Support to the collection Type.
// 'SequenceType' can only be used as a generic constraint because it has Self or associated type requirements
// So we use IterableCollectibleCollection for concrete  collection implementation and reference in the Registry `internal var _collections=[String:Collection]()`
public protocol IterableCollectibleCollection:BartlebyCollection,Collection{

}
