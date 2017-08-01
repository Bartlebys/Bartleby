//
//  ManagedModel+BaseImplementation.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/10/2016.
//
//

import Foundation

// MARK: - Equatable

public func ==(lhs: ManagedModel, rhs: ManagedModel) -> Bool {
    return lhs.UID==rhs.UID
}
