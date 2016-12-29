//
//  DocumentProviderWindowController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//  Copyright © 2016 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit


class DocumentProviderWindowController: NSWindowController,DocumentProvider {

    // MARK: - DocumentProvider

    /// Returns a BartlebyDocument
    /// Generally used in conjunction with `DocumentDependent` protocol
    ///
    /// - Returns: the document
    func getDocument() -> BartlebyDocument?{
        return self.document as? BartlebyDocument
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    }

    
}
