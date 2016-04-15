//
//  LoginCommand.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 08/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Cocoa

class LoginCommand: CommandBase {
    
    
    override init() {
        super.init()
        let sourceURLString = StringOption(shortFlag: "u", longFlag: "url", required: true,
                                           helpMessage: "BartlebySync base url e.g http://yd.local/api/v1/BartlebySync")
        let email = StringOption(shortFlag: "e", longFlag: "email",
                                 helpMessage: "An email or phone number are required for the authentication.")
        let phoneNumber = StringOption(shortFlag: "n", longFlag: "phone",
                                       helpMessage: "An email or phone number are required for the authentication.")
        let password = StringOption(shortFlag: "p", longFlag: "password",required: true,
                                    helpMessage: "A password is  required for authentication.")
        let spaceUID = StringOption(shortFlag: "i", longFlag: "spaceUID",required: true,
                                      helpMessage: "A spaceUID may be required for authentication.")
        let sharedSalt = StringOption(shortFlag: "t", longFlag: "salt",required: true,
                                      helpMessage: "The salt used for authentication.")
        
        
        cli.addOptions(sourceURLString,email,phoneNumber,password,spaceUID,sharedSalt)
        
        do {
            try cli.parse()
            
            if (!email.wasSet && !phoneNumber.wasSet) {
                print("")
                print("You must set an email or a phone number")
                exit(EX__BASE)
            }
            
            
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
                if (email.wasSet || phoneNumber.wasSet) && password.wasSet && spaceUID.wasSet && sharedSalt.wasSet {
                    
                    // We prefer to configure completly Bartleby
                    // When using it's api.
                    // For future extensions
                    Bartleby.configuration.API_BASE_URL=baseApiURL!
                    Bartleby.configuration.KEY=Bartleby.randomStringWithLength(32)
                    Bartleby.configuration.SHARED_SALT=sharedSalt.value!
                    Bartleby.configuration.API_CALL_TRACKING_IS_ENABLED=false
                    Bartleby.sharedInstance.configureWith(Bartleby.configuration)
                    
                    let user=User()
                    user.spaceUID=spaceUID.value!
                    if let email=email.value{
                        user.email=email
                    }
                    
                    
                    if let phoneNumber=phoneNumber.value{
                        user.phoneNumber=phoneNumber
                        user.verificationMethod=User.VerificationMethod.ByPhoneNumber
                    }
                   
                    LoginUser.execute(user, withPassword: password.value!, sucessHandler: {
                        print ("Successful login")
                        exit(EX_OK)
                        }, failureHandler: { (context) in
                            // Print a JSON failure description
                            print ("An error has occured: \(context.description)")
                            exit(EX_USAGE)
                    })
                }else{
                    
                }
            }else{
                print("Invalid source URL \(source)")
                exit(EX__BASE)
            }
            
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }
    
}
