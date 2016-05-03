//
//  CreateHashMapCommand.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 06/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Foundation

class CreateHashMapCommand: CommandBase {

    required init(completionHandler: ((completion: Completion) -> ())) {
        super.init(completionHandler: completionHandler)


        let folderPath = StringOption(shortFlag: "f", longFlag: "folder", required: true,
            helpMessage: "Path to the folder to hash.")

        let help = BoolOption(shortFlag: "h", longFlag: "help",
            helpMessage: "Prints a help message.")

        let verbosity = BoolOption(shortFlag: "v", longFlag: "verbose",
            helpMessage: "Print verbose messages.\n\n")

        cli.addOptions(folderPath, help, verbosity)

        do {
            try cli.parse()
            self.isVerbose=verbosity.value
            if let path=folderPath.value {
                var analyzer=BsyncLocalAnalyzer()
                do {
                    try analyzer.createHashMapFromLocalPath(path,
                        progressBlock: { (hash, path, index) -> Void in
                           self.printVerbose("#\(index) checksum of \(path) is \(hash)")
                        }, completionBlock: { (hashMap) -> Void in
                           self.printVerbose("End of hash map computation")
                            exit(EX_OK)
                    })
                } catch BsyncLocalAnalyzerError.InvalidURL(let explanations) {
                    print(explanations)
                    exit(EX__BASE)
                } catch {
                    print("Unexpected error \(error)")
                    exit(EX__BASE)
                }
            } else {
                print("Invalid folder path \(folderPath.value)")
                exit(EX__BASE)
            }
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }

}
