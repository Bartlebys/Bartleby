//
//  PrepareUserCreationViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//  Copyright © 2016 Chaosmos SAS. All rights reserved.
//

import BartlebyKit
import Cocoa

// Creates potentialy a user.
@objc open class PrepareUserCreationViewController: StepViewController {
    open override var nibName: NSNib.Name { return NSNib.Name("PrepareUserCreationViewController") }

    private var _suggestedIdentifications = [Identification]()

    @IBOutlet var box: NSBox!

    @IBOutlet var explanationsTextField: NSTextField!

    @IBOutlet var emailLabel: NSTextField!

    @IBOutlet var phoneNumberLabel: NSTextField!

    @IBOutlet var emailComboBox: NSComboBox!

    @IBOutlet var phoneCountryCodeLabel: NSTextField!

    @IBOutlet var phoneCountryCodeComboBox: NSComboBox!

    @IBOutlet var phoneNumberComboBox: NSComboBox!

    @IBOutlet var messageTextField: NSTextField!

    @IBOutlet var allowPasswordSyndicationCheckBox: NSButton!

    var countryCodes: [String] = ["Greece (+30)", "Netherlands (+31)", "Belgium (+32)", "France (+33)", "United Kingdom (+44)"]

    open override func viewWillAppear() {
        super.viewWillAppear()
        documentProvider?.getDocument()?.send(IdentificationStates.prepareUserCreation)
        allowPasswordSyndicationCheckBox.state = Bartleby.configuration.SUPPORTS_PASSWORD_SYNDICATION_BY_DEFAULT ? NSControl.StateValue.on : NSControl.StateValue.off
        messageTextField.stringValue = ""
        explanationsTextField.stringValue = NSLocalizedString("We need a valid email and a valid phone number. You can reuse previous identifications or create a new one for this document.", comment: "We need a valid email and a valid phone number. You can reuse previous identifications or create a new one for this document.")
        if let document = self.documentProvider?.getDocument() {
            _suggestedIdentifications = IdentitiesManager.suggestedIdentifications(forDocument: document)
            for identification in _suggestedIdentifications {
                emailComboBox.addItem(withObjectValue: identification.email)
                phoneNumberComboBox.addItem(withObjectValue: identification.phoneNumber)
                if identification.supportsPasswordSyndication {
                    allowPasswordSyndicationCheckBox.state = NSControl.StateValue.on
                } else {
                    allowPasswordSyndicationCheckBox.state = NSControl.StateValue.off
                }
            }
            emailComboBox.addItem(withObjectValue: NSLocalizedString("Add your Email", comment: "Add your Email"))
            phoneCountryCodeComboBox.addItem(withObjectValue: NSLocalizedString("Phone Country Code", comment: "Phone Country Code"))
            phoneNumberComboBox.addItem(withObjectValue: NSLocalizedString("Phone number", comment: "Phone number"))
            for country in countryCodes.sorted() {
                phoneCountryCodeComboBox.addItem(withObjectValue: country)
            }
            emailComboBox.selectItem(at: 0)
            phoneCountryCodeComboBox.selectItem(at: 0)
            phoneNumberComboBox.selectItem(at: 0)
            syncOnMain {
                self.didChange(self.emailComboBox)
            }
        }
    }

    @IBAction func didChange(_ sender: NSComboBox) {
        let index = sender.indexOfSelectedItem
        if index >= 0 && index < emailComboBox.objectValues.count {
            if sender == emailComboBox {
                phoneNumberComboBox.selectItem(at: index)
                if let email = self.emailComboBox.itemObjectValue(at: index) as? String {
                    for i in 0 ..< _suggestedIdentifications.count {
                        let identification = _suggestedIdentifications[i]
                        if identification.email == email {
                            // Select the Phone code
                            let idx = phoneCountryCodeComboBox.indexOfItem(withObjectValue: identification.phoneCountryCode)
                            if idx <= phoneCountryCodeComboBox.objectValues.count {
                                phoneCountryCodeComboBox.selectItem(at: idx)
                            }
                            break
                        }
                    }
                }
            }
            if sender == phoneNumberComboBox {
                emailComboBox.selectItem(at: index)
                if let phoneNumber = self.phoneNumberComboBox.itemObjectValue(at: index) as? String {
                    for i in 0 ..< _suggestedIdentifications.count {
                        let identification = _suggestedIdentifications[i]
                        if identification.phoneNumber == phoneNumber {
                            // Select the Phone code
                            let idx = phoneCountryCodeComboBox.indexOfItem(withObjectValue: identification.phoneCountryCode)
                            if idx <= phoneCountryCodeComboBox.objectValues.count {
                                phoneCountryCodeComboBox.selectItem(at: idx)
                            }
                            break
                        }
                    }
                }
            }
        }
    }

    open override func proceedToValidation() {
        super.proceedToValidation()
        messageTextField.stringValue = ""

        if let _ = self.documentProvider?.getDocument() {
            let email = emailComboBox.stringValue

            var prefix = ""
            if let match = self.phoneCountryCodeComboBox.stringValue.range(of: "(?<=\\()[^()]{1,10}(?=\\))", options: .regularExpression) {
                prefix = String(phoneCountryCodeComboBox.stringValue[match])
            }

            let phoneNumber = prefix + phoneNumberComboBox.stringValue
            if HTTPManager.isValidEmail(email) {
                if HTTPManager.isValidPhoneNumber(phoneNumber) {
                    let identification = Identification.newIdentification()
                    identification.email = email
                    identification.phoneCountryCode = phoneCountryCodeComboBox.stringValue
                    identification.phoneNumber = phoneNumberComboBox.stringValue
                    identification.supportsPasswordSyndication = (allowPasswordSyndicationCheckBox.state == NSControl.StateValue.on)
                    // We store the prepared identification
                    identityWindowController?.identification = identification
                    documentProvider?.getDocument()?.send(IdentificationStates.userCreationHasBeenPrepared)
                    stepDelegate?.didValidateStep(stepIndex)

                } else {
                    messageTextField.stringValue = NSLocalizedString("Invalid phone number!", comment: "Invalid phone number!")
                }
            } else {
                messageTextField.stringValue = NSLocalizedString("Invalid email!", comment: "Invalid email!")
            }
        }
    }
}
