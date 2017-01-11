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

    @IBOutlet weak var box: NSBox!

    @IBOutlet weak var explanationsTextField: NSTextField!

    @IBOutlet weak var emailLabel: NSTextField!

    @IBOutlet weak var phoneNumberLabel: NSTextField!

    @IBOutlet weak var emailComboBox: NSComboBox!

    @IBOutlet weak var phoneCountryCodeLabel: NSTextField!

    @IBOutlet weak var phoneCountryCodeComboBox: NSComboBox!

    @IBOutlet weak var phoneNumberComboBox: NSComboBox!

    @IBOutlet weak var messageTextField: NSTextField!

    var countryCodes:[String]=["Greece (+30)","Netherlands (+31)","Belgium (+32)","France (+33)","United Kingdom (+44)"]

    override func viewWillAppear() {
        super.viewWillAppear()
        self.messageTextField.stringValue=""
        self.explanationsTextField.stringValue=NSLocalizedString("We need a valid email and a valid phone number. You can reuse previous identifications or create a new one for this document.", comment: "We need a valid email and a valid phone number. You can reuse previous identifications or create a new one for this document.")
        if let document=self.documentProvider?.getDocument(){
            let profiles=IdentitiesManager.suggestedProfiles(forDocument:document)
            for profile in profiles{
                if let email=profile.user?.email{
                    self.emailComboBox.addItem(withObjectValue: email)
                }
                if let phoneCountryCode=profile.user?.phoneCountryCode{
                    self.phoneCountryCodeComboBox.addItem(withObjectValue: phoneCountryCode)
                }
                if let phoneNumber=profile.user?.phoneNumber{
                    self.phoneNumberComboBox.addItem(withObjectValue: phoneNumber)
                }
            }
            self.emailComboBox.addItem(withObjectValue:NSLocalizedString("Add your Email", comment: "Add your Email"))
            self.phoneNumberComboBox.addItem(withObjectValue:NSLocalizedString("Phone number", comment: "Phone number"))
            for country in countryCodes.sorted(){
                self.phoneCountryCodeComboBox.addItem(withObjectValue: country)
            }
            self.emailComboBox.selectItem(at: 0)
            self.phoneCountryCodeComboBox.selectItem(at: 1)
            self.phoneNumberComboBox.selectItem(at: 0)

        }
    }

    @IBAction func didChange(_ sender: NSComboBox) {
        if sender != self.emailComboBox{
            self.emailComboBox.selectItem(at: sender.indexOfSelectedItem)
        }
        if sender != self.phoneNumberComboBox{
            self.phoneNumberComboBox.selectItem(at: sender.indexOfSelectedItem)
        }
    }



    override func proceedToValidation(){
        super.proceedToValidation()
        self.messageTextField.stringValue=""
        if let document=self.documentProvider?.getDocument(){
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
                    // We store the prepared identification
                    self.identityWindowController?.identification=id
                    self.stepDelegate?.didValidateStep(number: self.stepIndex)
                }else{
                    self.messageTextField.stringValue=NSLocalizedString("Invalid phone number!", comment: "Invalid phone number!")
                }
            }else{
                self.messageTextField.stringValue=NSLocalizedString("Invalid email!", comment: "Invalid email!")
            }
        }
    }
    
    
}
