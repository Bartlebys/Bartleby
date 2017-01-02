//
//  IdentityWindowController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//  Copyright © 2016 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit


public protocol IdentifactionDelegate{
    func userWantsToClose()
}

/*
  To use the identity Controller

  1# Instantiate the IdentityWindowController
  2# Pass the document instance
  3# Register as IdentificationDelegate
 
 */
public class IdentityWindowController: NSWindowController,DocumentProvider {

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


    // MARK: -

    override public func windowDidLoad() {
        super.windowDidLoad()
        self.configureControllers()
    }

    func configureControllers() -> () {
        if let document=self.getDocument(){

        }else{
            print("NO DOCUMENT **")
        }
    }
   

    @IBAction func leftAction(_ sender: Any) {
        self.window?.close()
    }

    @IBAction func rightAction(_ sender: Any) {
    }

}
