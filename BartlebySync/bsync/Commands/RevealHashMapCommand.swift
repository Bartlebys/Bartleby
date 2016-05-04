//
//  RevealHashMapCommand.swift
//  bsync
//
//  Created by Martin Delille on 25/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

class RevealHashMapCommand: CommandBase {
    required init(completionHandler: ((completion: Completion) -> ())) {
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

        cli.addOptions(hashMapPathOption, secretKeyOption)
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

            if let path = hashMapPathOption.value {

                // Configure Bartleby without a specific URL
                Bartleby.configuration.KEY = secretKey
                Bartleby.sharedInstance.configureWith(Bartleby.configuration)

                let fm = BFileManager()

                fm.readString(contentsOfFile: path, handlers: Handlers { (read) in
                    if let encryptedHashMapString = read.getStringResult() where read.success {
                        do {
                            let decryptedHashMapString = try Bartleby.cryptoDelegate.decryptString(encryptedHashMapString)
                            print("# Hash map \(path) #\n\(decryptedHashMapString)\n# End of hash map #")
                            self.on(Completion.successState())
                        } catch {
                            self.on(Completion.failureState("Error decrypting \"\(encryptedHashMapString)", statusCode: .Precondition_Failed))
                        }
                    } else {
                        self.on(read)
                    }
                })
            }
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }
}
