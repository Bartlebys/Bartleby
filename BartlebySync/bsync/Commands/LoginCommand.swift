//
//  LoginCommand.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 08/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Cocoa

class LoginCommand: CommandBase {
    
    
    required init(completionHandler: CompletionHandler?)  {
        super.init(completionHandler: completionHandler)
        
        let api = StringOption(shortFlag: "a", longFlag: "api", required: true,
                               helpMessage: "API url e.g http://yd.local/api/v1")
        let userUID = StringOption(shortFlag: "u", longFlag: "user", required: true,
                                   helpMessage: "A user UID for the authentication.")
        let password = StringOption(shortFlag: "p", longFlag: "password", required: true,
                                    helpMessage: "A password is  required for authentication.")
        let secretKey = StringOption(shortFlag: "y", longFlag: "secretKey", required: true,
                                     helpMessage: "The secret key to encryp the data (if not set we use bsync's default)")
        let sharedSalt = StringOption(shortFlag: "t", longFlag: "salt", required: true,
                                      helpMessage: "The salt used for authentication.")
        
        
        addOptions(api, userUID, password, secretKey, sharedSalt)
        
        if parse() {
            if let api = api.value, let userUID = userUID.value, let password = password.value,
                let secretKey = secretKey.value, let sharedSalt = sharedSalt.value {

                if let apiUrl = NSURL(string: api) {
                    // We prefer to configure completly Bartleby
                    // When using it's api.
                    // For future extensions
                    Bartleby.configuration.API_BASE_URL=apiUrl
                    Bartleby.configuration.KEY=secretKey
                    Bartleby.configuration.SHARED_SALT=sharedSalt
                    Bartleby.configuration.API_CALL_TRACKING_IS_ENABLED=false
                    Bartleby.sharedInstance.configureWith(Bartleby.configuration)


                    let applicationSupportURL = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
                    let kvsUrl = applicationSupportURL[0].URLByAppendingPathComponent("bsync/kvs.json")
                    let kvs = BsyncKeyValueStorage(url: kvsUrl)
                    
                    do {
                        try kvs.open()
                        if let user = kvs[userUID] as? User {
                            let document=self.virtualDocumentFor(user.spaceUID,rootObjectUID:user.registryUID)
                            LoginUser.execute(user, withPassword: password, sucessHandler: {
                                kvs.setStringValue(document.registryMetadata.identificationValue, forKey: "kvid.\(user.UID)")
                                print ("Successful login")
                                exit(EX_OK)
                                }, failureHandler: { (context) in
                                    // Print a JSON failure description
                                    print ("An error has occured: \(context.description)")
                                    exit(EX_USAGE)
                            })
                        } else {
                            print("No user with id: \(userUID)")
                            exit(EX__BASE)
                        }
                    } catch {
                        self.on(Completion.failureStateFromError(error))
                    }
                } else {
                    print("Invalid API URL \(api)")
                    exit(EX__BASE)
                }
            }
        }
    }
}
