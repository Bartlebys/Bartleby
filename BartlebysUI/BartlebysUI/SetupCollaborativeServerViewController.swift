//
//  SetupCollaborativeServerViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//  Copyright © 2016 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

class SetupCollaborativeServerViewController: IdentityStepViewController{

    override var nibName : String { return "SetupCollaborativeServerViewController" }

    @IBOutlet weak var box: NSBox!

    @IBOutlet weak var explanationTextField: NSTextField!

    @IBOutlet weak var serverComboBox: NSComboBox!

    @IBOutlet weak var messageTextField: NSTextField!

    override func viewWillAppear() {
        super.viewWillAppear()
        self.explanationTextField.stringValue=NSLocalizedString("Select or register a Collaborative Server  API URL.", comment: "Select the Collaborative Server API URL")
        if let document=self.documentProvider?.getDocument(){
            var servers=Bartleby.configuration.defaultBaseURLList
            servers.append(NSLocalizedString("Add a Server", comment: "Add a Server"))
            self.serverComboBox.addItems(withObjectValues:servers)
            self.serverComboBox.selectItem(at: 0)
        }
    }

    override func proceedToValidation(){
        super.proceedToValidation()
        if let serverURL:URL=URL(string:self.serverComboBox.stringValue){
            Async.main{
                HTTPManager.apiIsReachable(serverURL, successHandler: {
                    // Everything is OK
                    self.messageTextField.stringValue=""
                    // Send the confirmation code.
                    self.stepDelegate?.didValidateStep(number: self.stepIndex)
                }, failureHandler: { (context) in
                    self.messageTextField.stringValue=NSLocalizedString("The server is not Reachable. Check carefully the URL.", comment: "The server is not Reachable. Check carefully the URL")+" Error code = \(context.httpStatusCode)"
                })
            }
        }else{
            self.messageTextField.stringValue=NSLocalizedString("This URL is not valid", comment: "This URL is not valid")
        }


        // You should call:
        //
        //      self.stepDelegate?.didValidateStep(number: self.stepIndex)
        //      or
        //      self.stepDelegate?.didFailValidatingStep(number: self.stepIndex)
    }


}
