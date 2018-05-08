//
//  UpdatePasswordViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//  Copyright © 2016 Chaosmos SAS. All rights reserved.
//

import BartlebyKit
import Cocoa

open class UpdatePasswordViewController: StepViewController {
    open override var nibName: NSNib.Name { return NSNib.Name("UpdatePasswordViewController") }

    @IBOutlet var passwordTextField: NSTextField!

    @IBOutlet var refreshButton: NSButton!

    @IBOutlet var messageTextField: NSTextField!
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    open override func viewWillAppear() {
        super.viewWillAppear()
        refresh(self)
    }

    @IBAction func refresh(_: Any) {
        passwordTextField.stringValue = Bartleby.randomStringWithLength(8, signs: Bartleby.configuration.PASSWORD_CHAR_CART)
    }

    open override func proceedToValidation() {
        super.proceedToValidation()
        documentProvider?.getDocument()?.send(IdentificationStates.updatePassword)
        identityWindowController?.passwordCandidate = passwordTextField.stringValue
        stepDelegate?.didValidateStep(stepIndex)
    }
}
