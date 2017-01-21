//
//  RecoverSugarViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 18/01/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

class RecoverSugarViewController: IdentityStepViewController {

    override var nibName : String { return "RecoverSugarViewController" }

    @IBOutlet weak var consignsLabel: NSTextField!

    @IBOutlet weak var codeTextField: NSTextField!

    @IBOutlet weak var messageTextField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        if let document=self.documentProvider?.getDocument(){
            let phoneNumber=document.metadata.currentUserFullPhoneNumber
            self.consignsLabel.stringValue=NSLocalizedString("We have sent an activation code to: ", comment: "We have sent a activation code to: ")+phoneNumber
            self.codeTextField.stringValue=""
        }else{
            self.messageTextField.stringValue=NSLocalizedString("Identification not found", comment: "Identification not found")
        }
    }

    override func proceedToValidation() {
        super.proceedToValidation()
        let code = PString.trim(self.codeTextField.stringValue)
        if code.characters.count > 3 {
            if let document=self.documentProvider?.getDocument(){
                // Verify the Locker
                VerifyLocker.execute(document.metadata.lockerUID,
                                     inDocumentWithUID: document.UID,
                                     code: code,
                                     accessGranted: { (locker) in
                                        let sugarCandidate=locker.gems
                                        document.metadata.sugar=sugarCandidate
                                        document.currentUser.status = .actived
                                        do{
                                            /// When the locker is verifyed use the sugar to retrieve the Collections and blocks data
                                            try document.reload()
                                            try document.metadata.putSomeSugarInYourBowl() // Save the key
                                            self.identityWindowController?.identificationIsValid=true
                                            self.stepDelegate?.didValidateStep( self.stepIndex)
                                        }catch{
                                            self.messageTextField.stringValue=NSLocalizedString("Unable to decrypt the package", comment: "Unable to decrypt the package")
                                             document.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
                                        }
                }, accessRefused: { (context) in
                    if let r=context.responseString{
                        var message=r.replacingOccurrences(of: "[\"", with: "")
                        message=message.replacingOccurrences(of: "\"]", with: "")
                        self.messageTextField.stringValue=message
                    }
                })

            }
        }else{
            self.messageTextField.stringValue=NSLocalizedString("Invalid Activation code", comment: "Invalid Activation code")
        }

    }
    
}

