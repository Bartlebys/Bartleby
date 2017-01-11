//
//  IdentityStepViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 02/01/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

open class IdentityStepViewController: NSViewController ,DocumentDependent,IdentityStep{

    open var stepDelegate:IdentityStepNavigation?


    /// There are credentials for that Server.
    /// Use them an set - up the association

    open var documentProvider: DocumentProvider?


    open var identityWindowController:IdentityWindowController?{
        return self.documentProvider as? IdentityWindowController
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    // MARK: - IdentityStep

    open var stepIndex:Int = -1

    open func proceedToValidation(){
        // On success You should call:
        //      self.stepDelegate?.didValidateStep(number: self.stepIndex)
    }
}
