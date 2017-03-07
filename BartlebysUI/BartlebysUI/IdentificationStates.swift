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

    public typealias RawValue = String

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

    public init?(rawValue: IdentificationStates.RawValue) {
        self = .undefined

        if rawValue == "prepareUserCreation"{
            self = .prepareUserCreation
        }
        if rawValue == "userCreationHasBeenPrepared"{
            self = .userCreationHasBeenPrepared
        }
        if rawValue == "selectTheServer"{
            self = .selectTheServer
        }
        if rawValue == "serverHasBeenSelected"{
            self = .serverHasBeenSelected
        }
        if rawValue == "createTheUser"{
            self = .createTheUser
        }
        if rawValue == "userHasBeenCreated"{
            self = .userHasBeenCreated
        }
        if rawValue == "revealPassword"{
            self = .revealPassword
        }
        if rawValue == "updatePassword"{
            self = .updatePassword
        }
        if rawValue == "passwordHasBeenUpdated"{
            self = .passwordHasBeenUpdated
        }
        if rawValue == "validatePassword"{
            self = .validatePassword
        }
        if rawValue == "passwordsAreMatching"{
            self = .passwordsAreMatching
        }
        if rawValue == "confirmAccount"{
            self = .confirmAccount
        }
        if rawValue == "accountHasBeenConfirmed"{
            self = .accountHasBeenConfirmed
        }
        if rawValue == "recoverSugar"{
            self = .recoverSugar
        }
        if rawValue == "sugarHasBeenRecovered"{
            self = .sugarHasBeenRecovered
        }
    }

    public var rawValue: String{
        switch self {
        case .undefined:
            return "undefined"
        case .prepareUserCreation:
            return "prepareUserCreation"
        case .userCreationHasBeenPrepared:
            return "userCreationHasBeenPrepared"
        case .selectTheServer:
            return "selectTheServer"
        case .serverHasBeenSelected:
            return "serverHasBeenSelected"
        case .createTheUser:
            return "createTheUser"
        case .userHasBeenCreated:
            return "userHasBeenCreated"
        case .revealPassword:
            return "revealPassword"
        case .updatePassword:
            return "updatePassword"
        case .passwordHasBeenUpdated:
            return "passwordHasBeenUpdated"
        case .validatePassword:
            return "validatePassword"
        case .passwordsAreMatching:
            return "passwordsAreMatching"
        case .confirmAccount:
            return "confirmAccount"
        case .accountHasBeenConfirmed:
            return "accountHasBeenConfirmed"
        case .recoverSugar:
            return "recoverSugar"
        case .sugarHasBeenRecovered:
            return "sugarHasBeenRecovered"
        }
    }
    
}
