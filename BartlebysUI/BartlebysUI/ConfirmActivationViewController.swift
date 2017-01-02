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
