//
//  ConfirmPasswordActivationCode.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 17/01/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

class ConfirmPasswordActivationCode: IdentityStepViewController {

    override var nibName : String { return "ConfirmPasswordActivationCode" }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override func proceedToValidation() {
        super.proceedToValidation()

        let candidatePassword=self.identityWindowController?.passwordCandidate
        let resetCode=self.identityWindowController?.passwordResetCode

        if let document=self.documentProvider?.getDocument(){
            // Will produce the syndication
            IdentitiesManager.synchronize(document)
        }

    }
}
