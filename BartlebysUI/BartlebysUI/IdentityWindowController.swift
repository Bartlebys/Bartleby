//
//  IdentityWindowController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//  Copyright © 2016 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit

// MARK: - IdentifactionDelegate

public protocol IdentifactionDelegate{
    func userWantsToCloseIndentityController()
}


// MARK: - IdentityWindowController

/*
 To use the identity Controller

 1# Instantiate the IdentityWindowController
 2# Pass the document instance
 3# Register as IdentificationDelegate

 */
open class IdentityWindowController: MultiStepWindowController {


    override open var windowNibName: NSNib.Name? { return NSNib.Name("IdentityWindowController") }

    // You can set up a void IdentityWindowController by setting `
    // `IdentityWindowController.usesDefaultComponents = false`
    // It allows to reuse creational identified components
    // You should always roll back to `IdentityWindowController.usesDefaultComponents = true` afer usage
    public static var usesDefaultComponents:Bool = true

    // Document creation
    public var creationMode=false

    // Set to true when the key is not available in the local bowl
    public var activationMode=false{
        didSet{
            if activationMode==true{
                self.recoverTheKey()
            }
        }
    }


    public var identification:Identification?

    public var identificationIsValid=false

    public var identificationDelegate:IdentifactionDelegate?


    // MARK: - Update Password

    public var passwordCandidate:String=""


    // MARK: - Components

    // You can replace the components
    // By overriding the IdentityWindowController.

    @IBOutlet open var prepareUserCreation: PrepareUserCreationViewController!

    @IBOutlet open var createAnIsolatedUser: CreateAnIsolatedUser!

    @IBOutlet open var byPassActivation: ByPassActivationViewController!

    @IBOutlet open var confirmActivation: ConfirmActivationViewController!

    @IBOutlet open var setUpCollaborativeServer: SetupCollaborativeServerViewController!

    @IBOutlet open var revealPassword: RevealPasswordViewController!

    @IBOutlet open var validatePassword: ValidatePasswordViewController!

    @IBOutlet open var updatePassword: UpdatePasswordViewController!

    @IBOutlet open var updatePasswordConfirmation: ConfirmUpdatePasswordActivationCode!

    @IBOutlet open var recoverSugar: RecoverSugarViewController!

    @IBOutlet open var importBkey: ImportBKeyViewController!


    // MARK: - Life cycle

    override open func windowDidLoad() {
        super.windowDidLoad()
        self.configureControllers()
        self.progressIndicator.isHidden=true
        if Bartleby.configuration.DEVELOPER_MODE{
            if let document=self.getDocument(){
                IdentitiesManager.dumpKeyChainedProfiles(document)
            }
        }
    }

    open func configureControllers() -> () {
        if IdentityWindowController.usesDefaultComponents{
            if let document=self.getDocument(){
                if document.metadata.currentUserUID == Default.NO_UID {
                    // It is a new document
                    self.creationMode = true
                    if Bartleby.configuration.ALLOW_ISOLATED_MODE && Bartleby.configuration.AUTO_CREATE_A_USER_AUTOMATICALLY_IN_ISOLATED_MODE{
                          self.append(viewController: self.createAnIsolatedUser, selectImmediately: true)
                    }else{
                        self.append(viewController: self.prepareUserCreation, selectImmediately: true)
                        self.append(viewController: self.setUpCollaborativeServer, selectImmediately: false)
                        // Secondary Authentication factor management
                        if document.metadata.secondaryAuthFactorRequired{
                            self.append(viewController: self.confirmActivation, selectImmediately: false)
                        }else{
                            self.append(viewController: self.byPassActivation, selectImmediately: false)
                        }
                        // Revelation of the password
                        self.append(viewController: self.revealPassword, selectImmediately: false)
                    }
                }else{
                    self.creationMode=false
                    let isolatedMode = document.metadata.collaborationServerURL == nil
                    if document.metadata.sugar == Default.NO_SUGAR && isolatedMode{
                        // we need to import a bkey
                        self.append(viewController: self.importBkey, selectImmediately: true)
                        if Bartleby.configuration.ALLOW_ISOLATED_MODE  && Bartleby.configuration.AUTO_CREATE_A_USER_AUTOMATICALLY_IN_ISOLATED_MODE == false{
                            // We gonna control the password
                            self.append(viewController: self.validatePassword, selectImmediately: false)
                        }
                    }else{
                        self.append(viewController: self.validatePassword, selectImmediately: true)
                    }
                }
            }
        }else{
             //IdentityWindowController.usesDefaultComponents == false
        }
    }


    // MARK: -

    override var currentStepIndex:Int{
        didSet{
            if IdentityWindowController.usesDefaultComponents{
                // Standard method
                if self.tabView.tabViewItems.count > currentStepIndex && currentStepIndex >= 0{
                    self.tabView.selectTabViewItem(at: currentStepIndex)
                }else{
                    if currentStepIndex==3 && self.creationMode==true{
                        if let document=self.getDocument(){
                            document.send(IdentificationStates.userHasBeenCreated)
                        }
                    }
                    self._userHasBeenControlled()
                    self.identificationDelegate?.userWantsToCloseIndentityController()
                }
                // Define a different
                if self.currentStepIs(self.prepareUserCreation) && Bartleby.configuration.ALLOW_ISOLATED_MODE{
                    self.leftButton.title = NSLocalizedString("Skip", comment: "Skip button tittle")
                }else{
                    self.leftButton.title = NSLocalizedString("Cancel", comment: "Cancel button tittle")
                }
            }else{
                // IdentityWindowController.usesDefaultComponents == false
                if self.tabView.tabViewItems.count > currentStepIndex && currentStepIndex >= 0{
                    self.tabView.selectTabViewItem(at: currentStepIndex)
                }else{
                    self.identificationDelegate?.userWantsToCloseIndentityController()
                }
            }
        }
    }

    fileprivate func _userHasBeenControlled(){
        // This Does not mean the user is valid.
        if let document=self.getDocument(){
            document.metadata.userHasBeenControlled = true
        }
    }



    // MARK: - Actions

    @IBAction override func leftAction(_ sender: Any) {
        if IdentityWindowController.usesDefaultComponents{

            if let document = self.getDocument(){
                if (Bartleby.configuration.ALLOW_ISOLATED_MODE && self.currentStepIs(self.prepareUserCreation)){
                    // This can occur on very early stage cancelation
                    // If Bartleby.configuration.ALLOW_ISOLATED_MODE
                    self.removeAllSuccessors()
                    self.append(viewController: self.createAnIsolatedUser, selectImmediately: false)
                    self.append(viewController: self.revealPassword, selectImmediately: false)
                }else if document.metadata.isolatedUserMode{
                    // Close automatically
                    document.close()
                }else{
                    // Normal case.
                    self._userHasBeenControlled()
                    self.identificationDelegate?.userWantsToCloseIndentityController()
                }
            }
        }else{
            //IdentityWindowController.usesDefaultComponents == false
             self.identificationDelegate?.userWantsToCloseIndentityController()
        }
    }




    // MARK: - StepNavigation

    public override func didValidateStep(_ step:Int){
        // Do not call super
        if IdentityWindowController.usesDefaultComponents{
            syncOnMain{
                var proceedImmediately=true

                if self.currentStepIs(self.importBkey) &&
                    Bartleby.configuration.ALLOW_ISOLATED_MODE &&
                    Bartleby.configuration.AUTO_CREATE_A_USER_AUTOMATICALLY_IN_ISOLATED_MODE{
                    self.nextStep()
                    self.enableActions()
                }else if self.creationMode && !self.currentStepIs(self.createAnIsolatedUser) {
                    // The SMS / second factor auth has been verified or by passed
                    if self.currentStepIs(self.confirmActivation) || self.currentStepIs(self.byPassActivation){
                        // user is confirmed.
                        if let document=self.getDocument(){
                            proceedImmediately = false
                            document.currentUser.doNotCommit {
                                // We want to update the user status
                                // And then we will move online
                                // It permits to use PERMISSION_BY_IDENTIFICATION_AND_ACTIVATION
                                // for the majority of the CRUD/URD calls
                                document.currentUser.status = .actived
                                IdentitiesManager.synchronize(document,password:document.currentUser.password ?? Default.NO_PASSWORD, completed: { (completion) in
                                    if completion.success{
                                        document.online=true
                                        self.identificationIsValid=true
                                        self.nextStep()
                                        self.enableActions()
                                    }else{
                                        document.log("Activation status updated did fail \(completion)", file: #file, function: #function, line: #line, category: Default.LOG_IDENTITY, decorative: false)
                                        self.enableActions()
                                    }
                                })
                            }
                        }
                    }
                    if proceedImmediately{
                        self.nextStep()
                        self.enableActions()
                    }
                    if step > 2 {
                        self.leftButton.isEnabled=false
                    }
                }else{
                    // Not in creation Mode
                    // or we are using an Isolated Created user
                    if proceedImmediately{
                        self.nextStep()
                        self.enableActions()
                    }
                }
            }
        }else{
             //IdentityWindowController.usesDefaultComponents == false
            self.nextStep()
            self.enableActions()
        }
    }


    /// MARK: Activation

    public func recoverTheKey(){
        self.append(viewController: self.recoverSugar, selectImmediately: true)
    }


    /// MARK: Password Reset procedure

    public func resetMyPassword(){
        self.append(viewController: self.updatePassword, selectImmediately: true)
        self.append(viewController: self.updatePasswordConfirmation, selectImmediately: false)
    }


    /// Called by ConfirmUpdatePasswordActivationCode
    public func passwordHasBeenChanged(){
        self.getDocument()?.send(IdentificationStates.passwordHasBeenUpdated)
        self.currentStepIndex=0
        let u=self.tabView.tabViewItem(at: 1)
        let c=self.tabView.tabViewItem(at: 2)
        self.tabView.removeTabViewItem(u)
        self.tabView.removeTabViewItem(c)
        self.enableActions()
    }
    
}
