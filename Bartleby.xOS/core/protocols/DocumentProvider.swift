//
//  DocumentProvider.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 31/10/2016.
//
//

import Foundation

public protocol DocumentProvider {
    /// Returns a BartlebyDocument
    /// Generally used in conjunction with `DocumentDependent` protocol
    ///
    /// - Returns: the document
    func getDocument() -> BartlebyDocument?
}

public protocol AsyncDocumentProvider {
    /// Returns a BartlebyDocument
    /// Generally used in conjunction with `DocumentDependent` protocol
    ///
    /// - Returns: the document
    func getDocument() -> BartlebyDocument?

    /// You can store document consumers
    /// To call `consumer.providerHasADocument()`
    /// - Parameter consumer: the document dependent consumer
    func addDocumentConsumer(consumer: AsyncDocumentDependent)
}
