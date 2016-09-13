//
//  CleanupCommand.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 06/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license


import Foundation

class CleanupCommand: CommandBase {
    
    required init(completionHandler: CompletionHandler?){
        super.init(completionHandler: completionHandler)
        
        let folderPath = StringOption(shortFlag: "p", longFlag: "path", required: true,
                                      helpMessage: "Path to the folder to be clean.")
        let help = BoolOption(shortFlag: "h", longFlag: "help",
                              helpMessage: "Prints a help message.")
        let verbosity = BoolOption(shortFlag: "v", longFlag: "verbose",
                                   helpMessage: "Print verbose messages.\n\n")
        addOptions(options: folderPath, help, verbosity)
        if parse() {
            self.isVerbose=verbosity.value
            do {
                let messages=try BsyncAdmin.cleanupFolder(folderPath.value!)
                for message in messages {
                    self.printVerbose(string: message)
                }
                exit(EX_OK)
            } catch {
                self.on(Completion.failureStateFromError(error))
            }
        }
    }
    
    
}
