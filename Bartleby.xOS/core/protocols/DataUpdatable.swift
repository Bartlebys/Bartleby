//
//  DataUpdatable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 28/12/2016.
//
//

import Foundation


public protocol DataUpdatable{

    /// Update an existing instance
    /// This approach is used by proxies.
    /// - Parameters:
    ///   - data: the data
    ///   - provisionChanges: should we provision the changes?
    /// - Returns: the Serialiable fully typed instance
    /// - Throws: ...
    func updateData(_ data: Data,provisionChanges:Bool) throws -> Serializable

}
