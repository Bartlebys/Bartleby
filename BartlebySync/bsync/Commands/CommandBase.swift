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

    public required init(completionHandler:((completion: Completion)->())) {
        super.init(completionHandler: completionHandler)
    }

//    public convenience init() {
//        self.init(completionHandler:{ (completion) in
//            if completion.success {
//                exit(EX_OK)
//            } else {
//                print(completion.message)
//                exit(Int32(completion.statusCode))
//            }
//        })
//    }

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
