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

    override var nibName : String { return "RevealPasswordViewController" }

    @IBOutlet weak var explanationsTextField: NSTextField!

    @IBOutlet weak var passwordTextField: NSTextField!

    @IBOutlet weak var memorizePasswordCheckBox: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        if let document=self.documentProvider?.getDocument(){
            if let password=document.currentUser.password{
                self.passwordTextField.stringValue=password
            }
            if Bartleby.configuration.DEVELOPER_MODE &&  document.metadata.saveThePassword == true{
                self.memorizePasswordCheckBox.state=1
            }else{
                 self.memorizePasswordCheckBox.state=0
            }
        }
    }

    override func proceedToValidation(){
        super.proceedToValidation()
        if let document=self.documentProvider?.getDocument(){
            if self.memorizePasswordCheckBox.state==1{
                document.metadata.saveThePassword=true
            }
            self.stepDelegate?.didValidateStep(number: self.stepIndex)
        }
    }
}
