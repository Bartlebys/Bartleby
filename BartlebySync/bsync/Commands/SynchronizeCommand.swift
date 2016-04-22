//
//  SynchronizeCommand.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 06/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Foundation

class SynchronizeCommand:CommandBase{
    
    required init(completionBlock: ((success: Bool, message: String?) -> ())) {
        super.init(completionBlock: completionBlock)
    }
    
    func executeCMD() {

        // Base options 
        
        let sourceURLString = StringOption(shortFlag: "s", longFlag: "source", required: true,
            helpMessage: "URL of the source folder")
        
        let destinationURLString = StringOption(shortFlag: "d", longFlag: "destination", required: true,
            helpMessage: "URL of the destination folder")
        
        let hashMapViewName = StringOption(shortFlag: "m", longFlag: "hashMapViewName",required: false,
            helpMessage: "The name of the optionnal hashMapView")
        
        let automaticTreesCreation = BoolOption(shortFlag: "a", longFlag: "automatic-trees-creation",required: false,
            helpMessage: "Creates automatically distant trees")
        
        // Help and verbosity
        
        let help = BoolOption(shortFlag: "h", longFlag: "help",required: false,
            helpMessage: "Prints a help message.")
        
        let verbosity = BoolOption(shortFlag: "v", longFlag: "verbose",required: false,
            helpMessage: "Print verbose messages.")
        
        // Barleby Authentication group of arguments
        // You can login and synchronize in one call.
        
        let userUID = StringOption(shortFlag: "u", longFlag: "user",
                                   helpMessage: "A user UID may be required for authentification")
        let password = StringOption(shortFlag: "p", longFlag: "password",required: false,
            helpMessage: "An password may be required for authentication")
        let sharedSalt = StringOption(shortFlag: "t", longFlag: "salt",required: false,
            helpMessage: "The salt used for authentication.")
        
        
        cli.addOptions( sourceURLString,
                        destinationURLString,
                        hashMapViewName,
                        automaticTreesCreation,
                        help,
                        verbosity,
                        userUID,
                        password,
                        sharedSalt )
        
        do {
            try cli.parse()
            
            self.isVerbose=verbosity.value
            
            var user: User?
            
            if userUID.wasSet || password.wasSet || sharedSalt.wasSet {
                if !userUID.wasSet || !password.wasSet || !sharedSalt.wasSet{
                    print("")
                    print("When you setup a user identifier, you must setup a, password, and a salt.")
                    print("Before to proceeding to synchronization \"bsync\" will proceed to authentication")
                    print("")
                    print("\tuser was set = \(userUID.wasSet)")
                    print("\tpassword was set = \(password.wasSet)")
                    print("\tsharedSalt was set = \(sharedSalt.wasSet)")
                    print("")
                    exit(EX__BASE)
                }
                
                if let userUID = userUID.value {
                    let applicationSupportURL = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
                    let kvsUrl = applicationSupportURL[0].URLByAppendingPathComponent("bsync/kvs.json")
                    let kvs = BsyncKeyValueStorage(url: kvsUrl)

                    try kvs.open()
                    user = kvs[userUID] as? User
                }
            }
            
            guard let source=sourceURLString.value else{
                print("Nil source URL")
                exit(EX__BASE)
            }
            guard let sourceURL=NSURL(string: source) else{
                print("Invalid source URL \(source)")
                exit(EX__BASE)
            }
            guard  let destination=destinationURLString.value else{
                print("Nil destination URL")
                exit(EX__BASE)
            }
            
            guard let destinationURL=NSURL(string: destination) else{
                print("Invalid destination URL \(destination)")
                exit(EX__BASE)
            }
            
            let runner = BsyncDirectivesRunner()
            runner.synchronize( sourceURL,
                                            destinationURL: destinationURL,
                                            hashMapViewName: hashMapViewName.value,
                                            user: user,
                                            password: password.value,
                                            sharedSalt: sharedSalt.value,
                                            autoCreateTrees:automaticTreesCreation.wasSet,
                                            handlers: self)
            
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }
}