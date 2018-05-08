//
//  ByPassActivationViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 12/08/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import Cocoa


// Allows to by pass the activation process
// If the Secondary Authentication Factor is not required `!document.metadata.secondaryAuthFactorRequired``
open class ByPassActivationViewController: StepViewController{

    override open var nibName : NSNib.Name { return NSNib.Name("ByPassActivationViewController") }

    override open func viewWillAppear() {
        super .viewWillAppear()
        self.stepDelegate?.didValidateStep(self.stepIndex)
    }
    
}
