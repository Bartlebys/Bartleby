//
//  VerifyCredentialsCommand.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 08/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Cocoa

class VerifyCredentialsCommand: CommandBase {
    
    required init(completionHandler: CompletionHandler?)  {
        super.init(completionHandler: completionHandler)
        
        let sourceURLString = StringOption(shortFlag: "u", longFlag: "url", required: true,
                                           helpMessage: "BartlebySync base url e.g http://yd.local/api/v1/BartlebySync")
        let registryUID = StringOption(shortFlag: "r", longFlag: "registryUID", required: true,
                                    helpMessage: "A registryUID is required authentication")
        let sharedSalt = StringOption(shortFlag: "t", longFlag: "salt", required: true,
                                      helpMessage: "The salt used for authentication.\n\t If salt is set; email, password and spaceUID, must be set too!\n\n")
        addOptions(options: sourceURLString, registryUID, sharedSalt)
        
        if parse() {
            var baseApiURL: URL?=nil
            
            guard let source=sourceURLString.value else {
                print("Nil source URL")
                exit(EX__BASE)
            }
            guard let _=URL(string: source) else {
                print("Invalid source URL \(source)")
                exit(EX__BASE)
            }
            
            
            // If there is an url let's determine the API base url.
            // it should be before baseAPI_URL/BartlebySync/tree/...
            // eg.: http://yd.local/api/v1/BartlebySync
            
            
            let r=source.range(of:"/BartlebySync")
            if let foundIndex=r?.lowerBound {
                // extract the base URL
                baseApiURL=URL(string: source.substring(to:foundIndex))
            }
            
            if baseApiURL != nil {
                
                HTTPManager.verifyCredentials(registryUID.value!, baseURL:baseApiURL!, successHandler: { () -> () in
                    print ("Your credentials are valid for spaceUID \"\(registryUID.value!)\" @\(baseApiURL!.absoluteString)")
                    exit(EX_OK)
                    
                    }, failureHandler: { (context) -> () in
                        
                        // Print a JSON failure description
                        print ("An error has occured:\(context.description)")
                        exit(EX_USAGE)
                })
                
            } else {
                print ("An unexpected error has occured")
                exit(EX_USAGE)
            }
        }
    }
}
