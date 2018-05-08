//
//  ByPassActivationViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 12/08/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import Cocoa

// Allows to by pass the activation process
// If the Secondary Authentication Factor is not required `!document.metadata.secondaryAuthFactorRequired``
open class ByPassActivationViewController: StepViewController {
    open override var nibName: NSNib.Name { return NSNib.Name("ByPassActivationViewController") }

    open override func viewWillAppear() {
        super.viewWillAppear()
        stepDelegate?.didValidateStep(stepIndex)
    }
}
