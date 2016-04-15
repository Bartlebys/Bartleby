//
//  VerifyCredentialsCommand.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 08/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Cocoa

class VerifyCredentialsCommand: CommandBase {
    
    override init() {
        
        super.init()
        let sourceURLString = StringOption(shortFlag: "u", longFlag: "url", required: true,
            helpMessage: "BartlebySync base url e.g http://yd.local/api/v1/BartlebySync")
        let spaceUID = StringOption(shortFlag: "i", longFlag: "spaceUID",required: true,
            helpMessage: "A spaceUID is required authentication")
        let sharedSalt = StringOption(shortFlag: "t", longFlag: "salt",required: true,
            helpMessage: "The salt used for authentication.\n\t If salt is set; email, password and spaceUID, must be set too!\n\n")
        cli.addOptions(sourceURLString,spaceUID,sharedSalt)
        
        do {
            try cli.parse()
            
            var baseApiURL:NSURL?=nil
            
            guard let source=sourceURLString.value else{
                print("Nil source URL")
                exit(EX__BASE)
            }
            guard let _=NSURL(string: source) else{
                print("Invalid source URL \(source)")
                exit(EX__BASE)
            }
            
            
            // If there is an url let's determine the API base url.
            // it should be before baseAPI_URL/BartlebySync/tree/...
            // eg.: http://yd.local/api/v1/BartlebySync
            
            
            let r=source.rangeOfString("/BartlebySync")
            if let foundIndex=r?.startIndex{
                // extract the base URL
                baseApiURL=NSURL(string: source.substringToIndex(foundIndex))
            }
            
            if baseApiURL != nil {
    
                HTTPManager.verifyCredentials(spaceUID.value!, baseURL:baseApiURL!, successHandler: { () -> () in
                    print ("Your credentials are valid for spaceUID \"\(spaceUID.value!)\" @\(baseApiURL!.absoluteString)")
                    exit(EX_OK)
                    
                    }, failureHandler: { (context) -> () in
                        
                        // Print a JSON failure description
                        print ("An error has occured:\(context.description)")
                        exit(EX_USAGE)
                })

                
            }else{
                print ("An unexpected error has occured")
                exit(EX_USAGE)
            }
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }
    
    

}