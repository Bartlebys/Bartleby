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
        
        
        let hashMapPathOption = StringOption(shortFlag: "f", longFlag: "file", required: false,
                                             helpMessage: "Path to the hashmap file.")
        let hashMapURLOption = StringOption(shortFlag: "u", longFlag: "url", required: false, helpMessage: "URL to the hashmap")
        
        addOptions(options: hashMapPathOption, hashMapURLOption)
        if parse() {
            // Configure Bartleby without a specific URL
            Bartleby.configuration.KEY = secretKey
            Bartleby.configuration.SHARED_SALT = sharedSalt
            Bartleby.configuration.ENABLE_BPRINT = false
            Bartleby.configuration.PRINT_BPRINT_ENTRIES = true
            Bartleby.sharedInstance.configureWith(Bartleby.configuration)
            
            func printHashMap(cryptedHashMap: String) {
                do {
                    let hashmap = try Bartleby.cryptoDelegate.decryptString(cryptedHashMap)
                    print(hashmap)
                    self.on(Completion.successState())
                } catch {
                    self.on(Completion.failureStateFromError(error))
                }
            }
            
            do {
                if let path = hashMapPathOption.value {
                    let cryptedHashMap = try String(contentsOfFile: path)
                    printHashMap(cryptedHashMap: cryptedHashMap)
                } else if let urlString = hashMapURLOption.value {
                    let r = request(urlString, method:HTTPMethod.get )
                    r.responseString(completionHandler: { (response) in
                        if let cryptedHashMap = response.result.value {
                            printHashMap(cryptedHashMap: cryptedHashMap)
                        } else {
                            self.on(Completion.failureState("Error when retrieving the file", statusCode: .undefined))
                        }
                    })
                } else {
                    self.on(Completion.failureState("You must specify a file path or a valid URL to the hashmap", statusCode: .undefined))
                }
            } catch {
                self.on(Completion.failureStateFromError(error))
            }
            
        }
    }
}
