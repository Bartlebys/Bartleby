//
//  NodeAccessor.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 08/11/2016.
//
//

import Foundation

/// Should be implemented by anything that want to acceed to a node.
/// This protocol is simplier than NSFilePresenter/Coordinator
/// It focuses on File consumers with read access to assembled files.
public protocol NodeAccessor:Identifiable{

    /// Called when:
    /// - the current node assembled file will become temporaly unusable (for example on external update)
    /// - the Box has been unmounted
    /// - the file will be deleted
    //  - or if the access to the file has been blocked (ACL)
    ///
    /// If the node accessor remain active, if the node become usable again it will receive a `nodeIsUsable(node:Node)` call
    ///
    /// - Parameter node: the node
    func willBecomeUnusable(node:Node)


    /// Called after an `wantsAccess` demand  when
    /// - the current node assembled file becomes available (all the block are available, and the file has been assembled)
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - path: its file path
    func nodeIsUsable(node:Node, at path:String)


    /// Called after an `wantsAccess` demand  when
    /// When the access to the node is refused.
    /// - Parameter:
    ///   - node: the node
    ///   - explanations: the explanations
    func accessRefused(to:Node,explanations:String)
    
}

