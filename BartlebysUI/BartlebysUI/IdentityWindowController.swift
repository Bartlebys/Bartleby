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
    func didValidateStep(_ step:Int)
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


    override public var windowNibName: NSNib.Name? { return NSNib.Name("IdentityWindowController") }

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

    // MARK: - Outlets

    @IBOutlet var prepareUserCreation: PrepareUserCreationViewController!

    @IBOutlet var byPassActivation: ByPassActivationViewController!

    @IBOutlet var confirmActivation: ConfirmActivationViewController!

    @IBOutlet var setUpCollaborativeServer: SetupCollaborativeServerViewController!

    @IBOutlet var revealPassword: RevealPasswordViewController!

    @IBOutlet var validatePassword: ValidatePasswordViewController!

    @IBOutlet var updatePassword: UpdatePasswordViewController!

    @IBOutlet var updatePasswordConfirmation: ConfirmUpdatePasswordActivationCode!

    @IBOutlet var recoverSugar: RecoverSugarViewController!

    @IBOutlet weak var tabView: NSTabView!

    @IBOutlet weak var leftButton: NSButton!

    @IBOutlet weak var rightButton: NSButton!

    @IBOutlet weak var progressIndicator: NSProgressIndicator!

    // MARK: - Life cycle

    override public func windowDidLoad() {
        super.windowDidLoad()
        self._configureControllers()
        self.progressIndicator.isHidden=true
        if Bartleby.configuration.DEVELOPER_MODE{
            if let document=self.getDocument(){
                IdentitiesManager.dumpKeyChainedProfiles(document)
            }
        }
    }

    fileprivate func _configureControllers() -> () {
        if let document=self.getDocument(){
            if document.metadata.currentUserUID == Default.NO_UID {
                self.creationMode=true
                // It is a new document
                self.append(viewController: self.prepareUserCreation, selectImmediately: true)
                self.append(viewController: self.setUpCollaborativeServer, selectImmediately: false)
                if document.metadata.secondaryAuthFactorRequired{
                     self.append(viewController: self.confirmActivation, selectImmediately: false)
                }else{
                    self.append(viewController: self.byPassActivation, selectImmediately: false)
                }
                self.append(viewController: self.revealPassword, selectImmediately: false)
            }else{
                self.creationMode=false
                self.append(viewController: self.validatePassword, selectImmediately: true)
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
            self.currentStep=viewController.stepIndex
        }
    }


    /// Removes the viewController
    ///
    /// - Parameter viewController: the view controller to remove
    public func remove(viewController:IdentityStepViewController){
        let nb=self.tabView.tabViewItems.count
        for i in 0..<nb{
            let item=self.tabView.tabViewItems[i]
            if item.viewController==viewController{
                self.tabView.removeTabViewItem(item)
                break
            }
        }
    }

    fileprivate func _currentStepIs(_ viewController:IdentityStepViewController)->Bool{
        if self.tabView.tabViewItems.count > self.currentStep{
            let item=self.tabView.tabViewItems[self.currentStep]
            let matching=item.viewController?.className==viewController.className
            return matching
        }else{
            return false
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
                        document.send(IdentificationStates.userHasBeenCreated)
                    }
                }
                self._userHasBeenControlled()
                self.identificationDelegate?.userWantsToCloseIndentityController()
            }
        }
    }

    fileprivate func _userHasBeenControlled(){
        // This Does not mean the user is valid.
        if let document=self.getDocument(){
            document.metadata.userHasBeenControlled = true
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
        self._userHasBeenControlled()
        self.identificationDelegate?.userWantsToCloseIndentityController()
    }

    @IBAction func rightAction(_ sender: Any) {
        self.currentIdentityStep?.proceedToValidation()
    }


    // MARK: - IdentityStepNavigation

    public func didValidateStep(_ step:Int){
        Bartleby.syncOnMain{
            var proceedImmediately=true
            if self.creationMode {
                // The SMS / second factor auth has been verified or by passed
                if self._currentStepIs(self.confirmActivation) || self._currentStepIs(self.byPassActivation){
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
                                    document.log("Activation status updated did fail \(completion)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
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
                if proceedImmediately{
                    self.nextStep()
                    self.enableActions()
                }
            }
        }
    }

    public func disableActions(){
        self.enableProgressIndicator()
        self.leftButton.isEnabled=false
        self.rightButton.isEnabled=false
    }

    public func enableActions(){
        self.disableProgressIndicator()
        self.leftButton.isEnabled=true
        self.rightButton.isEnabled=true
    }

    public func enableProgressIndicator(){
        self.progressIndicator.isHidden=false
        self.progressIndicator.startAnimation(self)
    }

    public func disableProgressIndicator(){
        self.progressIndicator.isHidden=true
        self.progressIndicator.stopAnimation(self)
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
        self.currentStep=0
        let u=self.tabView.tabViewItem(at: 1)
        let c=self.tabView.tabViewItem(at: 2)
        self.tabView.removeTabViewItem(u)
        self.tabView.removeTabViewItem(c)
        self.enableActions()
    }
    
}
