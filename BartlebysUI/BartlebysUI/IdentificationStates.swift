//
//  IdentificationStates.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 06/03/2017.
//
//

import BartlebyKit
import Foundation

// You should start by the IdentityWindowController to understand the variety of possible workflows.
// Bartleby supports a lot variations from distributed execution, to confined deployments.
public enum IdentificationStates: StateMessage {
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
    case sugarHasBeenRecovered // just after DocumentStates.collectionsDataHasBeenDecrypted
}
