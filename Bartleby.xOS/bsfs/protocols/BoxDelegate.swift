//
//  BoxDelegate.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 08/11/2016.
//
//

import Foundation

// Box Delegation is related to synchronization
// and content replacement
public protocol BoxDelegate {
    /// BSFS sends to BoxDelegate
    /// The delegate invokes proceed asynchronously giving the time to perform required actions
    ///
    /// - Parameter node: the node that will be moved or copied
    func moveIsReady(node: Node, to relativePath: String, proceed: () -> Void)

    /// BSFS sends to BoxDelegate
    /// The delegate invokes proceed asynchronously giving the time to perform required actions
    ///
    /// - Parameter node: the node that will be moved or copied
    func copyIsReady(node: Node, to relativePath: String, proceed: () -> Void)

    /// BSFS sends to BoxDelegate
    /// The delegate invokes proceed asynchronously giving the time to perform required actions
    ///
    /// - Parameter node: the node that will be Updated
    func deletionIsReady(node: Node, proceed: () -> Void)

    /// BSFS sends to BoxDelegate
    /// The delegate invokes proceed asynchronously giving the time to perform required actions
    ///
    /// - Parameter node: the node that will be Updated
    func nodeIsReady(node: Node, proceed: () -> Void)

    /// Should we allow the replacement of content node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - path: the path
    ///   - accessor: the accessor
    /// - Returns: true if allowed respond false by default (override required)
    func allowReplaceContent(of node: Node, withContentAt path: String, by accessor: NodeAccessor) -> Bool
}
