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

            let documentSugar = document.metadata.sugar
            let creationMode = self.identityWindowController?.creationMode

            /// If there is a valid Sugar we can validate
            /// Else we should recover the sugar (using second security factor)
            
            if documentSugar != Default.NO_UID {
                let currentPassword=PString.trim(self.passwordTextField.stringValue)
                let documentPassword=PString.trim(document.currentUser.password ?? "")
                if currentPassword == document.currentUser.password{
                    document.metadata.saveThePassword=(self.memorizePasswordCheckBox.state==1)
                    self.identityWindowController?.identificationIsValid=true
                    self.stepDelegate?.didValidateStep(number: self.stepIndex)
                }else{
                    self.messageTextField.stringValue=NSLocalizedString("Invalid Password", comment: "Invalid Password")
                }
            }else{
                HTTPManager.apiIsReachable(document.baseURL, successHandler: {
                    do{
                        /// We create a temporary user
                        /// We need to encrypt its serialized password (we never store the directly the passwords)
                        /// We create a temporary to authenticate
                        /// Note that the real user is serialized within the collections (with the sugar)
                        let password = try Bartleby.cryptoDelegate.encryptString(self.passwordTextField.stringValue,useKey:Bartleby.configuration.KEY)
                        let dictionary=[
                            Default.TYPE_NAME_KEY:User.typeName(),
                            Default.UID_KEY:document.metadata.currentUserUID,
                            Default.USER_EMAIL_KEY:self.emailTextField.stringValue,
                            Default.USER_PASSWORD_KEY:password,
                            ];

                        let serializable = try document.serializer.deserializeFromDictionary(dictionary)
                        if var user:User = serializable as? User{
                            user.creatorUID=user.UID
                            user.referentDocument=document
                            user.login(sucessHandler: {

                                /// Find the locker to be verifyed
                                let lockerUID=document.metadata.lockerUID

                                /// GetActivationCode(for :lockerUID)
                                /// -> Will verify the user ID and use the found user PhoneNumber to send the activation code.


                                GetActivationCode.execute(baseURL: document.baseURL,
                                                          documentUID: document.UID,
                                                          lockerUID: lockerUID,
                                                          title: "",
                                                          body: "$code",
                                                          sucessHandler: { (context) in
                                                            /// Go to activation screen.

                                                            /// On activation Proceed to Verify Locker
                                                            /// When the locker is verifyed use the sugar to retrieve the Collections and blocks data

                                }, failureHandler: { (context) in

                                })

                                self.identityWindowController?.identificationIsValid=true


                                self.stepDelegate?.didValidateStep(number: self.stepIndex)

                            }, failureHandler: { (context) in
                                self.messageTextField.stringValue=NSLocalizedString("The login has failed", comment: "The login has failed")
                            })
                        }
                    }catch{
                        self.messageTextField.stringValue="\(error)"
                        document.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
                    }
                    
                }, failureHandler: { (context) in
                    self.messageTextField.stringValue=NSLocalizedString("The server is not Reachable", comment: "The server is not Reachable")
                })
            }
        }

    }
    
    @IBAction func resetMyPassword(_ sender: Any) {
        self.identityWindowController?.resetMyPassword()
    }
    
    
}
