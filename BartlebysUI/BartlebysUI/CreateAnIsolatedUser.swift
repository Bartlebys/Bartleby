//
//  CreateAnIsolatedUser.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 12/08/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//

import Cocoa
import BartlebyKit


// Creates automatically a single User in off line mode
class CreateAnIsolatedUser: IdentityStepViewController {

    override var nibName : NSNib.Name { return NSNib.Name("CreateAnIsolatedUser") }

    override func viewWillAppear() {
        super .viewWillAppear()
        self._createAnIsolatedUser()
        self.stepDelegate?.didValidateStep(self.stepIndex)
    }


    fileprivate func _createAnIsolatedUser(){
        if let document = self.documentProvider?.getDocument(){
            let user:User = document.newManagedModel(commit:false)
            user.isIsolated = true
            document.metadata.isolatedUserMode = true
            document.metadata.configureCurrentUser(user)
            // We setup a sugar to enable the crypto
            // But this sugar has not been stored on any server.
            // That why we will propose to save a MasterKey
            // There is no way to get back the data if the bowl is deleted.
            document.metadata.sugar=Bartleby.randomStringWithLength(1024)
            document.hasChanged()
            do{
                try document.metadata.putSomeSugarInYourBowl() // Save the key
                document.send(IdentificationStates.sugarHasBeenRecovered)
                self.identityWindowController?.identificationIsValid=true
            }catch{
                document.log("\(error)",category: Default.LOG_IDENTITY)
            }

        }
    }

}
