//
//  CreateUser.swift
//  bsync
//
//  Created by Martin Delille on 06/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

class CreateUserCommand : CommandBase {
    
    
    override init() {
        super.init()
        
        let baseURLString = StringOption(shortFlag: "u", longFlag: "url", required: true,
                                         helpMessage: "BartlebySync base url e.g http://yd.local/api/v1/BartlebySync")
        
        let password = StringOption(shortFlag: "p", longFlag: "password",required: true,
                                    helpMessage: "A password is  required for authentication.")
        
        let spaceUID = StringOption(shortFlag: "i", longFlag: "spaceUID",required: true,
                                    helpMessage: "A spaceUID")
        
        let sharedSalt = StringOption(shortFlag: "t", longFlag: "salt",required: true,
                                      helpMessage: "The salt used for authentication.")
        
        let verbosity = BoolOption(shortFlag: "v", longFlag: "verbose",required: false,
                                   helpMessage: "Print verbose messages.")
        
        cli.addOptions(baseURLString, password, spaceUID, sharedSalt, verbosity)
        
        do {
            try cli.parse()
            
            
            if let base = baseURLString.value, pw = password.value, let space = spaceUID.value, let salt = sharedSalt.value {
                
                if let url = NSURL(string: base) {
                    
                    Bartleby.configuration.API_BASE_URL=url
                    Bartleby.configuration.KEY=Bartleby.randomStringWithLength(32)
                    Bartleby.configuration.SHARED_SALT=salt
                    Bartleby.configuration.API_CALL_TRACKING_IS_ENABLED=false
                    Bartleby.configuration.ENABLE_BPRINT=verbosity.value
                    Bartleby.sharedInstance.configureWith(Bartleby.configuration)
                    
                    let user=User()
                    user.spaceUID = space
                    user.creatorUID = user.UID
                    user.password = pw
                    
                    
                    CreateUser.execute(user, inDataSpace: space,
                                       sucessHandler: { (context) in
                                        print (user.UID)
                                        exit(EX_OK)
                        }, failureHandler: { (context) in
                            // Print a JSON failure description
                            print ("An error has occured: \(context.description)")
                            exit(EX_USAGE)
                    })
                }else{
                    print("Invalid source URL \(base)")
                    exit(EX__BASE)
                }
            }
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }
}

