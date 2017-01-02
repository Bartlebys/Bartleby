//
//  IdentityStepViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 02/01/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

class IdentityStepViewController: NSViewController ,DocumentDependent,IdentityStep{

    var stepDelegate:IdentityStepNavigation?


    /// There are credentials for that Server.
    /// Use them an set - up the association

    var documentProvider: DocumentProvider?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    // MARK: - IdentityStep

    var stepIndex:Int = -1

    func proceedToValidation(){
        // You should call:
        //
        //      self.stepDelegate?.didValidateStep(number: self.stepIndex)
        //      or
        //      self.stepDelegate?.didFailValidatingStep(number: self.stepIndex)
    }

}
