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
        
        cli.addOptions(filePath, secretKey, sharedSalt, help)
        do {
            try cli.parse()
            if let filePath = filePath.value, let salt = sharedSalt.value {
                // TODO: @md Configure Bartleby before running directives
                
                let directives = try BsyncDirectives.load(filePath)
                directives.run(salt, handlers: self)
            } else {
                self.on(Completion.failureState("Unwrapping error", statusCode: .Undefined))
            }
            
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }
}
