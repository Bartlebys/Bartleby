//
//  SetupCollaborativeServerViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//  Copyright © 2016 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

class SetupCollaborativeServerViewController: IdentityStepViewController{

    override var nibName : String { return "SetupCollaborativeServerViewController" }

    @IBOutlet weak var box: NSBox!

    @IBOutlet weak var explanationTextField: NSTextField!

    override func viewWillAppear() {
        super.viewWillAppear()
        self.explanationTextField.stringValue=NSLocalizedString("Select the Collaborative Server  API URL. \nFor example: https://api.bartlebys.org", comment: "Select the Collaborative Server API URL")
    }

    override func proceedToValidation(){
        super.proceedToValidation()
        self.stepDelegate?.didValidateStep(number: self.stepIndex)

        // You should call:
        //
        //      self.stepDelegate?.didValidateStep(number: self.stepIndex)
        //      or
        //      self.stepDelegate?.didFailValidatingStep(number: self.stepIndex)
    }


}
