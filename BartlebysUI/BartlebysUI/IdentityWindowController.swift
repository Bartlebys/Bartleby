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

// MARK: - IdentityStepNavigation

public protocol IdentityStepNavigation{
    func didValidateStep(number:Int)
    func disableActions()
    func enableActions()
}

// MARK: - IdentityStep

public protocol IdentityStep{
    var stepIndex:Int { get set }
    func proceedToValidation()
}



// MARK: - IdentityWindowController


/*
 To use the identity Controller

 1# Instantiate the IdentityWindowController
 2# Pass the document instance
 3# Register as IdentificationDelegate

 */
public class IdentityWindowController: NSWindowController,DocumentProvider,IdentityStepNavigation {


    override public var windowNibName: String? { return "IdentityWindowController" }

    // MARK: DocumentDependent

    /// Returns a BartlebyDocument
    /// Generally used in  with `DocumentDependent` protocol
    ///
    /// - Returns: the document
    public func getDocument() -> BartlebyDocument?{
        return self.document as? BartlebyDocument
    }

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

    public var passwordResetCode:String=""

    // MARK: - Outlets

    @IBOutlet var prepareUserCreation: PrepareUserCreationViewController!

    @IBOutlet var confirmActivation: ConfirmActivationViewController!

    @IBOutlet var setUpCollaborativeServer: SetupCollaborativeServerViewController!

    @IBOutlet var revealPassword: RevealPasswordViewController!

    @IBOutlet var validatePassword: ValidatePasswordViewController!

    @IBOutlet var updatePassword: UpdatePasswordViewController!

    @IBOutlet var recoverSugar: RecoverSugarViewController!

    @IBOutlet weak var tabView: NSTabView!

    @IBOutlet weak var leftButton: NSButton!

    @IBOutlet weak var rightButton: NSButton!


    // MARK: - Life cycle

    override public func windowDidLoad() {
        super.windowDidLoad()
        self.configureControllers()
    }

    func configureControllers() -> () {
        if let document=self.getDocument(){
            if document.metadata.currentUserUID == Default.NO_UID {

                self.creationMode=true
                // It is a new document

                let prepareUserCreationItem=NSTabViewItem(viewController:self.prepareUserCreation)
                self.prepareUserCreation.documentProvider=self
                self.prepareUserCreation.stepDelegate=self
                self.prepareUserCreation.stepIndex=0
                self.tabView.addTabViewItem(prepareUserCreationItem)

                let setupServerItem=NSTabViewItem(viewController:self.setUpCollaborativeServer)
                self.setUpCollaborativeServer.documentProvider=self
                self.setUpCollaborativeServer.stepDelegate=self
                self.setUpCollaborativeServer.stepIndex=1
                self.tabView.addTabViewItem(setupServerItem)

                let confirmActivationItem=NSTabViewItem(viewController:self.confirmActivation)
                self.confirmActivation.documentProvider=self
                self.confirmActivation.stepDelegate=self
                self.confirmActivation.stepIndex=2
                self.tabView.addTabViewItem(confirmActivationItem)

                let revealPasswordItem=NSTabViewItem(viewController:self.revealPassword)
                self.revealPassword.documentProvider=self
                self.revealPassword.stepDelegate=self
                self.revealPassword.stepIndex=3
                self.tabView.addTabViewItem(revealPasswordItem)
                self.currentStep=0
            }else{
                self.creationMode=false

                let validatePasswordItem=NSTabViewItem(viewController:self.validatePassword)
                self.validatePassword.documentProvider=self
                self.validatePassword.stepDelegate=self
                self.validatePassword.stepIndex=0
                self.tabView.addTabViewItem(validatePasswordItem)

                self.currentStep=0

            }
        }
    }



    /// Appends a view Controller to the stack
    ///
    /// - Parameters:
    ///   - viewController: an IdentityStepViewController children
    ///   - selectImmediately: display immediately the added view Controller
    public func append(viewController:IdentityStepViewController,selectImmediately:Bool){
        let viewControllerItem=NSTabViewItem(viewController:viewController)
        viewController.documentProvider=self
        viewController.stepDelegate=self
        viewController.stepIndex=self.tabView.tabViewItems.count
        self.tabView.addTabViewItem(viewControllerItem)
        if selectImmediately{
            self.tabView.selectTabViewItem(at: viewController.stepIndex)
        }
    }


    // MARK: -

    var currentStep:Int = -1{
        didSet{
            if self.tabView.tabViewItems.count > currentStep && currentStep >= 0{
                self.tabView.selectTabViewItem(at: currentStep)
            }else{
                if currentStep==3 && self.creationMode==true{
                    if let document=self.getDocument(){
                        document.currentUserHasBeenCreated()
                    }
                }
                self.identificationDelegate?.userWantsToCloseIndentityController()
            }
        }
    }

    var currentIdentityStep:IdentityStep?{
        let vc =  self.tabView.selectedTabViewItem?.viewController
        return vc as? IdentityStep
    }

    func nextStep(){
        self.currentStep += 1
    }

    // MARK: - Actions

    @IBAction func leftAction(_ sender: Any) {
        self.identificationDelegate?.userWantsToCloseIndentityController()
    }

    @IBAction func rightAction(_ sender: Any) {
        self.currentIdentityStep?.proceedToValidation()
    }


    // MARK: - IdentityStepNavigation

    public func didValidateStep(number:Int){
        var proceedImmediately=true
        if self.creationMode {
            if number == 0{}
            if number == 1{}
            // The SMS / second factor auth has been verified.
            if number == 2{
                // user is confirmed.
                if let document=self.getDocument(){
                    proceedImmediately = false
                    document.currentUser.doNotCommit {
                        // We want to update the user status
                        // And then we will move online
                        // It permits to use PERMISSION_BY_IDENTIFICATION_AND_ACTIVATION 
                        // for the majority of the CRUD/URD calls
                        document.currentUser.status = .actived
                        UpdateUser.execute(document.currentUser, in: document.UID,
                                           sucessHandler: { (context) in

                                            IdentitiesManager.synchronize(document)
                                            document.online=true
                                            self.identificationIsValid=true
                                            self.nextStep()
                                            self.enableActions()
                        }, failureHandler: { (context) in
                            document.log("Activation status updated did fail \(context)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
                            self.enableActions()
                        })
                        // Mark as committed to prevent from re-upserting
                        document.currentUser.hasBeenCommitted()
                    }
                }
            }
            if number == 3 {}
            if proceedImmediately{
                self.nextStep()
                self.enableActions()
            }
            if number > 2 {
                self.leftButton.isEnabled=false
            }
        }else{
            if proceedImmediately{
                self.nextStep()
                self.enableActions()
            }
        }
    }
    
    public func disableActions(){
        self.leftButton.isEnabled=false
        self.rightButton.isEnabled=false
    }

    public func enableActions(){
        
        self.leftButton.isEnabled=true
        self.rightButton.isEnabled=true
    }
    

    /// MARK: Activation 

    public func recoverTheKey(){
        /// Go to activation screen.
        let recoverSugarItem=NSTabViewItem(viewController:self.recoverSugar)
        self.recoverSugar.documentProvider=self
        self.recoverSugar.stepDelegate=self
        self.recoverSugar.stepIndex=1
        self.tabView.addTabViewItem(recoverSugarItem)
        self.currentStep=1
    }


    /// MARK: Password Reset procedure


    public func resetMyPassword(){
        let updatePasswordItem=NSTabViewItem(viewController:self.updatePassword)
        self.updatePassword.documentProvider=self
        self.updatePassword.stepDelegate=self
        self.updatePassword.stepIndex=1
        self.tabView.addTabViewItem(updatePasswordItem)
        self.currentStep=1

        /// + CONFIRMATION ?  ConfirmPassword...
        ///

        /// IL Est POSSIBLE QUE NOUS N'AYONS PAS LE DROIT DE LE FAIRE
        /// PREVOIR L IMPOSSIBILITE ( pas de bouton reset sur certains doc?)

        ///


    }

    /// APPELER password has been changed après le changement
    public func passwordHasBeenChanged(){
        self.currentStep=0
        let u=self.tabView.tabViewItem(at: 1)
        let c=self.tabView.tabViewItem(at: 2)
        self.tabView.removeTabViewItem(u)
        self.tabView.removeTabViewItem(c)
    }


}


