//
//  CommandBase.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 06/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Foundation


public class CommandBase: Handlers {


    public var isVerbose=true

    let cli = CommandLine()

    public required init(completionHandler: CompletionHandler?) {
        super.init(completionHandler: completionHandler)
    }


    func printVerbose(string: String) {
        if isVerbose {
            self.printVersatile(string)
        }
    }

    /**
     Versatile print method.

     - parameter string: the message
     */
    func printVersatile(string: String) {
        print(string)
    }
}
