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
     The CommandLine mode execution
     */
    func executeCMD() {
        
        let filePath = StringOption(shortFlag: "f", longFlag: "file", required: true,
                                    helpMessage: "Path to the directive file.")
        
        let secretKey = StringOption(shortFlag: "i", longFlag: "secretKey", required: true,
                                     helpMessage: "The secret key to encryp the data (if not set we use bsync's default)")
        
        let sharedSalt = StringOption(shortFlag: "t", longFlag: "salt", required: true,
                                      helpMessage: "The salt (if not set we use bsync's default)")
        
        // Optional
        let api = StringOption(shortFlag: "a", longFlag: "api",
                               helpMessage: "Bartleby base url e.g http://yd.local/api/v1")

        let help = BoolOption(shortFlag: "h", longFlag: "help",
                              helpMessage: "Prints a help message.")
        
        addOptions(options: filePath, secretKey, sharedSalt, help)
        if parse() {
            if let api = api.value, let url = URL(string: api) {
                Bartleby.configuration.API_BASE_URL = url
            }
            
            if let filePath = filePath.value, let key = secretKey.value, let salt = sharedSalt.value {
                Bartleby.configuration.KEY = key
                Bartleby.configuration.SHARED_SALT = salt
                Bartleby.configuration.API_CALL_TRACKING_IS_ENABLED = false
                Bartleby.sharedInstance.configureWith(Bartleby.configuration)

                let admin = BsyncAdmin()
             
                do {
                    let directives = try admin.loadDirectives(filePath)
                    admin.runDirectives(directives, sharedSalt: salt, handlers: self)
                } catch {
                    self.on(Completion.failureStateFromError(error))
                }
            } else {
                self.on(Completion.failureState("Unwrapping error", statusCode: .undefined))
            }
        }
    }
}
