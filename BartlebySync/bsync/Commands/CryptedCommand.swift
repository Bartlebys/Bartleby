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
        
        secretKey = env["BARTLEBY_SECRET_KEY"] ?? ""
        
        sharedSalt = env["BARTLEBY_SHARED_SALT"] ?? ""
        
        // secret key is required only if no environment variable is defined and valid
        _secretKeyOption = StringOption(shortFlag: "i", longFlag: "secretKey", required: !Bartleby.isValidKey(secretKey),
                                        helpMessage: "The secret key to encryp the data")
        
        _sharedSaltOption = StringOption(shortFlag: "t", longFlag: "salt", required: sharedSalt.isEmpty,
                                         helpMessage: "The salt used for authentication.")

        super.init(completionHandler: completionHandler)
        
        addOptions(_secretKeyOption, _sharedSaltOption)
    }
    
    override func parse() -> Bool {
        if super.parse() {
            if let key = _secretKeyOption.value {
                secretKey = key
            }
            
            if let salt = _sharedSaltOption.value {
                sharedSalt = salt
            }
            
            if !Bartleby.isValidKey(secretKey) {
                self.on(Completion.failureState("Bad encryption key: \(secretKey)", statusCode: .Bad_Request))
                return false
            }
            
            if sharedSalt.isEmpty {
                self.on(Completion.failureState("Bad shared salt: \(sharedSalt)", statusCode: .Bad_Request))
                return false
            }

            return true
        }
        return false
    }
}
