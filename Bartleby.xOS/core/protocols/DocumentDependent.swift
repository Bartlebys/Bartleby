//
//  DocumentDependent.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 31/10/2016.
//
//

import Foundation



public protocol DocumentDependent {

    /// Return the document provider
    var documentProvider:DocumentProvider? { get set }

}


public protocol AsyncDocumentDependent{

    /// Return the document provider
    var documentProvider:AsyncDocumentProvider? { get set }

    /// If relevent this method can be Called by the provider to notify it as a new document
    /// It allows to determine when the `documentProvider` will be available
    /// When the `documentProvider` is available you can call `documentProvider.getDocument()`
    func providerHasADocument()

}
