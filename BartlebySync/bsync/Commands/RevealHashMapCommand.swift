//
//  RevealHashMapCommand.swift
//  bsync
//
//  Created by Martin Delille on 25/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

class RevealHashMapCommand: CryptedCommand {
    required init(completionHandler: CompletionHandler?)  {
        super.init(completionHandler: completionHandler)
        
        
        let hashMapPathOption = StringOption(shortFlag: "f", longFlag: "file", required: true,
                                             helpMessage: "Path to the hashmap file.")
        
        addOptions(hashMapPathOption)
        if parse() {
            if let path = hashMapPathOption.value {
                // Configure Bartleby without a specific URL
                Bartleby.configuration.KEY = secretKey
                Bartleby.configuration.SHARED_SALT = sharedSalt
                Bartleby.configuration.ENABLE_BPRINT = false
                Bartleby.sharedInstance.configureWith(Bartleby.configuration)
                
                do {
                    let cryptedHashMap = try String(contentsOfFile: path)
                    let hashmap = try Bartleby.cryptoDelegate.decryptString(cryptedHashMap)
                    print(hashmap)
                    self.on(Completion.successState())
                } catch {
                    self.on(Completion.failureStateFromError(error))
                }
            }
        }
    }
}
