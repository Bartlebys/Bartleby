//
//  RunDirectivesCommand.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 06/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Foundation

/*

*/
public class RunDirectivesCommand:CommandBase {
    
    /**
     The commandline mode execution
     */
    func executeCMD(){
        
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
            
            self.runDirectives(filePath.value!, secretKey: key, sharedSalt: salt, verbose: verbosity.value)
            
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }
    
    /**
     Run the directives
     
     - parameter filePath:   the directives filePath
     - parameter secretKey:  the secret key to decrypt the directives
     - parameter sharedSalt: the shared salt
     - parameter verbose:    verbose or not
     */
    public func runDirectives(filePath:String,secretKey:String,sharedSalt:String,verbose:Bool=true){

        self.isVerbose=verbose
        
         // We configure Bartleby
        Bartleby.configuration.API_BASE_URL=NSURL()
        Bartleby.configuration.KEY=secretKey
        Bartleby.configuration.SHARED_SALT=sharedSalt
        Bartleby.configuration.API_CALL_TRACKING_IS_ENABLED=true
        Bartleby.configuration.ENABLE_BPRINT=verbose
        Bartleby.sharedInstance.configureWith(Bartleby.configuration)
        
        let fp:String=filePath
        
        if NSFileManager.defaultManager().fileExistsAtPath(fp)==false{
            self.completion_EXIT(EX__BASE, message: "Unexisting path \(fp)")
            return
        }
        
        // Load the directives
        var JSONString="{}"
        do{
            // If the file is named .json the file is deleted.
            JSONString = try NSString(contentsOfFile: fp, encoding: NSUTF8StringEncoding) as String
            JSONString = try Bartleby.cryptoDelegate.decryptString(JSONString as String)
        }catch{
            self.completion_EXIT(EX__BASE,message:"Deserialization of directives has failed \(fp) \(JSONString)")
            return
        }
        
        if let directives:BsyncDirectives = Mapper<BsyncDirectives>().map(JSONString){
            
            guard directives.sourceURL != nil else {
                self.completion_EXIT(EX__BASE,message:"Source URL is void")
                return
            }
            
            
            guard directives.destinationURL != nil else {
                self.completion_EXIT(EX__BASE,message:"Destination URL is void")
                return
            }
            
            // IMPORTANT ! 
            let validity=directives.areValid()
            guard validity.valid else{
                if let explanation=validity.message{
                    self.completion_EXIT(EX__BASE,message:"Directives are not valid : \(explanation)")
                    return
                }else{
                    self.completion_EXIT(EX__BASE,message:"Directives are not valid")
                    return
                }
            }
            
            
            func runSynchronizationCommand(){
                
                let hashMapviewName:String?=(directives.hashMapViewName == BsyncDirectives.NO_HASHMAPVIEW) ? nil : directives.hashMapViewName
                
                let synchronizeCommand=SynchronizeCommand()
                synchronizeCommand.completionBlock=self.completionBlock
                synchronizeCommand.progressBlock=self.progressBlock
                
                synchronizeCommand.synchronize( directives.sourceURL!,
                                                destinationURL: directives.destinationURL!,
                                                hashMapViewName: hashMapviewName,
                                                email: directives.email,
                                                phoneNumber: directives.phoneNumber,
                                                password: directives.password,
                                                spaceUID: directives.spaceUID,
                                                sharedSalt: directives.salt,
                                                verbose:verbose,
                                                autoCreateTrees: directives.automaticTreeCreation)
            }
            
            
            
            if directives.computeTheHashMap==true{
                
                // Before to Proceed to hash.
                // We need to determine what ?
                // The source or the destination ?
                
                // Syncronization context
                let context=BsyncContext(
                                            sourceURL: directives.sourceURL!,
                                            andDestinationUrl: directives.destinationURL!,
                                            restrictedTo: directives.hashMapViewName,
                                            autoCreateTrees: directives.automaticTreeCreation
                                        )
                

                
                var url:NSURL?
                switch context.mode(){
                case BsyncMode.SourceIsDistantDestinationIsLocal:
                    url=directives.destinationURL!
                case BsyncMode.SourceIsLocalDestinationIsDistant:
                    url=directives.sourceURL!
                default:
                    url=nil
                }
                if url != nil {
                    var analyzer=BsyncLocalAnalyzer()
                    do {
                        if let folderPath=url!.path{
                            
                            let fm=NSFileManager.defaultManager()
                            var isAFolder : ObjCBool = false
                            if directives.automaticTreeCreation{
                                try fm.createDirectoryAtPath(folderPath, withIntermediateDirectories: true, attributes:nil)
                            }
                            if fm.fileExistsAtPath(folderPath, isDirectory: &isAFolder){
                                if isAFolder{
                                    self.printVerbose("# hash map computation #")
                                    try analyzer.createHashMapFromLocalPath(folderPath,
                                        progressBlock: { (hash, path, index) -> Void in
                                            self.printVerbose("\(index) checksum of \(path) is \(hash)")
                                        }, completionBlock: { (hashMap) -> Void in
                                            self.printVerbose("# End of hash map computation#")
                                            runSynchronizationCommand()
                                    })
                                }else{
                                    self.completion_EXIT(EX__BASE,message:"\(folderPath) is not a directory")
                                    return
                                }
                            }else{
                                self.completion_EXIT(EX__BASE,message:"Unexisting folder path: \(folderPath)")
                                return
                            }
                            
                        }else{
                            self.completion_EXIT(EX__BASE,message:"Url to filtered path error: \(url)")
                            return
                        }
                    }catch BsyncLocalAnalyzerError.InvalidURL(let explanations){
                        self.completion_EXIT(EX__BASE,message:explanations)
                        return
                    }catch{
                        self.completion_EXIT(EX__BASE,message:"Unexpected error \(error)")
                        return
                    }
                }else{
                    self.completion_EXIT(EX__BASE,message:"Unsupported mode \(context.mode())")
                    return
                }
                
            }else{
                // There is no need to compute
                // Run the synchro directly
                runSynchronizationCommand()
            }
        }
        
        
    }
}