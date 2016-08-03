//
//  CryptedCommand.swift
//  bsync
//
//  Created by Martin Delille on 06/06/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

public class CryptedCommand: CommandBase {

    var secretKey: String = ""
    var sharedSalt: String = ""
    
    private let _secretKeyOption, _sharedSaltOption: StringOption

    public required init(completionHandler: CompletionHandler?) {
        let env = NSProcessInfo.processInfo().environment
        
        self.secretKey = env["BARTLEBY_SECRET_KEY"] ?? ""
        
        self.sharedSalt = env["BARTLEBY_SHARED_SALT"] ?? ""
        
        // secret key is required only if no environment variable is defined and valid
        self._secretKeyOption = StringOption(shortFlag: "i", longFlag: "secretKey", required: !Bartleby.isValidKey(secretKey),
                                        helpMessage: "The secret key to encryp the data")
        
        self._sharedSaltOption = StringOption(shortFlag: "t", longFlag: "salt", required: sharedSalt.isEmpty,
                                         helpMessage: "The salt used for authentication.")

        super.init(completionHandler: completionHandler)
        
        addOptions(self._secretKeyOption,self._sharedSaltOption)
    }
    
    override func parse() -> Bool {
        if super.parse() {
            if let key = self._secretKeyOption.value {
                self.secretKey = key
            }
            
            if let salt = self._sharedSaltOption.value {
                self.sharedSalt = salt
            }
            
            if !Bartleby.isValidKey(self.secretKey) {
                self.on(Completion.failureState("Bad encryption key: \(self.secretKey)", statusCode: .Bad_Request))
                return false
            }
            
            if self.sharedSalt.isEmpty {
                self.on(Completion.failureState("Bad shared salt: \(self.sharedSalt)", statusCode: .Bad_Request))
                return false
            }

            return true
        }
        return false
    }
}
