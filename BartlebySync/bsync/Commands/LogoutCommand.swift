//
//  LogoutCommand.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 08/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Cocoa

class LogoutCommand: CommandBase {
    
    required init(completionHandler: CompletionHandler?) {
        super.init(completionHandler: completionHandler)
        
        let sourceURLString = StringOption(shortFlag: "u", longFlag: "url", required: true,
                                           helpMessage: "BartlebySync base url e.g http://yd.local/api/v1/BartlebySync")

        let spaceUID = StringOption(shortFlag: "i", longFlag: "spaceUID", required: true,
                                    helpMessage: "A spaceUID is required for authentication")

        let userUID = StringOption(shortFlag: "u", longFlag: "userUID", required: true,
                                    helpMessage: "A userUID is required")
        let sharedSalt = StringOption(shortFlag: "t", longFlag: "salt", required: true,
                                      helpMessage: "The salt used for authentication.")

        addOptions(options: sourceURLString,spaceUID,userUID, sharedSalt)
        
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

            guard let userUID=userUID.value else {
                print("userUID undefined")
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
                
                // We prefer to configure completly Bartleby
                // When using it's api.
                // For future extensions.
                Bartleby.configuration.API_BASE_URL = baseApiURL!
                Bartleby.sharedInstance.configureWith(Bartleby.configuration)

              let document=self.virtualDocumentFor(spaceUID: spaceUID.value!,rootObjectUID: nil)
                
                let applicationSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                let kvsUrl = applicationSupportURL[0].appendingPathComponent("bsync/kvs.json")
                let kvs = BsyncKeyValueStorage(url: kvsUrl)
                do {
                    try kvs.open()
                    if let user = kvs[userUID] as? User {
                        document.registryMetadata.currentUser=user
                        LogoutUser.execute(user, sucessHandler: { () -> () in
                            kvs.delete("kvid.\(user.UID)")
                            print ("Successful logout")
                            exit(EX_OK)
                            }, failureHandler: { (context) -> () in
                                // Print a JSON failure description
                                print ("An error has occured:\(context.description)")
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
                print ("An unexpected error has occured")
                exit(EX_USAGE)
            }
        }
    }
}
