//
//  ByPassActivationViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 12/08/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import Cocoa

class ByPassActivationViewController: IdentityStepViewController{

    override var nibName : NSNib.Name { return NSNib.Name("ByPassActivationViewController") }

    override func viewWillAppear() {
        super .viewWillAppear()
        self.stepDelegate?.didValidateStep(self.stepIndex)
    }

    
}
