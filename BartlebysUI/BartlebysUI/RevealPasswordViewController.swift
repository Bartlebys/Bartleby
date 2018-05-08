//
//  RevealPasswordViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 02/01/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

open class RevealPasswordViewController: StepViewController {

    override open var nibName : NSNib.Name { return NSNib.Name("RevealPasswordViewController") }

    @IBOutlet weak var explanationsTextField: NSTextField!

    @IBOutlet weak var passwordTextField: NSTextField!

    override open func viewDidLoad() {
        super.viewDidLoad()
    }

    override open func viewWillAppear() {
        super.viewWillAppear()
        if let document=self.documentProvider?.getDocument(){
            document.send(IdentificationStates.revealPassword)
            let password=document.currentUser.password
            self.passwordTextField.stringValue=password ?? Default.NO_PASSWORD
        }
    }

    override open func proceedToValidation(){
        super.proceedToValidation()
        if let _ = self.documentProvider?.getDocument(){
            self.stepDelegate?.didValidateStep( self.stepIndex)
        }
    }
}
