//
//  ImportBKeyViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 17/08/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import Foundation
import Cocoa
import BartlebyKit

open class ImportBKeyViewController:IdentityStepViewController {

    override open var nibName : NSNib.Name { return NSNib.Name("ImportBKeyViewController") }

    @IBOutlet weak var box: NSBox!

    @IBOutlet weak var filePathField: NSTextField!

    @IBOutlet weak var deleteTheKeyCheckBox: NSButton!

    @IBOutlet weak var selectionButton: NSButton!

    var keyURL:URL?

    override open func viewWillAppear() {
        super.viewWillAppear()
        self.stepDelegate?.disableProgressIndicator()
     
    }


    @IBAction func didSelect(_ sender: NSButton) {
            let openPanel = NSOpenPanel()
            openPanel.allowsMultipleSelection = false
            openPanel.canChooseDirectories = false
            openPanel.canCreateDirectories = false
            openPanel.canChooseFiles = true
            openPanel.allowedFileTypes = ["bky"]
            openPanel.begin { (result) -> Void in
                syncOnMain {
                    if result == NSApplication.ModalResponse.OK  {
                        if let url=openPanel.url {
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



    override open func proceedToValidation(){
        super.proceedToValidation()
        if let keyURL = self.keyURL,
            let document = self.documentProvider?.getDocument(){
            // Proceed to import
            do{
                let cryptedData = try Data(contentsOf: keyURL)
                let data = try Bartleby.cryptoDelegate.decryptData(cryptedData, useKey: Bartleby.configuration.KEY)
                let masterKey = try JSON.decoder.decode(MasterKey.self, from:data)
                document.metadata.sugar = masterKey.key
                if Bartleby.configuration.DEVELOPER_MODE{
                    print("The password is: \(masterKey.password)")
                }
                /// When the locker is verifyed use the sugar to retrieve the Collections and blocks data
                try document.reloadCollectionData()
                try document.metadata.putSomeSugarInYourBowl()
                if Bartleby.configuration.AUTO_CREATE_A_USER_AUTOMATICALLY_IN_ISOLATED_MODE{
                    self.identityWindowController?.identificationIsValid = true
                }
                self.stepDelegate?.didValidateStep(self.stepIndex)

            }catch{
                self.displayMessage("\(error)")
            }
        }
    }


    func displayMessage(_ message:String){

    }

}
