//
//  StepViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 02/01/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import BartlebyKit
import Cocoa

@objc open class StepViewController: NSViewController, DocumentDependent, Step {
    open var stepDelegate: StepNavigation?

    /// There are credentials for that Server.
    /// Use them an set - up the association

    open var documentProvider: DocumentProvider?

    // MARK: - Step

    open var stepIndex: Int = -1

    open func proceedToValidation() {
        // On success You should call: self.stepDelegate?.didValidateStep(self.stepIndex)
        // Else you can embedd the navigation logic
    }
}
