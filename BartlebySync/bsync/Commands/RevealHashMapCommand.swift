//
//  RevealHashMapCommand.swift
//  bsync
//
//  Created by Martin Delille on 25/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

class RevealHashMapCommand: CommandBase {
    required init(completionBlock: ((completion: Completion) -> ())) {
        super.init(completionBlock: completionBlock)
       
        var secretKey: String = ""

        let env = NSProcessInfo.processInfo().environment
        if let key = env["BARTLEBY_SECRET_KEY"] {
            secretKey = key
        }
        
        let hashMapPathOption = StringOption(shortFlag: "f", longFlag: "file", required: true,
                                       helpMessage: "Path to the hashmap file.")
        
        // secret key is required only if no environment variable is defined and valid
        let secretKeyOption = StringOption(shortFlag: "i", longFlag: "secretKey",required: !Bartleby.isValidKey(secretKey),
                                     helpMessage: "The secret key to encryp the data")
        
        cli.addOptions(hashMapPathOption,secretKeyOption)
        do {
            try cli.parse()
            
            if let key = secretKeyOption.value {
                if Bartleby.isValidKey(key) {
                    secretKey = key
                } else {
                    self.completionBlock(Completion(success: false, message: "Bad encryption key: \(key)"))
                    return
                }
                
            }
            
            if let path = hashMapPathOption.value {
                
                // Configure Bartleby without a specific URL
                Bartleby.configuration.KEY = secretKey
                Bartleby.sharedInstance.configureWith(Bartleby.configuration)
                
                let fm = BFileManager()
                
                fm.fileExistsAtPath(path, callBack: { (exists, isADirectory, success, message) in
                    if success && exists {
                        // Load the hashmap
                        fm.readString(contentsOfFile: path, encoding: NSUTF8StringEncoding, callBack: { (string, success, message) in
                            if success {
                                if let encryptedHashMapString = string {
                                    do {
                                        let decryptedHashMapString = try Bartleby.cryptoDelegate.decryptString(encryptedHashMapString)
                                        print("# Hash map \(path) #\n\(decryptedHashMapString)\n# End of hash map #")
                                        self.completionBlock(Completion(success: true))
                                    } catch {
                                        self.completionBlock(Completion(success: false, message: "Error decrypting \"\(encryptedHashMapString)"))
                                    }
                                } else {
                                    self.completionBlock(Completion(success: false, message: "Bad file"))
                                }
                            }else {
                                self.completionBlock(Completion(success: false, message: "Unable to read: \(path)"))
                            }
                        })
                        
                    } else {
                        self.completionBlock(Completion(success: false, message: "Unexisting path: \(path)"))
                    }
                })
            }
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }
}