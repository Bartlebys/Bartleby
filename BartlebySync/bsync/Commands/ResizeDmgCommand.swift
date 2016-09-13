//
//  ResizeDmgCommand.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 01/09/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Cocoa

class ResizeDmgCommand: CommandBase {


        required init(completionHandler: CompletionHandler?) {
            super.init(completionHandler: completionHandler)

            let path = StringOption(shortFlag: "i", longFlag: "imagepath", required: true,
                                    helpMessage: "The image disk file path.")

            let size = StringOption(shortFlag: "s", longFlag: "size", required: true,
                                    helpMessage: "Size of the volume: ??b|??k|??m|??g|??t|??p|??e")

            let password = StringOption(shortFlag: "p", longFlag: "password",
                                        helpMessage: "Set a password if you want to create a crypted disk image")

            let help = BoolOption(shortFlag: "h", longFlag: "help",
                                  helpMessage: "Prints a help message.")

            addOptions(options: path, help, size, password)
            if parse() {

                if let path = path.value, let size = size.value {
                    let dmgManager=BsyncImageDiskManager()
                    self.appendCompletionHandler({ (resizeImg) in
                        if resizeImg.success {
                            print("The disk image has been resized")
                        }
                    })
                    dmgManager.resizeDMG(size, imageFilePath: path, password: password.value, completionHandler: completionHandler!)
                } else {
                    self.on(Completion.failureState("Error unwrapping option", statusCode: .undefined))
                }
            }
        }


}
