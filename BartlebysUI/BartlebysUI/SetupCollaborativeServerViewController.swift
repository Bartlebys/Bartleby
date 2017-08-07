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

    // During dev you can setup to false (not to consume SMS credits)
    let relayActivationCode:Bool=false

    override var nibName : NSNib.Name { return NSNib.Name("SetupCollaborativeServerViewController") }

    @IBOutlet weak var box: NSBox!

    @IBOutlet weak var explanationsTextField: NSTextField!

    @IBOutlet weak var serverComboBox: NSComboBox!

    @IBOutlet weak var messageTextField: NSTextField!

    override func viewWillAppear() {
        super.viewWillAppear()
        self.documentProvider?.getDocument()?.send(IdentificationStates.selectTheServer)
        self.explanationsTextField.stringValue=NSLocalizedString("Select or register a Collaborative Server  API URL.", comment: "Select the Collaborative Server API URL")
        if let _ = self.documentProvider?.getDocument(){
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
                self.stepDelegate?.disableActions()
                Bartleby.syncOnMain{
                    HTTPManager.apiIsReachable(serverURL, successHandler: {
                        self.documentProvider?.getDocument()?.send(IdentificationStates.serverHasBeenSelected)
                        if let identification=identityWindowController.identification{
                            // We prefer to wait for reachability response before to disable the actions
                            // The server is Reachable
                            self.messageTextField.stringValue=""

                            // Should we create a USER?
                            var matchingProfile:Profile?
                            var userHasBeenFound=false

                            // Check if we should reuse a password or an external ID.
                            matchingProfile=IdentitiesManager.profileMatching(identification: identification, inDocument: document)
                            if let matchingProfile=matchingProfile{
                                if document.spaceUID == matchingProfile.documentSpaceUID &&
                                    PString.trim(document.baseURL.absoluteString) == PString.trim(matchingProfile.url.absoluteString){
                                    if let user = matchingProfile.user {
                                        // We should reuse the user.
                                        document.users.add(user, commit: false,isUndoable: false)
                                        document.metadata.configureCurrentUser(user)
                                        userHasBeenFound=true
                                    }
                                }
                            }


                            if userHasBeenFound==false{
                                // In rare situation we prefer to push manually the entities
                                // To do so we do not commit the object created by the newManagedModel() factory
                                var user:User=document.newManagedModel(commit:false)

                                user.email=identification.email
                                user.phoneCountryCode=identification.phoneCountryCode
                                user.phoneNumber=identification.phoneNumber
                                let externalID=identification.externalID
                                if externalID != Default.NO_UID{
                                    user.externalID=externalID
                                }
                                user.supportsPasswordSyndication=identification.supportsPasswordSyndication

                                if let matchingProfile=matchingProfile {
                                    if let matchingUser=matchingProfile.user{
                                        if user.supportsPasswordSyndication == true{
                                            user.password=matchingUser.password
                                            let externalID=matchingUser.externalID
                                            if externalID != Default.NO_UID{
                                                user.externalID=externalID
                                            }
                                        }
                                    }
                                }
                                document.metadata.configureCurrentUser(user)
                            }

                            func __postCreationPhase(user:User){
                                // The user has been successfully pushed
                                // Let's login
                                user.login(sucessHandler: {
                                    let locker:Locker=document.newManagedModel(commit:false)
                                    locker.startDate=Date()// now
                                    locker.endDate=Date.distantFuture//
                                    locker.doNotCommit {
                                        locker.gems=document.metadata.sugar
                                        locker.associatedDocumentUID=document.UID
                                        locker.subjectUID=document.UID
                                        locker.userUID=user.UID
                                        locker.mode = .persistent
                                        // Store the locker UID
                                        document.metadata.lockerUID=locker.UID

                                        CreateLocker.execute(locker, in:  document.UID, sucessHandler: { (context) in
                                            let email=user.email
                                            let phoneNumber=user.fullPhoneNumber

                                            if self.relayActivationCode{
                                                // The Locker has been successfully pushed
                                                // we need now  to confirm the account
                                                RelayActivationCode.execute(baseURL: serverURL,
                                                                            documentUID: document.UID,
                                                                            toEmail: email,
                                                                            toPhoneNumber: phoneNumber,
                                                                            code: locker.code, title: NSLocalizedString("Your activation code", comment: "Your activation code"),
                                                                            body: NSLocalizedString("Your activation code is: \n$code", comment: "Your activation code is"),
                                                                            sucessHandler: { (context) in
                                                                                self.stepDelegate?.didValidateStep( self.stepIndex)
                                                }, failureHandler: { (context) in
                                                    self.stepDelegate?.enableActions()
                                                    document.log("\(String(describing: context.responseString))", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
                                                })
                                            }else{
                                                self.stepDelegate?.didValidateStep( self.stepIndex)
                                            }

                                        }, failureHandler: { (context) in
                                            self.stepDelegate?.enableActions()
                                            self.messageTextField.stringValue="\(String(describing: context.responseString))"
                                            document.log("\(String(describing: context.message))", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
                                        })

                                    }
                                }, failureHandler: { (context) in
                                    self.stepDelegate?.enableActions()
                                    self.messageTextField.stringValue="\(String(describing: context.message))"
                                    document.log("\(String(describing: context.responseString))", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
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
                                    self.documentProvider?.getDocument()?.send(IdentificationStates.createTheUser)
                                    CreateUser.execute(user, in: document.UID, sucessHandler: { (context) in
                                         self.documentProvider?.getDocument()?.send(IdentificationStates.userHasBeenCreated)
                                        __postCreationPhase(user: user)
                                    }, failureHandler: { (context) in
                                        self.stepDelegate?.enableActions()
                                        self.messageTextField.stringValue="\(String(describing: context.responseString))"
                                        document.log("\(String(describing: context.responseString))", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
                                    })
                                }
                                
                            }catch{
                                self.stepDelegate?.enableActions()
                                self.messageTextField.stringValue="\(error)"
                                document.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
                                
                            }
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
