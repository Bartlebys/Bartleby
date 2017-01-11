//
//  ValidatePasswordViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//  Copyright © 2016 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

class ValidatePasswordViewController: IdentityStepViewController{

    override var nibName : String { return "ValidatePasswordViewController" }

    @IBOutlet weak var emailLabel: NSTextField!

    @IBOutlet weak var phoneNumberLabel: NSTextField!

    @IBOutlet weak var passwordLabel: NSTextField!

    @IBOutlet weak var emailTextField: NSTextField!

    @IBOutlet weak var phoneNumberTextField: NSTextField!

    @IBOutlet weak var passwordTextField: NSSecureTextField!

    @IBOutlet weak var memorizePasswordCheckBox: NSButton!

    @IBOutlet weak var messageTextField: NSTextField!

    @IBOutlet weak var resetMyPasswordButton: NSButton!



    override func viewWillAppear() {
        super.viewWillAppear()
        if let document=self.documentProvider?.getDocument(){

            if let email=document.currentUser.email{
                self.emailTextField.stringValue=email
            }
            if let phoneNumber=document.currentUser.phoneNumber,
                let code=document.currentUser.phoneCountryCode{
                self.phoneNumberTextField.stringValue=code+phoneNumber
            }

            if Bartleby.configuration.DEVELOPER_MODE &&  document.metadata.saveThePassword == true{
                self.memorizePasswordCheckBox.state=1
                if let password=document.currentUser.password{
                    self.passwordTextField.stringValue=password
                }
            }else{
                self.memorizePasswordCheckBox.state=0
                self.passwordTextField.stringValue=""
            }
        }
    }


    override func proceedToValidation(){
        super.proceedToValidation()
        if let document=self.documentProvider?.getDocument(){
            let currentPassword=PString.trim(self.passwordTextField.stringValue)
            if currentPassword == document.currentUser.password{
                if self.identityWindowController?.creationMode == true{
                     self.stepDelegate?.didValidateStep(number: self.stepIndex)
                }else{

                    /// IF there is a Sugar in the Bowl we can validate
                    /// Else we should login + grab the Locker to recover the sugar

                    HTTPManager.apiIsReachable(document.baseURL, successHandler: {
                        document.currentUser.login(sucessHandler: {

                        }, failureHandler: { (context) in
                            self.messageTextField.stringValue=NSLocalizedString("The login has failed", comment: "The login has failed")
                        })
                    }, failureHandler: { (context) in
                        self.messageTextField.stringValue=NSLocalizedString("The server is not Reachable", comment: "The server is not Reachable")
                    })



                }
            }else{
                self.messageTextField.stringValue=NSLocalizedString("Invalid Password", comment: "Invalid Password")
            }
        }
    }


    @IBAction func resetMyPassword(_ sender: Any) {
        self.identityWindowController?.resetMyPassword()
    }
    
    
}
