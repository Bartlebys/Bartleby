//
//  ConfirmActivationViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//  Copyright © 2016 Chaosmos SAS. All rights reserved.
//

import BartlebyKit
import Cocoa

open class ConfirmActivationViewController: StepViewController {
    open override var nibName: NSNib.Name { return NSNib.Name("ConfirmActivationViewController") }

    @IBOutlet var confirmLabel: NSTextField!

    @IBOutlet var codeTextField: NSTextField!

    @IBOutlet var messageTextField: NSTextField!

    var locker: Locker?

    open override func viewWillAppear() {
        super.viewWillAppear()
        if let document = self.documentProvider?.getDocument() {
            document.send(IdentificationStates.confirmAccount)
            if let locker: Locker = try? Bartleby.registredObjectByUID(document.metadata.lockerUID) {
                self.locker = locker
                confirmLabel.stringValue = NSLocalizedString("We have sent a confirmation code to: ", comment: "We have sent a confirmation code to: ") + document.currentUser.fullPhoneNumber
                codeTextField.stringValue = ""
            } else {
                confirmLabel.stringValue = NSLocalizedString("Locker not found", comment: "Locker not found")
            }
        }
    }

    open override func proceedToValidation() {
        super.proceedToValidation()
        stepDelegate?.disableActions()
        if let locker = self.locker {
            if codeTextField.stringValue == locker.code {
                documentProvider?.getDocument()?.send(IdentificationStates.accountHasBeenConfirmed)
                stepDelegate?.didValidateStep(stepIndex)
            } else {
                messageTextField.stringValue = NSLocalizedString("The activation code is not correct!", comment: "The activation code is not correct!")
                stepDelegate?.enableActions()
            }
        }
    }
}
