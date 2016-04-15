//
//  CleanupCommand.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 06/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license


import Foundation

class CleanupCommand:CommandBase {
    
    override init() {
        super.init()
        let folderPath = StringOption(shortFlag: "p", longFlag: "path", required: true,
            helpMessage: "Path to the folder to be clean.")
        let help = BoolOption(shortFlag: "h", longFlag: "help",
            helpMessage: "Prints a help message.")
        let verbosity = BoolOption(shortFlag: "v", longFlag: "verbose",
            helpMessage: "Print verbose messages.\n\n")
        cli.addOptions(folderPath, help, verbosity)
        do {
            try cli.parse()
            self.isVerbose=verbosity.value
                do {
                    let messages=try BsyncAdmin.cleanupFolder(folderPath.value!)
                    for message in messages{
                        self.printVerbose(message)
                    }
                    exit(EX_OK)
                }catch{
                    print("\(error)")
                    exit(EX__BASE)
                }
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }


}