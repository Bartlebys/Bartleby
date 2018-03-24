//
//  StepViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 02/01/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

@objc open class StepViewController: NSViewController ,DocumentDependent,Step{

    open var stepDelegate:StepNavigation?


    /// There are credentials for that Server.
    /// Use them an set - up the association

    open var documentProvider: DocumentProvider?

    // MARK: - Step

    open var stepIndex:Int = -1

    open func proceedToValidation(){
        // On success You should call: self.stepDelegate?.didValidateStep(self.stepIndex)
        // Else you can embedd the navigation logic
    }
}



/// This extension is used to access to the window controller
/// when the steps controllers are embedded in the IdentityWindowController
public extension StepViewController{

    public var identityWindowController:IdentityWindowController?{
        return self.documentProvider as? IdentityWindowController
    }

}
