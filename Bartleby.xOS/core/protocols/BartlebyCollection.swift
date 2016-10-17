//
//  BartlebyCollection.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/10/2016.
//
//

import Foundation


// A collection without generic constraint of IterableCollectibleCollection
// @todo use type erasure?
public protocol BartlebyCollection:CollectibleCollection, SuperIterable, Committable{

}
