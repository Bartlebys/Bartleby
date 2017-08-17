//
//  ImportBKeyViewController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 17/08/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

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
        self.stepDelegate?.disableActions()
        self.stepDelegate?.disableProgressIndicator()
     
    }


    @IBAction func didSelect(_ sender: NSButton) {
            let openPanel = NSOpenPanel()
            openPanel.allowsMultipleSelection = false
            openPanel.canChooseDirectories = false
            openPanel.canCreateDirectories = false
            openPanel.canChooseFiles = true
            openPanel.allowedFileTypes = ["bkey"]
            openPanel.begin { (result) -> Void in
                Bartleby.syncOnMain {
                    if result.rawValue == NSFileHandlingPanelOKButton {
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
        if let keyURL = self.keyURL{
            // Proceed to import
            do{
                let cryptedData = try Data(contentsOf: keyURL)
                let data = try Bartleby.cryptoDelegate.decryptData(cryptedData, useKey: Bartleby.configuration.KEY)
                let masterKey = try JSON.decoder.decode(MasterKey.self, from:data)
                print(masterKey)
            }catch{
                self.displayMessage("\(error)")
            }
            self.stepDelegate?.didValidateStep(self.stepIndex)
        }
    }


    func displayMessage(_ message:String){

    }

}
