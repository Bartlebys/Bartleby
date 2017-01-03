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

protocol IdentityStepNavigation{
    func didValidateStep(number:Int)
    func didFailValidatingStep(number:Int)
}

// MARK: - IdentityStep

protocol IdentityStep{
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

    public var identificationDelegate:IdentifactionDelegate?

    // MARK: - Outlets

    @IBOutlet var createUser: CreateUserViewController!

    @IBOutlet var confirmActivation: ConfirmActivationViewController!

    @IBOutlet var setUpCollaborativeServer: SetupCollaborativeServerViewController!

    @IBOutlet var validatePassword: ValidatePasswordViewController!

    @IBOutlet var updatePassword: UpdatePasswordViewController!

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
            if document.metadata.currentUserUID == Default.NO_UID{
                // It is a new document

                let createUserItem=NSTabViewItem(viewController:self.createUser)
                self.createUser.documentProvider=self
                self.createUser.stepDelegate=self
                self.createUser.stepIndex=0
                self.tabView.addTabViewItem(createUserItem)

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

                self.currentStep=0
            }
        }
    }

    // MARK: 

    var currentStep:Int = -1{
        didSet{
            if self.tabView.tabViewItems.count > currentStep && currentStep >= 0{
                self.tabView.selectTabViewItem(at: currentStep)
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
        self.nextStep()
    }

    public func didFailValidatingStep(number:Int){
        
    }


}


