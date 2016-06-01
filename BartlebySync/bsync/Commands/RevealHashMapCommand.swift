//
//  RevealHashMapCommand.swift
//  bsync
//
//  Created by Martin Delille on 25/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

class RevealHashMapCommand: CommandBase {
    required init(completionHandler: CompletionHandler?)  {
        super.init(completionHandler: completionHandler)

        var secretKey: String = ""

        let env = NSProcessInfo.processInfo().environment
        if let key = env["BARTLEBY_SECRET_KEY"] {
            secretKey = key
        }

        let hashMapPathOption = StringOption(shortFlag: "f", longFlag: "file", required: true,
                                       helpMessage: "Path to the hashmap file.")

        // secret key is required only if no environment variable is defined and valid
        let secretKeyOption = StringOption(shortFlag: "i", longFlag: "secretKey", required: !Bartleby.isValidKey(secretKey),
                                     helpMessage: "The secret key to encryp the data")

        let sharedSalt = StringOption(shortFlag: "t", longFlag: "salt", required: true,
                                      helpMessage: "The salt used for authentication.")

        cli.addOptions(hashMapPathOption, secretKeyOption, sharedSalt)
        do {
            try cli.parse()

            if let key = secretKeyOption.value {
                if Bartleby.isValidKey(key) {
                    secretKey = key
                } else {
                    self.on(Completion.failureState("Bad encryption key: \(key)", statusCode: .Bad_Request))
                    return
                }

            }

            if let path = hashMapPathOption.value, let salt = sharedSalt.value {
                // Configure Bartleby without a specific URL
                Bartleby.configuration.KEY = secretKey
                Bartleby.configuration.SHARED_SALT = salt
                Bartleby.configuration.ENABLE_BPRINT = false
                Bartleby.sharedInstance.configureWith(Bartleby.configuration)

                let cryptedHashMap = try String(contentsOfFile: path)
                let hashmap = try Bartleby.cryptoDelegate.decryptString(cryptedHashMap)
                print(hashmap)
                self.on(Completion.successState())
            }
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }
}
