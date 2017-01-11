//
//  ConfirmActivationViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//  Copyright © 2016 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

class ConfirmActivationViewController: IdentityStepViewController{


    override var nibName : String { return "ConfirmActivationViewController" }

    @IBOutlet weak var confirmLabel: NSTextField!

    @IBOutlet weak var codeTextField: NSTextField!

    @IBOutlet weak var messagesTextField: NSTextField!

    var locker:Locker?

    override func viewWillAppear() {
        super.viewWillAppear()
        if let document=self.documentProvider?.getDocument(){
            if let locker=document.lockers.first {
                self.locker=locker
                var phoneNumber=""
                if let c=document.currentUser.phoneCountryCode,
                    let p=document.currentUser.phoneNumber{
                    phoneNumber=c+p
                }
                self.confirmLabel.stringValue=NSLocalizedString("We have sent a confirmation code to: ", comment: "We have sent a confirmation code to: ")+phoneNumber
                self.codeTextField.stringValue=""
                if Bartleby.configuration.DEVELOPER_MODE{
                    print("\(locker.code)")
                }
            }
        }
    }

    override func proceedToValidation(){
        super.proceedToValidation()
        self.stepDelegate?.disableActions()
        if let locker=self.locker{
            if codeTextField.stringValue == locker.code{
                self.stepDelegate?.didValidateStep(number: self.stepIndex)
            }else{
                self.messagesTextField.stringValue=NSLocalizedString("The activation code is not correct!", comment: "The activation code is not correct!")
                self.stepDelegate?.enableActions()
            }
        }
    }
    
}
