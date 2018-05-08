//
//  ConfirmUpdatePasswordActivationCode.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 17/01/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import BartlebyKit
import Cocoa

open class ConfirmUpdatePasswordActivationCode: StepViewController {
    @IBOutlet var consignsLabel: NSTextField!

    @IBOutlet var messageTextField: NSTextField!

    @IBOutlet var codeTextField: NSTextField!

    var code = Bartleby.randomStringWithLength(8, signs: Bartleby.configuration.PASSWORD_CHAR_CART)

    var confirmationIsImpossible = false

    open override var nibName: NSNib.Name { return NSNib.Name("ConfirmUpdatePasswordActivationCode") }

    open override func viewDidLoad() {
        super.viewDidLoad()
    }

    open override func viewWillAppear() {
        super.viewWillAppear()
        if let document = self.documentProvider?.getDocument() {
            consignsLabel.stringValue = NSLocalizedString("We have sent a confirmation code to: ", comment: "We have sent a confirmation code to: ") + document.currentUser.fullPhoneNumber
        }
        messageTextField.stringValue = ""

        codeTextField.stringValue = ""
        if Bartleby.configuration.DEVELOPER_MODE {
            print(code)
        }
    }

    open override func viewDidAppear() {
        super.viewDidAppear()
        stepDelegate?.disableActions()
        if let document = self.documentProvider?.getDocument() {
            if let serverURL = document.metadata.collaborationServerURL {
                document.currentUser.login(sucessHandler: {
                    let email = document.currentUser.email
                    let phoneNumber = document.currentUser.phoneNumber

                    // we need now  relay the activation code
                    RelayActivationCode.execute(baseURL: serverURL,
                                                documentUID: document.UID,
                                                toEmail: email,
                                                toPhoneNumber: phoneNumber,
                                                code: self.code,
                                                title: NSLocalizedString("Your activation code", comment: "Your activation code"),
                                                body: NSLocalizedString("Your activation code is: \n$code", comment: "Your activation code is"),
                                                sucessHandler: { _ in
                                                    self.stepDelegate?.enableActions()
                                                }, failureHandler: { context in
                                                    self._confirmationIsImpossible()
                                                    document.log("\(String(describing: context.responseString))", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
                    })

                }, failureHandler: { _ in
                    self._confirmationIsImpossible()
                })
            }
        } else {
            _confirmationIsImpossible()
        }
    }

    fileprivate func _confirmationIsImpossible() {
        confirmationIsImpossible = true
        messageTextField.stringValue = NSLocalizedString("The confirmation is impossible. For security reason you must contact your support supervisor.", comment: "The confirmation is impossible. For security reason you must contact your support supervisor.")
        stepDelegate?.enableActions()
    }

    open override func proceedToValidation() {
        super.proceedToValidation()
        stepDelegate?.disableActions()
        if let document = self.documentProvider?.getDocument(),
            let candidatePassword = self.identityWindowController?.passwordCandidate {
            if confirmationIsImpossible == false {
                if PString.trim(code) == PString.trim(codeTextField.stringValue) {
                    // Will produce the syndication
                    IdentitiesManager.synchronize(document, password: candidatePassword, completed: { completion in
                        if completion.success {
                            self.identityWindowController?.passwordHasBeenChanged()
                        } else {
                            self.identityWindowController?.enableActions()
                            self.messageTextField.stringValue = NSLocalizedString("Password change has failed. For security reason you must contact your support supervisor.", comment: "Password change has failed. For security reason you must contact your support supervisor.")
                        }
                    })

                } else {
                    messageTextField.stringValue = NSLocalizedString("The activation code is not correct!", comment: "The activation code is not correct!")
                }
            }
        }
    }
}
