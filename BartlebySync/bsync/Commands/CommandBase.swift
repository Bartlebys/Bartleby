//
//  CommandBase.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 06/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Foundation


/// Base command implementing common behavior for all bsync commands
public class CommandBase: Handlers {


    public var isVerbose=true

    private let _cli = CommandLine()

    public required init(completionHandler: CompletionHandler?) {
        super.init(completionHandler: completionHandler)
    }
    
    func addOptions(options: Option...) {
        for o in options {
            _cli.addOption(o)
        }
    }
    
    func parse() -> Bool {
        do {
            try _cli.parse()
            return true
        } catch {
            _cli.printUsage()
            exit(EX_USAGE)
        }
    }

    func printVerbose(string: String) {
        if isVerbose {
            self.printVersatile(string: string)
        }
    }

    /**
     Versatile print method.

     - parameter string: the message
     */
    func printVersatile(string: String) {
        print(string)
    }


    /**
     Creates a virtual Document to be able to use Bartleby's stack in CommandLines sequential commands.

     - parameter spaceUID: the spaceUID

     - returns: a document
     */
    func virtualDocumentFor(spaceUID:String,rootObjectUID:String?)->BartlebyDocument{
        let document=BartlebyDocument()
        document.registryMetadata.spaceUID=spaceUID
        do{
            if let rootObjectUID=rootObjectUID{
                try document.setRootObjectUID(rootObjectUID)
            }else{
                try document.setRootObjectUID(Bartleby.createUID())
            }
        }catch{

        }
        Bartleby.sharedInstance.declare(document)
        return document
    }
}
