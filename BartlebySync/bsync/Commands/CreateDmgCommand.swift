//
//  CreateDmgCommand.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 06/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license


import Cocoa

class CreateDmgCommand: CommandBase {


    required init(completionHandler: CompletionHandler?) {
        super.init(completionHandler: completionHandler)

        let path = StringOption(shortFlag: "f", longFlag: "folder", required: true,
            helpMessage: "Path to the folder in wich we will save the image disk.")
        let volumeName = StringOption(shortFlag: "n", longFlag: "name", required: true,
            helpMessage: "Name of the volume")
        let size = StringOption(shortFlag: "s", longFlag: "size", required: true,
            helpMessage: "Size of the volume: 10g 100m ")
        let help = BoolOption(shortFlag: "h", longFlag: "help",
            helpMessage: "Prints a help message.")
        let password = StringOption(shortFlag: "p", longFlag: "password",
            helpMessage: "Set a password if you want to create a crypted disk image")
        cli.addOptions(path, help, volumeName, size, password)
        do {
            try cli.parse()
            let dmgManager=BsyncImageDiskManager()
            
            if let path = path.value, let name = volumeName.value, let size = size.value {
                self.appendCompletionHandler({ (createDisk) in
                    if createDisk.success {
                        print("The disk image has been created")
                    }
                })
                dmgManager.createImageDisk(path + name, volumeName:name, size:size, password:password.value, handlers: self)
            } else {
                self.on(Completion.failureState("Error unwrapping option", statusCode: .Undefined))
            }


        } catch {
            self.on(Completion.failureState("\(error)", statusCode: .Bad_Request))
        }
    }



}
