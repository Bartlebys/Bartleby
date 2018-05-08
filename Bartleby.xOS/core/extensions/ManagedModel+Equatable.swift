//
//  ManagedModel+BaseImplementation.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/10/2016.
//
//

import Foundation

// MARK: - Equatable

// We have encountered serious QUIRKS With `Equatable` + OBJC runtime (with swift 4)
// Such inconsistencies or bugs where very difficult to debug o
// So we have decided to create global functions equalityOf(...)
// The Equatable implementation relies on this function

extension ManagedModel {
    public static func == (lhs: ManagedModel, rhs: ManagedModel) -> Bool {
        return equalityOf(lhs, rhs)
    }
}

public func equalityOf(_ lhs: ManagedModel?, _ rhs: ManagedModel?) -> Bool {
    let equality = lhs?.UID == rhs?.UID
    return equality
}
