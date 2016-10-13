//
//  BsyncDMGCard.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 28/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
    import BartlebyKit
#endif



extension BsyncDMGCard {
    
    /// Returns the absolute volume path
    open var volumePath: String {
        get {
            return "/Volumes/\(volumeName)/"
        }
    }

    open var standardDirectivesPath: String {
        get {
            if self.directivesRelativePath != BsyncDMGCard.NO_PATH {
                return self.volumePath+"\(self.directivesRelativePath)"
            } else {
                return self.volumePath+"\(BsyncDirectives.DEFAULT_FILE_NAME)"
            }

        }
    }

    /**
     Evaluates the validity of the card

     - returns: a block
     */
    open func evaluate() -> Completion {
        // Test the path
        let url=URL(fileURLWithPath:imagePath, isDirectory:false)
        let ext=url.pathExtension
        if ext != BsyncDMGCard.DMG_EXTENSION {
            return Completion.failureState(NSLocalizedString("Invalid path extension. The path must end by .\(BsyncDMGCard.DMG_EXTENSION). Current path:", comment: "Invalid path extension.")+"\(imagePath)", statusCode: .bad_Request)
        }

        // Verify that everything has been set.
        if (userUID == BsyncDMGCard.NOT_SET ||
            contextUID == BsyncDMGCard.NOT_SET ||
            imagePath == BsyncDMGCard.NO_PATH ||
            volumeName == BsyncDMGCard.NOT_SET) {
            return Completion.failureState(NSLocalizedString("The card is not correctly configured userUID,contextUID,path and volumeName must be set.", comment: "The card is not correctly configured.")+"\nuserUID = \(userUID),\ncontextUID = \(contextUID),\npath= \(imagePath),\n volumeName = \(volumeName)\n", statusCode: .bad_Request)
        } else {
            return Completion.successState()
        }
    }


    /**
     Returns a password.
     To be valid the userUID, contextUID must be consistant
     and bartleby should have be correctly initialized.

     - returns: the password
     */
    open func getPasswordForDMG() -> String {
        // This method will not return a correct password if Bartleby is not correctly initialized.
        do {
            return try CryptoHelper.hash(Bartleby.cryptoDelegate.encryptString(contextUID+userUID+Bartleby.configuration.SHARED_SALT))
        } catch {
            bprint("\(error)", file: #file, function: #function, line: #line)
            return "default-password-on-crypto-failure"
        }
    }

    
}
