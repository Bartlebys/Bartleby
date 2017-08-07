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

    override var nibName : NSNib.Name { return NSNib.Name("ValidatePasswordViewController") }

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
        if let document = self.documentProvider?.getDocument(){

            if Bartleby.configuration.DEVELOPER_MODE{
                print("Using currentUserUID: \(document.metadata.currentUserUID)")
            }

            document.send(IdentificationStates.validatePassword)
            self.emailTextField.stringValue = document.metadata.currentUserEmail
            if document.metadata.currentUserFullPhoneNumber.characters.count > 3{
                self.phoneNumberTextField.stringValue = document.metadata.currentUserFullPhoneNumber
            }else{
                let p = document.currentUser.fullPhoneNumber
                if p.characters.count > 3 {
                    self.phoneNumberTextField.stringValue = p
                }
            }

            var supportsPasswordUpdate=false
            var supportsPasswordMemorization=false
            if let user = document.metadata.currentUser{
                supportsPasswordUpdate=user.supportsPasswordUpdate
                supportsPasswordMemorization=user.supportsPasswordMemorization
            }

            if !Bartleby.configuration.REDUCED_SECURITY_MODE{
                if !supportsPasswordMemorization{
                    self.memorizePasswordCheckBox.isEnabled=false
                    self.memorizePasswordCheckBox.isHidden=true
                }

                if document.metadata.sugar == Default.VOID_STRING
                    || supportsPasswordUpdate == false {
                    self.resetMyPasswordButton.isEnabled=false
                    self.resetMyPasswordButton.isHidden=true
                }
            }

            if document.metadata.saveThePassword == true && supportsPasswordMemorization{
                self.memorizePasswordCheckBox.state = NSControl.StateValue.on
                let password=document.currentUser.password
                self.passwordTextField.stringValue=password ?? Default.NO_PASSWORD
            }else{
                self.passwordTextField.stringValue=""
            }
        }
    }


    override func proceedToValidation(){
        super.proceedToValidation()
        if let document=self.documentProvider?.getDocument(){

            let documentSugar = document.metadata.sugar

            /// If there is a valid Sugar we can validate
            /// Else we should recover the sugar (using second security factor)

            if documentSugar != Default.VOID_STRING {
                let currentPassword=PString.trim(self.passwordTextField.stringValue)
                let documentPassword=PString.trim(document.currentUser.password ?? Default.NO_PASSWORD)
                if currentPassword == documentPassword{
                    document.send(IdentificationStates.passwordsAreMatching)
                    document.metadata.saveThePassword=(self.memorizePasswordCheckBox.state == NSControl.StateValue.on )
                    self.identityWindowController?.identificationIsValid=true
                    document.online=true
                    self.stepDelegate?.didValidateStep( self.stepIndex)
                }else{
                    self.messageTextField.stringValue=NSLocalizedString("Invalid Password", comment: "Invalid Password")
                }
            }else{
                if Bartleby.configuration.DEVELOPER_MODE{
                    print("Using baseURL: \(document.baseURL)")
                }
                HTTPManager.apiIsReachable(document.baseURL, successHandler: {
                    do{

                        /// We create a temporary user
                        /// We create a temporary user to authenticate
                        /// Note that the real user is serialized within the collections (with the sugar)
                        /// We never store the clearly the password (on login we use user.cryptoPassword)
                        /// Even locally the password is crypted on serialization
                        let password = self.passwordTextField.stringValue
                        let tempUser:User = User()
                        tempUser.quietChanges {
                            tempUser.UID = document.metadata.currentUserUID
                            tempUser.email = self.emailTextField.stringValue
                            tempUser.password = password
                            tempUser.creatorUID=tempUser.UID
                            tempUser.referentDocument=document
                            document.metadata.configureCurrentUser(tempUser)
                        }

                        tempUser.login(sucessHandler: {

                            /// Find the locker to be verifyed
                            let lockerUID=document.metadata.lockerUID

                            /// GetActivationCode(for :lockerUID)
                            /// -> Will verify the user ID and use the found user PhoneNumber to send the activation code.

                            GetActivationCode.execute(baseURL: document.baseURL,
                                                      documentUID: document.UID,
                                                      lockerUID: lockerUID,
                                                      title: "",
                                                      body: NSLocalizedString("Your activation code is: \n$code", comment: "Your activation code is"),
                                                      sucessHandler: { (context) in
                                                        if !document.metadata.secondaryAuthFactorRequired{
                                                            // IMPORTANT :
                                                            // Normally we should recover the sugar by calling VerifyLocker
                                                            // This approach bypasses the RecoverSugarViewController
                                                            // and implement the same logic as RecoverSugarViewController.proceedToValidation
                                                            if let string=context.responseString{
                                                                if let data = string.data(using:Default.STRING_ENCODING){
                                                                    if let locker = try? JSON.decoder.decode(Locker.self, from: data){
                                                                        // We have the locker
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
                                                                            return
                                                                        }catch{
                                                                            self.messageTextField.stringValue=NSLocalizedString("Unexpected Error: ", comment:"Unexpected Error:") + "\(error)"
                                                                            self.identityWindowController?.activationMode=true
                                                                        }
                                                                    }else{
                                                                        // This certainly means that the locker was not configured to by pass the secondary auth factor
                                                                        self.messageTextField.stringValue=NSLocalizedString("Unable to get the Locker", comment: "Unable to get the Locker")
                                                                        // So we will display the activation view controller after 3 seconds.
                                                                        // And print the call result
                                                                        // And the SMS layer is disabled by configuration we will receive its text HERE
                                                                        Async.main(after: 3, { () -> () in
                                                                             print(string)
                                                                            self.identityWindowController?.activationMode=true
                                                                        })
                                                                    }
                                                                }
                                                            }else{
                                                                self.messageTextField.stringValue=NSLocalizedString("Void Data", comment: "Void Data")
                                                            }
                                                        }else{
                                                            // We use the secondaryAuthFactorRequired
                                                            self.identityWindowController?.activationMode=true
                                                        }

                                                        

                            }, failureHandler: { (context) in
                                self.messageTextField.stringValue=NSLocalizedString("We are unable to activate this account", comment: "We are unable to activate this account")

                            })
                        }, failureHandler: { (context) in
                            self.messageTextField.stringValue=NSLocalizedString("The login has failed", comment: "The login has failed")
                        })

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
