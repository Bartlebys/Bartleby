//
//  StepViewController+Identity.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 24/03/2018.
//  Copyright © 2018 Chaosmos SAS. All rights reserved.
//

import Foundation

/// This extension is used to access to the window controller
/// when the steps controllers are embedded in the IdentityWindowController
public extension StepViewController {
    public var identityWindowController: IdentityWindowController? {
        return documentProvider as? IdentityWindowController
    }
}
