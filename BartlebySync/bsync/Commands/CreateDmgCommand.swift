//
//  CreateDmgCommand.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 06/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license


import Cocoa

class CreateDmgCommand: CommandBase {

    
    override init() {
        super.init()
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
        cli.addOptions(path, help,volumeName,size,password)
        do {
            try cli.parse()
                let dmgManager=BsyncImageDiskManager()
            do{
                if try dmgManager.createImageDisk(path.value!+volumeName.value!,volumeName:volumeName.value!,size:size.value!,password:password.value){
                    print("The disk image has been created")
                    exit(EX_OK)
                }else{
                    exit(EX__BASE)
                }
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
