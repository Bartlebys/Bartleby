//
//  ValidatePasswordViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//  Copyright © 2016 Chaosmos SAS. All rights reserved.
//

import BartlebyKit
import Cocoa

open class ValidatePasswordViewController: StepViewController {
    open override var nibName: NSNib.Name { return NSNib.Name("ValidatePasswordViewController") }

    @IBOutlet var emailLabel: NSTextField!

    @IBOutlet var phoneNumberLabel: NSTextField!

    @IBOutlet var passwordLabel: NSTextField!

    @IBOutlet var emailTextField: NSTextField!

    @IBOutlet var phoneNumberTextField: NSTextField!

    @IBOutlet var passwordTextField: NSSecureTextField!

    @IBOutlet var memorizePasswordCheckBox: NSButton!

    @IBOutlet var messageTextField: NSTextField!

    @IBOutlet var resetMyPasswordButton: NSButton!

    open override func viewWillAppear() {
        super.viewWillAppear()
        if let document = self.documentProvider?.getDocument() {
            if Bartleby.configuration.DEVELOPER_MODE {
                print("Using currentUserUID: \(document.metadata.currentUserUID)")
            }

            if document.metadata.isolatedUserMode {
                _viewDidAppearForIsolatedUser()
            }

            document.send(IdentificationStates.validatePassword)
            emailTextField.stringValue = document.metadata.currentUserEmail
            if document.metadata.currentUserFullPhoneNumber.count > 3 {
                phoneNumberTextField.stringValue = document.metadata.currentUserFullPhoneNumber
            } else {
                let p = document.currentUser.fullPhoneNumber
                if p.count > 3 {
                    phoneNumberTextField.stringValue = p
                }
            }

            var supportsPasswordUpdate = false
            var supportsPasswordMemorization = false
            if let user = document.metadata.currentUser {
                supportsPasswordUpdate = user.supportsPasswordUpdate
                supportsPasswordMemorization = user.supportsPasswordMemorization
            }

            if !supportsPasswordMemorization {
                memorizePasswordCheckBox.isEnabled = false
                memorizePasswordCheckBox.isHidden = true
            }

            if document.metadata.sugar == Default.NO_SUGAR
                || supportsPasswordUpdate == false {
                resetMyPasswordButton.isEnabled = false
                resetMyPasswordButton.isHidden = true
            }

            if document.metadata.saveThePassword == true && supportsPasswordMemorization {
                memorizePasswordCheckBox.state = NSControl.StateValue.on
                let password = document.currentUser.password
                passwordTextField.stringValue = password ?? Default.NO_PASSWORD
            } else {
                passwordTextField.stringValue = ""
            }
        }
    }

    fileprivate func _viewDidAppearForIsolatedUser() {
        emailLabel.isHidden = true
        emailTextField.isHidden = true
        phoneNumberLabel.isHidden = true
        phoneNumberTextField.isHidden = true
        resetMyPasswordButton.isHidden = true
    }

    open override func proceedToValidation() {
        super.proceedToValidation()
        if let document = self.documentProvider?.getDocument() {
            let documentSugar = document.metadata.sugar

            /// If there is a valid Sugar we can validate
            /// Else we should recover the sugar (using second security factor)

            if documentSugar != Default.NO_SUGAR {
                let currentPassword = PString.trim(passwordTextField.stringValue)
                let documentPassword = PString.trim(document.currentUser.password ?? Default.NO_PASSWORD)
                if currentPassword == documentPassword {
                    document.send(IdentificationStates.passwordsAreMatching)
                    document.metadata.saveThePassword = (memorizePasswordCheckBox.state == NSControl.StateValue.on)
                    identityWindowController?.identificationIsValid = true
                    if !document.currentUser.isIsolated {
                        document.online = true
                    }
                    stepDelegate?.didValidateStep(stepIndex)
                } else {
                    messageTextField.stringValue = NSLocalizedString("Invalid Password", comment: "Invalid Password")
                }
            } else {
                if Bartleby.configuration.DEVELOPER_MODE {
                    print("Using baseURL: \(document.baseURL)")
                }
                HTTPManager.apiIsReachable(document.baseURL, successHandler: {
                    /// We create a temporary user
                    /// We create a temporary user to authenticate
                    /// Note that the real user is serialized within the collections (with the sugar)
                    /// We never store the clearly the password (on login we use user.cryptoPassword)
                    /// Even locally the password is crypted on serialization
                    let password = self.passwordTextField.stringValue
                    let tempUser: User = User()
                    tempUser.quietChanges {
                        tempUser.UID = document.metadata.currentUserUID
                        tempUser.email = self.emailTextField.stringValue
                        tempUser.password = password
                        tempUser.creatorUID = tempUser.UID
                        tempUser.referentDocument = document
                        document.metadata.configureCurrentUser(tempUser)
                    }

                    tempUser.login(sucessHandler: {
                        /// Find the locker to be verifyed
                        let lockerUID = document.metadata.lockerUID

                        /// GetActivationCode(for :lockerUID)
                        /// -> Will verify the user ID and use the found user PhoneNumber to send the activation code.

                        GetActivationCode.execute(baseURL: document.baseURL,
                                                  documentUID: document.UID,
                                                  lockerUID: lockerUID,
                                                  title: "",
                                                  body: NSLocalizedString("Your activation code is: \n$code", comment: "Your activation code is"),
                                                  sucessHandler: { context in
                                                      if !document.metadata.secondaryAuthFactorRequired {
                                                          // IMPORTANT :
                                                          // Normally we should recover the sugar by calling VerifyLocker
                                                          // This approach bypasses the RecoverSugarViewController
                                                          // and implement the same logic as RecoverSugarViewController.proceedToValidation
                                                          if let string = context.responseString {
                                                              if let data = string.data(using: Default.STRING_ENCODING) {
                                                                  if let locker = try? JSON.decoder.decode(Locker.self, from: data) {
                                                                      // We have the locker
                                                                      let sugarCandidate = locker.gems
                                                                      document.metadata.sugar = sugarCandidate
                                                                      document.currentUser.status = .actived
                                                                      do {
                                                                          /// When the locker is verifyed use the sugar to retrieve the Collections and blocks data
                                                                          try document.reloadCollectionData()
                                                                          try document.metadata.putSomeSugarInYourBowl() // Save the key
                                                                          document.send(IdentificationStates.sugarHasBeenRecovered)
                                                                          self.identityWindowController?.identificationIsValid = true
                                                                          self.stepDelegate?.didValidateStep(self.stepIndex)
                                                                          return
                                                                      } catch {
                                                                          self.messageTextField.stringValue = NSLocalizedString("Unexpected Error: ", comment: "Unexpected Error:") + "\(error)"
                                                                          self.identityWindowController?.activationMode = true
                                                                      }
                                                                  } else {
                                                                      // This certainly means that the locker was not configured to by pass the secondary auth factor
                                                                      self.messageTextField.stringValue = NSLocalizedString("Unable to get the Locker", comment: "Unable to get the Locker")
                                                                      // So we will display the activation view controller after 3 seconds.
                                                                      // And print the call result
                                                                      // And the SMS layer is disabled by configuration we will receive its text HERE
                                                                      Async.main(after: 3, { () -> Void in
                                                                          print(string)
                                                                          self.identityWindowController?.activationMode = true
                                                                      })
                                                                  }
                                                              }
                                                          } else {
                                                              self.messageTextField.stringValue = NSLocalizedString("Void Data", comment: "Void Data")
                                                          }
                                                      } else {
                                                          // We use the secondaryAuthFactorRequired
                                                          self.identityWindowController?.activationMode = true
                                                      }

                                                  }, failureHandler: { _ in
                                                      self.messageTextField.stringValue = NSLocalizedString("We are unable to activate this account", comment: "We are unable to activate this account")

                        })
                    }, failureHandler: { _ in
                        self.messageTextField.stringValue = NSLocalizedString("The login has failed", comment: "The login has failed")
                    })

                }, failureHandler: { _ in
                    self.messageTextField.stringValue = NSLocalizedString("The server is not Reachable", comment: "The server is not Reachable")
                })
            }
        }
    }

    @IBAction func resetMyPassword(_: Any) {
        identityWindowController?.resetMyPassword()
    }
}
