//
//  UpdatePasswordViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//  Copyright © 2016 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

open class UpdatePasswordViewController: IdentityStepViewController{

    override open var nibName : NSNib.Name { return NSNib.Name("UpdatePasswordViewController") }

    @IBOutlet weak var passwordTextField: NSTextField!

    @IBOutlet weak var refreshButton: NSButton!

    @IBOutlet weak var messageTextField: NSTextField!
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override open func viewWillAppear() {
        super.viewWillAppear()
        self.refresh(self)
    }

    @IBAction func refresh(_ sender: Any) {
        self.passwordTextField.stringValue=Bartleby.randomStringWithLength(8,signs:Bartleby.configuration.PASSWORD_CHAR_CART)
    }

    override open func proceedToValidation(){
        super.proceedToValidation()
        self.documentProvider?.getDocument()?.send(IdentificationStates.updatePassword)
        self.identityWindowController?.passwordCandidate=self.passwordTextField.stringValue
        self.stepDelegate?.didValidateStep( self.stepIndex)
    }

}
