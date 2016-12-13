//
//  ManagedModel+BaseImplementation.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/10/2016.
//
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif


// MARK: - Equatable

public func ==(lhs: ManagedModel, rhs: ManagedModel) -> Bool {
    return lhs.UID==rhs.UID
}
