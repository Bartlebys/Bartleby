//
//  CreateUser.swift
//  bsync
//
//  Created by Martin Delille on 06/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

class CreateUserCommand : CommandBase {
    
    
    required init(completionBlock: ((success: Bool, message: String?) -> ())) {
        super.init(completionBlock: completionBlock)
        
        let api = StringOption(shortFlag: "a", longFlag: "api", required: true,
                                         helpMessage: "Bartleby base url e.g http://yd.local/api/v1")
        
        let password = StringOption(shortFlag: "p", longFlag: "password",required: true,
                                    helpMessage: "A password is  required for authentication.")
        
        let spaceUID = StringOption(shortFlag: "i", longFlag: "spaceUID",required: true,
                                    helpMessage: "A spaceUID")
        
        let secretKey = StringOption(shortFlag: "y", longFlag: "secretKey",required: true,
                                     helpMessage: "The secret key to encryp the data (if not set we use bsync's default)")
        
        let sharedSalt = StringOption(shortFlag: "t", longFlag: "salt",required: true,
                                      helpMessage: "The salt used for authentication.")
        
        // Optional parameters
        let email = StringOption(shortFlag: "e", longFlag: "email", required: false,
                                 helpMessage: "The email can be used to set the verification method")
        
        let phone = StringOption(shortFlag: "n", longFlag: "phone", required: false,
                                 helpMessage: "The phone number can be used to set the verification method")
        
        let verbosity = BoolOption(shortFlag: "v", longFlag: "verbose",required: false,
                                   helpMessage: "Print verbose messages.")
        
        
        
        // TODO: Add email and/or phone to implement verification
        cli.addOptions(api, password, spaceUID, secretKey, sharedSalt, email, phone, verbosity)
        
        do {
            try cli.parse()
            
            
            if let base = api.value, pw = password.value, let space = spaceUID.value, let key = secretKey.value, let salt = sharedSalt.value {
                
                if let url = NSURL(string: base) {
                    
                    Bartleby.configuration.API_BASE_URL=url
                    Bartleby.configuration.KEY=key
                    Bartleby.configuration.SHARED_SALT=salt
                    Bartleby.configuration.API_CALL_TRACKING_IS_ENABLED=false
                    Bartleby.configuration.ENABLE_BPRINT=verbosity.value
                    Bartleby.sharedInstance.configureWith(Bartleby.configuration)
                    
                    let user=User()
                    user.spaceUID = space
                    user.creatorUID = user.UID
                    user.password = pw
                    user.verificationMethod = .None
                    if let email = email.value {
                        user.email = email
                        user.verificationMethod = .ByEmail
                    }
                    if let phone = phone.value {
                        user.phoneNumber = phone
                        user.verificationMethod = .ByPhoneNumber
                    }
                    
                    CreateUser.execute(user, inDataSpace: space,
                                       sucessHandler: { (context) in
                                        print (user.UID)
                                        
                                        // Storing user in the KVS:
                                        let applicationSupportURL = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
                                        let kvsUrl = applicationSupportURL[0].URLByAppendingPathComponent("bsync/kvs.json")
                                        let kvs = BsyncKeyValueStorage(url: kvsUrl)
                                        do {
                                            try kvs.open()
                                            kvs[user.UID] = user
                                            try kvs.save()
                                        } catch {
                                            print("Error storing the user:\(error)")
                                        }
                                        
                                        exit(EX_OK)
                        }, failureHandler: { (context) in
                            // Print a JSON failure description
                            print ("An error has occured: \(context.description)")
                            exit(EX_USAGE)
                    })
                }else{
                    print("Invalid API URL \(base)")
                    exit(EX__BASE)
                }
            }
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }
}

