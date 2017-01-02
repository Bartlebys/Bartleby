//
//  CreateUserViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//  Copyright © 2016 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

class CreateUserViewController: IdentityStepViewController{

    override var nibName : String { return "CreateUserViewController" }

    @IBOutlet weak var box: NSBox!

    @IBOutlet weak var explanationsTextField: NSTextField!

    @IBOutlet weak var emailLabel: NSTextField!

    @IBOutlet weak var phoneNumberLabel: NSTextField!

    @IBOutlet weak var emailComboBox: NSComboBox!

    @IBOutlet weak var phoneNumberComboBox: NSComboBox!



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
