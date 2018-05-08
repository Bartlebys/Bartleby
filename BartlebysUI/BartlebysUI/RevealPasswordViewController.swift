//
//  RevealPasswordViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 02/01/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import BartlebyKit
import Cocoa

open class RevealPasswordViewController: StepViewController {
    open override var nibName: NSNib.Name { return NSNib.Name("RevealPasswordViewController") }

    @IBOutlet var explanationsTextField: NSTextField!

    @IBOutlet var passwordTextField: NSTextField!

    open override func viewDidLoad() {
        super.viewDidLoad()
    }

    open override func viewWillAppear() {
        super.viewWillAppear()
        if let document = self.documentProvider?.getDocument() {
            document.send(IdentificationStates.revealPassword)
            let password = document.currentUser.password
            passwordTextField.stringValue = password ?? Default.NO_PASSWORD
        }
    }

    open override func proceedToValidation() {
        super.proceedToValidation()
        if let _ = self.documentProvider?.getDocument() {
            stepDelegate?.didValidateStep(stepIndex)
        }
    }
}
