//
//  ConfirmPasswordActivationCode.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 17/01/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

class ConfirmPasswordActivationCode: IdentityStepViewController {

    @IBOutlet weak var consignsLabel: NSTextField!

    @IBOutlet weak var messageTextField: NSTextField!

    @IBOutlet weak var codeTextField: NSTextField!

    var code=Bartleby.randomStringWithLength(8,signs:Bartleby.configuration.PASSWORD_CHAR_CART)

    var confirmationIsImpossible=false


    override var nibName : String { return "ConfirmPasswordActivationCode" }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.consignsLabel.stringValue=""
        self.messageTextField.stringValue=""
        self.codeTextField.stringValue=""
        if Bartleby.configuration.DEVELOPER_MODE{
            print(self.code)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.stepDelegate?.disableActions()
        if let document = self.documentProvider?.getDocument(){
            let candidatePassword=self.identityWindowController?.passwordCandidate

            if let serverURL = document.metadata.collaborationServerURL,
                let email =  document.currentUser.email,
                let phoneNumber =  document.currentUser.phoneNumber{
                document.currentUser.login(sucessHandler: {
                    // we need now  relay the activation code
                    RelayActivationCode.execute(baseURL: serverURL,
                                                documentUID: document.UID,
                                                toEmail: email,
                                                toPhoneNumber: phoneNumber,
                                                code: self.code,
                                                title: NSLocalizedString("Your activation code", comment: "Your activation code"),
                                                body: NSLocalizedString("Your activation code is: \n$code", comment: "Your activation code is"),
                                                sucessHandler: { (context) in
                                                    self.stepDelegate?.enableActions()
                    }, failureHandler: { (context) in
                         self._confirmationIsImpossible()
                        document.log("\(context.responseString)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
                    })

                }, failureHandler: { (context) in
                    self._confirmationIsImpossible()
                })
            }
        }else{
            self._confirmationIsImpossible()
        }
    }

    fileprivate func _confirmationIsImpossible(){
        self.confirmationIsImpossible=true
        self.messageTextField.stringValue=NSLocalizedString("The confirmation is impossible. For security reason you must contact your support supervisor.", comment: "The confirmation is impossible. For security reason you must contact your support supervisor.")
        self.stepDelegate?.enableActions()
    }


    override func proceedToValidation() {
        super.proceedToValidation()
        self.stepDelegate?.disableActions()
        if let document = self.documentProvider?.getDocument(),
            let candidatePassword=self.identityWindowController?.passwordCandidate {
            if self.confirmationIsImpossible==false{
                if PString.trim(self.code)==PString.trim(self.codeTextField.stringValue){
                    document.currentUser.password=candidatePassword
                    // Will produce the syndication
                    IdentitiesManager.synchronize(document)
                    self.identityWindowController?.passwordHasBeenChanged()
                }else{
                    self.messageTextField.stringValue=NSLocalizedString("The activation code is not correct!", comment: "The activation code is not correct!")
                }
            }
        }
    }
}
