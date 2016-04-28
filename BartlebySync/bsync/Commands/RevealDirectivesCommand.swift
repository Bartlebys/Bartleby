//
//  RevealDirectivesCommand.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 14/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Cocoa

class RevealDirectivesCommand: CommandBase {
    
    required init(completionHandler: ((completion: Completion) -> ())) {
        super.init(completionHandler: completionHandler)
                
        let filePath = StringOption(shortFlag: "f", longFlag: "file", required: true,
            helpMessage: "Path to the directive file.")
        
        let secretKey = StringOption(shortFlag: "i", longFlag: "secretKey",required: true,
            helpMessage: "The secret key to encryp the data (if not set we use bsync's default)")
        
        let sharedSalt = StringOption(shortFlag: "t", longFlag: "salt",required: true,
            helpMessage: "The salt (if not set we use bsync's default)")
        
        let help = BoolOption(shortFlag: "h", longFlag: "help",
            helpMessage: "Prints a help message.")
        
        let verbosity = BoolOption(shortFlag: "v", longFlag: "verbose",
            helpMessage: "Print verbose messages.\n\n")
        
        cli.addOptions(filePath,secretKey, sharedSalt, help, verbosity)
        do {
            try cli.parse()
            self.isVerbose=verbosity.value
            let key = secretKey.value!
            let salt = sharedSalt.value!

            
            RevealDirectivesCommand.revealDirectives(filePath.value!, secretKey: key, sharedSalt: salt, verbose: verbosity.value)
            
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }
    
    /**
     Reveals the directives
     
     - parameter filePath:      the directives filePath
     - parameter secretKey:     the secret key to decrypt the directives
     - parameter sharedSalt:    the sharedSalt
     - parameter verbose:       verbose or not
     */
    static func revealDirectives(filePath:String,secretKey:String,sharedSalt:String,verbose:Bool=true){
        
        
        // Configure Bartleby without a specific URL
        Bartleby.configuration.KEY=secretKey
        Bartleby.configuration.SHARED_SALT=sharedSalt
        Bartleby.configuration.API_CALL_TRACKING_IS_ENABLED=false
        Bartleby.sharedInstance.configureWith(Bartleby.configuration)
    
        
        let fp:String=filePath
        guard NSFileManager.defaultManager().fileExistsAtPath(fp)==true else{
            print("Unexisting path \(fp)")
            exit(EX__BASE)
        }
        
        // Load the directives
        var JSONString="{}"
        do{
            // If the file is named .json the file is deleted.
            JSONString = try NSString(contentsOfFile: fp, encoding: NSUTF8StringEncoding) as String
            JSONString = try Bartleby.cryptoDelegate.decryptString(JSONString) // Decrypt
        }catch{
            print("Deserialization of directives has failed \(fp) \(JSONString)")
            exit(EX__BASE)
        }
        
        if let _ : BsyncDirectives = Mapper<BsyncDirectives>().map(JSONString){
            print("# Directives \(fp) #\n\(JSONString)\n# End of Directives #")
            exit(EX_OK)
            
        }else{
            print("JSON Mapping of directives has failed \(fp)")
            exit(EX__BASE)
        }
        
        
    }

}
