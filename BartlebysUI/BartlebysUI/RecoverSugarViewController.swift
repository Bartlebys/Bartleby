//
//  RecoverSugarViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 18/01/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

open class RecoverSugarViewController: StepViewController {

    override open var nibName : NSNib.Name { return NSNib.Name("RecoverSugarViewController") }

    @IBOutlet weak var consignsLabel: NSTextField!

    @IBOutlet weak var codeTextField: NSTextField!

    @IBOutlet weak var messageTextField: NSTextField!

    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override open func viewWillAppear() {
        super.viewWillAppear()
        if let document=self.documentProvider?.getDocument(){
            document.send(IdentificationStates.recoverSugar)
            let phoneNumber=document.metadata.currentUserFullPhoneNumber
            self.consignsLabel.stringValue=NSLocalizedString("We have sent an activation code to: ", comment: "We have sent a activation code to: ")+phoneNumber
            self.codeTextField.stringValue=""
            /// IMPORTANT
            if !document.metadata.secondaryAuthFactorRequired{
                if let locker:Locker = try? Bartleby.registredObjectByUID(document.metadata.lockerUID){
                    self.codeTextField.stringValue = locker.code
                    self.proceedToValidation()
                }
            }

        }else{
            self.messageTextField.stringValue=NSLocalizedString("Identification not found", comment: "Identification not found")
        }
    }

    override open func proceedToValidation() {
        super.proceedToValidation()
        let code = PString.trim(self.codeTextField.stringValue)
        if code.count > 3 {
            if let document=self.documentProvider?.getDocument(){
                ////
                /// Verifies the Locker
                /// In case of success the Locker is returned with its gems.
                /// We will use the gems to extract the sugar and decrypt the data
                ///
                /// IMPORTANT !
                /// This logic can be bypassed when using document.metadata.secondaryAuthFactorRequired == false
                /// THe ValidatePasswordViewController implement an equivalent logic
                VerifyLocker.execute(document.metadata.lockerUID,
                                     inDocumentWithUID: document.UID,
                                     code: code,
                                     accessGranted: { (locker) in
                                        let sugarCandidate=locker.gems
                                        document.metadata.sugar=sugarCandidate
                                        document.currentUser.status = .actived
                                        do{
                                            /// When the locker is verifyed use the sugar to retrieve the Collections and blocks data
                                            try document.reloadCollectionData()
                                            try document.metadata.putSomeSugarInYourBowl() // Save the key
                                            document.send(IdentificationStates.sugarHasBeenRecovered)
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

