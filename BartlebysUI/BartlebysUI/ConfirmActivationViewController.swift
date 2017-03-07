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

    @IBOutlet weak var messageTextField: NSTextField!

    var locker:Locker?

    override func viewWillAppear() {
        super.viewWillAppear()
        if let document=self.documentProvider?.getDocument(){
            document.send(IdentificationStates.confirmAccount)
            if let locker:Locker = try? Bartleby.registredObjectByUID(document.metadata.lockerUID) {
                self.locker=locker
                self.confirmLabel.stringValue=NSLocalizedString("We have sent a confirmation code to: ", comment: "We have sent a confirmation code to: ")+document.currentUser.fullPhoneNumber
                self.codeTextField.stringValue=""
                if Bartleby.configuration.DEVELOPER_MODE{
                    print("\(locker.code)")
                }
            }else{
                self.confirmLabel.stringValue=NSLocalizedString("Locker not found", comment: "Locker not found")
            }
        }
    }

    override func proceedToValidation(){
        super.proceedToValidation()
        self.stepDelegate?.disableActions()
        if let locker=self.locker{
            if codeTextField.stringValue == locker.code{
                self.documentProvider?.getDocument()?.send(IdentificationStates.accountHasBeenConfirmed)
                self.stepDelegate?.didValidateStep(self.stepIndex)
            }else{
                self.messageTextField.stringValue=NSLocalizedString("The activation code is not correct!", comment: "The activation code is not correct!")
                self.stepDelegate?.enableActions()
            }
        }
    }
    
}
