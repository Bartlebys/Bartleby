//
//  ChangesInspectable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/10/2016.
//
//

import Foundation

public protocol ChangesInspectable {
    var changedKeys: [KeyedChanges] { get set }
}
