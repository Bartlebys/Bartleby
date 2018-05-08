//
//  ImportBKeyViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 17/08/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import BartlebyKit
import Cocoa
import Foundation

open class ImportBKeyViewController: StepViewController {
    open override var nibName: NSNib.Name { return NSNib.Name("ImportBKeyViewController") }

    @IBOutlet var box: NSBox!

    @IBOutlet var filePathField: NSTextField!

    @IBOutlet var deleteTheKeyCheckBox: NSButton!

    @IBOutlet var selectionButton: NSButton!

    var keyURL: URL?

    open override func viewWillAppear() {
        super.viewWillAppear()
        stepDelegate?.disableProgressIndicator()
    }

    @IBAction func didSelect(_: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["bky"]
        openPanel.begin { (result) -> Void in
            syncOnMain {
                if result == NSApplication.ModalResponse.OK {
                    if let url = openPanel.url {
                        self.filePathField.stringValue = url.path
                        self.keyURL = url
                        self.stepDelegate?.enableActions()
                    }
                } else {
                    // Nothing
                }
            }
        }
    }

    open override func proceedToValidation() {
        super.proceedToValidation()
        if let keyURL = self.keyURL,
            let document = self.documentProvider?.getDocument() {
            // Proceed to import
            do {
                let cryptedData = try Data(contentsOf: keyURL)
                let data = try Bartleby.cryptoDelegate.decryptData(cryptedData, useKey: Bartleby.configuration.KEY)
                let masterKey = try JSON.decoder.decode(MasterKey.self, from: data)
                document.metadata.sugar = masterKey.key
                if Bartleby.configuration.DEVELOPER_MODE {
                    print("The password is: \(masterKey.password)")
                }
                /// When the locker is verifyed use the sugar to retrieve the Collections and blocks data
                try document.reloadCollectionData()
                try document.metadata.putSomeSugarInYourBowl()
                if Bartleby.configuration.ALLOW_ISOLATED_MODE && Bartleby.configuration.AUTO_CREATE_A_USER_AUTOMATICALLY_IN_ISOLATED_MODE {
                    identityWindowController?.identificationIsValid = true
                }
                stepDelegate?.didValidateStep(stepIndex)

            } catch {
                displayMessage("\(error)")
            }
        }
    }

    func displayMessage(_: String) {
    }
}
