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

    @IBOutlet weak var explanationsTextField: NSTextField!

    @IBOutlet weak var serverComboBox: NSComboBox!

    @IBOutlet weak var messageTextField: NSTextField!

    override func viewWillAppear() {
        super.viewWillAppear()
        self.explanationsTextField.stringValue=NSLocalizedString("Select or register a Collaborative Server  API URL.", comment: "Select the Collaborative Server API URL")
        if let document=self.documentProvider?.getDocument(){
            var servers=Bartleby.configuration.defaultBaseURLList
            servers.append(NSLocalizedString("Add a Server", comment: "Add a Server"))
            self.serverComboBox.addItems(withObjectValues:servers)
            self.serverComboBox.selectItem(at: 0)
        }
    }

    override func proceedToValidation(){
        super.proceedToValidation()
        if let document=self.documentProvider?.getDocument(),
            let identityWindowController=self.identityWindowController{
            if let serverURL:URL=URL(string:self.serverComboBox.stringValue){
                Async.main{
                    HTTPManager.apiIsReachable(serverURL, successHandler: {
                        // We prefer to wait for reachability response before to disable the actions
                        self.stepDelegate?.disableActions()
                        // The server is Reachable
                        self.messageTextField.stringValue=""

                        // Should we create a USER?
                        var matchingProfile:Profile?
                        var userHasBeenFound=false
                        if let identification=identityWindowController.identification{
                            // Check if we should reuse a password or an external ID.
                            matchingProfile=IdentitiesManager.profileMatching(identification: identification, inDocument: document)
                            if let matchingProfile=matchingProfile{
                                if document.spaceUID == matchingProfile.documentSpaceUID &&
                                    PString.trim(document.baseURL.absoluteString) == PString.trim(matchingProfile.url.absoluteString){
                                    if let user = matchingProfile.user {
                                        // We should reuse the user.
                                        document.users.add(user, commit: false)
                                        document.metadata.currentUserUID=user.UID
                                        userHasBeenFound=true
                                    }
                                }
                            }
                        }

                        if userHasBeenFound==false{
                            // In rare situation we prefer to push manually the entities
                            // To do so we do not commit the object created by the newObject() factory
                            var user:User=document.newObject(commit:false)
                            user.email=identityWindowController.identification?.email
                            user.phoneCountryCode=identityWindowController.identification?.phoneCountryCode
                            user.phoneNumber=identityWindowController.identification?.phoneNumber
                            if let matchingProfile=matchingProfile {
                                if let matchingUser=matchingProfile.user{
                                    user.password=matchingUser.password
                                    user.externalID=matchingUser.externalID
                                }
                            }
                            document.metadata.currentUserUID=user.UID
                        }

                        func __postCreationPhase(user:User){
                            // The user has been successfully pushed
                            // Let's login
                            user.login(sucessHandler: {

                                let locker:Locker=document.newObject(commit:false)
                                locker.gems=document.metadata.sugar
                                locker.associatedDocumentUID=document.UID
                                locker.subjectUID=document.UID
                                locker.userUID=user.UID
                                locker.mode = .persistent
                                CreateLocker.execute(locker, in:  document.UID, sucessHandler: { (context) in
                                    
                                    let email=user.email!
                                    let phoneNumber=user.phoneNumber!

                                    // The Locker has been successfully pushed
                                    // we need now  to confirm the account
                                    RelayActivationCode.execute(baseURL: serverURL,
                                                                documentUID: document.UID,
                                                                fromEmail:email, // @TODO may be we should remove this option
                                        fromPhoneNumber: phoneNumber, //@TODO may be we should remove this option
                                        toEmail: email,
                                        toPhoneNumber: phoneNumber,
                                        code: locker.code, title: NSLocalizedString("Your activation code", comment: "Your activation code"),
                                        body: NSLocalizedString("Your activation code is: \n$code", comment: "Your activation code is"),
                                        sucessHandler: { (context) in
                                            document.log("\(context.message)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
                                            self.stepDelegate?.didValidateStep(number: self.stepIndex)
                                    }, failureHandler: { (context) in
                                        self.stepDelegate?.enableActions()
                                        document.log("\(context.responseString)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
                                        print("\(context.responseString)")
                                    })

                                }, failureHandler: { (context) in
                                    self.stepDelegate?.enableActions()
                                    self.messageTextField.stringValue="\(context.responseString)"
                                    document.log("\(context.message)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
                                })
                            }, failureHandler: { (context) in
                                self.stepDelegate?.enableActions()
                                self.messageTextField.stringValue="\(context.message)"
                                document.log("\(context.responseString)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
                            })

                        }

                        do{
                            // This will create and save the sugar cryptic key.
                            try document.metadata.cookThePie()

                            document.metadata.collaborationServerURL=serverURL
                            let user=document.users[0]
                            if userHasBeenFound{
                                __postCreationPhase(user: user)
                            }else{

                                CreateUser.execute(user, in: document.UID, sucessHandler: { (context) in
                                }, failureHandler: { (context) in
                                    __postCreationPhase(user: user)
                                    self.stepDelegate?.enableActions()
                                    self.messageTextField.stringValue="\(context.responseString)"
                                    document.log("\(context.responseString)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
                                })
                            }

                        }catch{
                            self.stepDelegate?.enableActions()
                            self.messageTextField.stringValue="\(error)"
                            document.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)

                        }

                    }, failureHandler: { (context) in
                        self.stepDelegate?.enableActions()
                        self.messageTextField.stringValue=NSLocalizedString("The server is not Reachable. Check carefully the URL.", comment: "The server is not Reachable. Check carefully the URL")+" Error code = \(context.httpStatusCode)"
                    })
                }
            }else{
                self.stepDelegate?.enableActions()
                self.messageTextField.stringValue=NSLocalizedString("This URL is not valid", comment: "This URL is not valid")
            }
        }
    }


}
