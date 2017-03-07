//
//  IdentificationStates.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 06/03/2017.
//
//

import Foundation
import BartlebyKit

public enum IdentificationStates:StateMessage{

    // Initial state
    case undefined

    // PrepareUserCreationViewController
    case prepareUserCreation
    case userCreationHasBeenPrepared

    // SetupCollaborativeServerViewController
    case selectTheServer
    case serverHasBeenSelected

    case createTheUser
    case userHasBeenCreated

    // RevealPasswordViewController
    case revealPassword

    // UpdatePasswordViewController -> IdentityWindowController
    case updatePassword

    // ConfirmUpdatePasswordActivationCode -> IdentityWindowController
    case passwordHasBeenUpdated

    // ValidatePasswordViewController
    case validatePassword
    case passwordsAreMatching

    // ConfirmActivationViewController
    case confirmAccount
    case accountHasBeenConfirmed

    // RecoverSugarViewController
    case recoverSugar
    case sugarHasBeenRecovered // just after PersistencyStates.collectionsDataHasBeenDecrypted
    
}
