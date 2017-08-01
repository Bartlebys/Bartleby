//
//  RevealPasswordViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 02/01/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

class RevealPasswordViewController: IdentityStepViewController {

    override var nibName : NSNib.Name { return NSNib.Name("RevealPasswordViewController") }

    @IBOutlet weak var explanationsTextField: NSTextField!

    @IBOutlet weak var passwordTextField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        if let document=self.documentProvider?.getDocument(){
            document.send(IdentificationStates.revealPassword)
            let password=document.currentUser.password
            self.passwordTextField.stringValue=password
        }
    }

    override func proceedToValidation(){
        super.proceedToValidation()
        if let _ = self.documentProvider?.getDocument(){
            self.stepDelegate?.didValidateStep( self.stepIndex)
        }
    }
}
