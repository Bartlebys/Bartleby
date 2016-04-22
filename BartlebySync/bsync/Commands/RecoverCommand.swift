//
//  RecoverCommand.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 06/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Foundation


class RecoverCommand:CommandBase {
    
    required init(completionBlock: ((success: Bool, message: String?) -> ())) {
        super.init(completionBlock: completionBlock)
        
        let sourcePath = StringOption(shortFlag: "s", longFlag: "snapshot", required: true,
            helpMessage: "Path to the snapshot folder")
       
        let destinationPath = StringOption(shortFlag: "d", longFlag: "destination", required: true,
            helpMessage: "Path to the destination folder")
        
        let secretKey = StringOption(shortFlag: "k", longFlag: "secret-key",
            helpMessage: "The secret key")
        
        let help = BoolOption(shortFlag: "h", longFlag: "help",
            helpMessage: "Prints a help message.")
        
        let verbosity = BoolOption(shortFlag: "v", longFlag: "verbose",
            helpMessage: "Print verbose messages.\n\n")
        
        cli.addOptions( sourcePath,
                        destinationPath,
                        secretKey,
                        help,
                        verbosity )
        
        do {
            try cli.parse()
            self.isVerbose=verbosity.value
            guard let source=sourcePath.value else{
                print("Nil source path")
                exit(EX__BASE)
            }
            guard  let destination=destinationPath.value else{
                print("Nil destination path")
                exit(EX__BASE)
            }
            let secretKey=secretKey.value
            let shooter=BsyncSnapShooter()
            do {
                try shooter.recoverSnapshotForPath(source, destination: destination, secretKey: secretKey, progressBlock: { (taskIndex, progress, filePath, chunkPath, message) -> Void in
                    if progress>=100{
                       self.printVerbose("End of snapshot recovery")
                        exit(EX_OK)
                    }else{
                       self.printVerbose("#\(taskIndex) progress \(progress)% creating \(chunkPath)")
                       self.printVerbose("\(message)")
                    }
                })
            }catch BsyncSnapShooterError.InvalidPath(let explanations){
                print(explanations)
                exit(EX__BASE)
            }catch{
                print("Unexpected error \(error)")
                exit(EX__BASE)
            }
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }
}