//
//  RunDirectivesCommand.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 06/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Foundation

/*

*/
class RunDirectivesCommand: CommandBase {

    required init(completionHandler: CompletionHandler?){
        super.init(completionHandler: completionHandler)
    }

    /**
     The commandline mode execution
     */
    func executeCMD() {

        let filePath = StringOption(shortFlag: "f", longFlag: "file", required: true,
            helpMessage: "Path to the directive file.")

        let secretKey = StringOption(shortFlag: "i", longFlag: "secretKey", required: true,
            helpMessage: "The secret key to encryp the data (if not set we use bsync's default)")

        let sharedSalt = StringOption(shortFlag: "t", longFlag: "salt", required: true,
            helpMessage: "The salt (if not set we use bsync's default)")

        let help = BoolOption(shortFlag: "h", longFlag: "help",
            helpMessage: "Prints a help message.")

        let verbosity = BoolOption(shortFlag: "v", longFlag: "verbose",
            helpMessage: "Print verbose messages.\n\n")

        cli.addOptions(filePath, secretKey, sharedSalt, help, verbosity)
        do {
            try cli.parse()
            self.isVerbose=verbosity.value
            let key = secretKey.value!
            let salt = sharedSalt.value!

            let runner = BsyncDirectivesRunner()
            runner.runDirectives(filePath.value!, secretKey: key, sharedSalt: salt, handlers: self)

        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }
}
