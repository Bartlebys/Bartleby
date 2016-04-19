//
//  CreateDirectiveCommand.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 11/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Cocoa

class CreateDirectiveCommand: CommandBase {
    
    override init() {
        super.init()
        
        let sourceURLString = StringOption(shortFlag: "s", longFlag: "source", required: true,
            helpMessage: "URL of the source folder")
        
        let destinationURLString = StringOption(shortFlag: "d", longFlag: "destination", required: true,
            helpMessage: "URL of the destination folder")
        
        let password = StringOption(shortFlag: "p", longFlag: "password", required: true,
            helpMessage: "A password")
        
        let spaceUID = StringOption(shortFlag: "i", longFlag: "spaceUID",required: true,
            helpMessage: "A space UID")
        
        let filePath = StringOption(shortFlag: "f", longFlag: "file",required: true,
            helpMessage: "The file path e.f ~/Desktop/Samples/directives.json")
        
        let secretKey = StringOption(shortFlag: "y", longFlag: "secretKey",required: true,
            helpMessage: "The secret key to encryp the data (if not set we use bsync's default)")
        
        let sharedSalt = StringOption(shortFlag: "t", longFlag: "salt",required: true,
            helpMessage: "The salt (if not set we use bsync's default)")

        // Mutally required
        let phoneNumber = StringOption(shortFlag: "n", longFlag: "phoneNumber",required: false,
                                       helpMessage: "An phoneNumber may be required for authentication.")
        
        let email = StringOption(shortFlag: "e", longFlag: "email", required: false,
                                 helpMessage: "An email")
        
        // Optionnal
        
        let automaticTreesCreation = BoolOption(shortFlag: "a", longFlag: "automatic-trees-creation",required: false,
            helpMessage: "Creates automatically distant trees")
        
        let hashMapViewName = StringOption(shortFlag: "m", longFlag: "hashMapViewName",required: false,
            helpMessage: "The name of the optionnal hashMapView")
        
        let dontComputeHashMap = BoolOption(shortFlag: "c", longFlag: "dont-compute-hashmap",required: false,
            helpMessage: "Do not compute the hash map before synchronization")
        
        let help = BoolOption(shortFlag: "h", longFlag: "help",required: false,
            helpMessage: "Prints a help message.")
        
        let verbosity = BoolOption(shortFlag: "v", longFlag: "verbose",required: false,
            helpMessage: "Print verbose messages.")
        
        
        cli.addOptions( sourceURLString,
            destinationURLString,
            email,
            phoneNumber,
            password,
            spaceUID,
            filePath,
            automaticTreesCreation,
            secretKey,
            sharedSalt,
            hashMapViewName,
            dontComputeHashMap,
            help,
            verbosity )
        
        do {
            try cli.parse()
            self.isVerbose=verbosity.value
            
            guard email.value != nil || phoneNumber.value != nil else {
                print("Specify a email or a phone")
                exit(EX__BASE)
            }
            
            guard let source=sourceURLString.value else{
                print("Nil source URL")
                exit(EX__BASE)
            }
            guard let sourceURL=NSURL(string: source) else{
                print("Invalid source URL \(source)")
                exit(EX__BASE)
            }
            guard  let destination=destinationURLString.value else{
                print("Nil destination URL")
                exit(EX__BASE)
            }
            
            guard let destinationURL=NSURL(string: destination) else{
                print("Invalid destination URL \(destination)")
                exit(EX__BASE)
            }
            
            let folderPath=NSString(string: filePath.value!).stringByDeletingLastPathComponent
            let _=NSURL(fileURLWithPath:folderPath,isDirectory:true)
            
            guard  NSFileManager.defaultManager().fileExistsAtPath(folderPath) else{
                print("Directives file folder does not exist \(folderPath)")
                exit(EX__BASE)
            }
        
            let key = secretKey.value!
            let salt = sharedSalt.value!
            
            // Do not setup an URL
            Bartleby.configuration.KEY=key
            Bartleby.configuration.SHARED_SALT=salt
            Bartleby.configuration.API_CALL_TRACKING_IS_ENABLED=false
            Bartleby.sharedInstance.configureWith(Bartleby.configuration)
            
            if let directives:BsyncDirectives=Mapper<BsyncDirectives>().map([String : AnyObject]()){
                
                directives.sourceURL=sourceURL
                directives.destinationURL=destinationURL
                directives.spaceUID=spaceUID.value
                // The logic computeTheHashMap / dontComputeHashMap is inversed
                if dontComputeHashMap.wasSet{
                    directives.computeTheHashMap=false
                }else{
                    directives.computeTheHashMap=true
                }
                if automaticTreesCreation.wasSet{
                    directives.automaticTreeCreation=true
                }else{
                    directives.automaticTreeCreation=false
                }
                
                if hashMapViewName.value != nil {
                    directives.hashMapViewName=hashMapViewName.value!
                }
                directives.email=email.value
                directives.phoneNumber=phoneNumber.value
                directives.password=password.value
                directives.salt=sharedSalt.value
                
                // IMPORTANT !
                let validity=directives.areValid()
                guard validity.valid else{
                    if let explanation=validity.message{
                        print("Directives are not valid : \(explanation)")
                    }else{
                        print("Directives are not valid")
                    }
                    exit(EX__BASE)
                }
                
                if var JSONString:NSString = Mapper().toJSONString(directives){
                    let filePath=filePath.value!
                    do{
                        JSONString = try Bartleby.cryptoDelegate.encryptString(JSONString as String)
                        try JSONString.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
                    }catch{
                        print("\(error)")
                        exit(EX__BASE)
                    }
                    print("Directives have be saved to:\(filePath)")
                    exit(EX_OK)
                    
                }else{
                    print("The serialization has failed")
                    exit(EX__BASE)
                }
            }else{
                print("Unexpected instanciation error")
                exit(EX__BASE)
            }
            
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }
}
