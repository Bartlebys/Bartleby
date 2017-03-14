//
//  PrepareUserCreationViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//  Copyright © 2016 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

// Creates potentialy a user.
class PrepareUserCreationViewController: IdentityStepViewController{

    override var nibName : String { return "PrepareUserCreationViewController" }

    fileprivate var _suggestedIdentifications=[Identification]()

    @IBOutlet weak var box: NSBox!

    @IBOutlet weak var explanationsTextField: NSTextField!

    @IBOutlet weak var emailLabel: NSTextField!

    @IBOutlet weak var phoneNumberLabel: NSTextField!

    @IBOutlet weak var emailComboBox: NSComboBox!

    @IBOutlet weak var phoneCountryCodeLabel: NSTextField!

    @IBOutlet weak var phoneCountryCodeComboBox: NSComboBox!

    @IBOutlet weak var phoneNumberComboBox: NSComboBox!

    @IBOutlet weak var messageTextField: NSTextField!

    @IBOutlet weak var allowPasswordSyndicationCheckBox: NSButton!

    var countryCodes:[String]=["Greece (+30)","Netherlands (+31)","Belgium (+32)","France (+33)","United Kingdom (+44)"]

    override func viewWillAppear() {
        super.viewWillAppear()
        self.documentProvider?.getDocument()?.send(IdentificationStates.prepareUserCreation)
        self.allowPasswordSyndicationCheckBox.state = Bartleby.configuration.SUPPORTS_PASSWORD_SYNDICATION_BY_DEFAULT ? 1 : 0
        self.messageTextField.stringValue=""
        self.explanationsTextField.stringValue=NSLocalizedString("We need a valid email and a valid phone number. You can reuse previous identifications or create a new one for this document.", comment: "We need a valid email and a valid phone number. You can reuse previous identifications or create a new one for this document.")
        if let document=self.documentProvider?.getDocument(){
            self._suggestedIdentifications = IdentitiesManager.suggestedIdentifications(forDocument: document)
            for identification in self._suggestedIdentifications{
                self.emailComboBox.addItem(withObjectValue: identification.email)
                self.phoneNumberComboBox.addItem(withObjectValue: identification.phoneNumber)
                if identification.supportsPasswordSyndication{
                     self.allowPasswordSyndicationCheckBox.state=1
                }else{
                    self.allowPasswordSyndicationCheckBox.state=0
                }
            }
            self.emailComboBox.addItem(withObjectValue:NSLocalizedString("Add your Email", comment: "Add your Email"))
            self.phoneCountryCodeComboBox.addItem(withObjectValue:NSLocalizedString("Phone Country Code", comment: "Phone Country Code"))
            self.phoneNumberComboBox.addItem(withObjectValue:NSLocalizedString("Phone number", comment: "Phone number"))
            for country in countryCodes.sorted(){
                self.phoneCountryCodeComboBox.addItem(withObjectValue: country)
            }
            self.emailComboBox.selectItem(at: 0)
            self.phoneCountryCodeComboBox.selectItem(at: 0)
            self.phoneNumberComboBox.selectItem(at: 0)
            Async.main{
                self.didChange(self.emailComboBox)
            }
        }
    }

    @IBAction func didChange(_ sender: NSComboBox) {
        let index=sender.indexOfSelectedItem
        if index>=0 && index < emailComboBox.objectValues.count{
            if sender == self.emailComboBox{
                self.phoneNumberComboBox.selectItem(at: index)
                if let email = self.emailComboBox.itemObjectValue(at: index) as? String{
                    for i in 0 ..< self._suggestedIdentifications.count{
                        let identification=self._suggestedIdentifications[i]
                        if identification.email==email{
                            // Select the Phone code
                            let idx=self.phoneCountryCodeComboBox.indexOfItem(withObjectValue: identification.phoneCountryCode)
                            if idx <= self.phoneCountryCodeComboBox.objectValues.count{
                                self.phoneCountryCodeComboBox.selectItem(at: idx)
                            }
                            break
                        }

                    }
                }
            }
            if sender == self.phoneNumberComboBox{
                self.emailComboBox.selectItem(at: index)
                if let phoneNumber = self.phoneNumberComboBox.itemObjectValue(at: index) as? String{
                    for i in 0 ..< self._suggestedIdentifications.count{
                        let identification=self._suggestedIdentifications[i]
                        if identification.phoneNumber == phoneNumber{
                            // Select the Phone code
                            let idx=self.phoneCountryCodeComboBox.indexOfItem(withObjectValue: identification.phoneCountryCode)
                            if idx <= self.phoneCountryCodeComboBox.objectValues.count{
                                self.phoneCountryCodeComboBox.selectItem(at: idx)
                            }
                            break
                        }

                    }
                }
            }
        }
    }

    override func proceedToValidation(){
        super.proceedToValidation()
        self.messageTextField.stringValue=""
        if let _ = self.documentProvider?.getDocument(){
            let email=self.emailComboBox.stringValue

            var prefix=""
            if let match = self.phoneCountryCodeComboBox.stringValue.range(of:"(?<=\\()[^()]{1,10}(?=\\))", options: .regularExpression) {
                prefix=self.phoneCountryCodeComboBox.stringValue.substring(with: match)
            }
            let phoneNumber=prefix+self.phoneNumberComboBox.stringValue
            if HTTPManager.isValidEmail(email){
                if HTTPManager.isValidPhoneNumber(phoneNumber){
                    var id=Identification()
                    id.email=email
                    id.phoneCountryCode=self.phoneCountryCodeComboBox.stringValue
                    id.phoneNumber=self.phoneNumberComboBox.stringValue
                    id.supportsPasswordSyndication=(self.allowPasswordSyndicationCheckBox.state==1)
                    // We store the prepared identification
                    self.identityWindowController?.identification=id
                    self.documentProvider?.getDocument()?.send(IdentificationStates.userCreationHasBeenPrepared)
                    self.stepDelegate?.didValidateStep(self.stepIndex)
                }else{
                    self.messageTextField.stringValue=NSLocalizedString("Invalid phone number!", comment: "Invalid phone number!")
                }
            }else{
                self.messageTextField.stringValue=NSLocalizedString("Invalid email!", comment: "Invalid email!")
            }
        }
    }
    
    
}
