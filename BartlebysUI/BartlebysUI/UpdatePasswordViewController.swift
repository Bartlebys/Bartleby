//
//  UpdatePasswordViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//  Copyright © 2016 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

class UpdatePasswordViewController: IdentityStepViewController{

    override var nibName : String { return "UpdatePasswordViewController" }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override func proceedToValidation(){
        // use
        self.identityWindowController?.passwordCandidate
        self.identityWindowController?.passwordResetCode
        super.proceedToValidation()
    }

}
