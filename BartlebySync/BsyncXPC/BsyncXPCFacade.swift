//
//  BsyncXPCFacade.swift
//  BsyncXPC
//
//  Created by Benoit Pereira da silva on 20/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation


@objc(BsyncXPCFacade) class BsyncXPCFacade:BFileManager,BsyncXPCProtocol{
    
    
    /**
     
     Creates an image disk using bsync
     
     - parameter imageFilePath: the file path (absolute nix style)
     - parameter volumeName:    the volume name
     - parameter size:          a size e.g : "10m" = 10MB "1g"=1GB
     - parameter password:      the password (if omitted the disk image will not be crypted
     - parameter callBack:      the result of the creation
     
     - returns: nothing
     */
    func createImageDisk(imageFilePath:String,volumeName:String,size:String,password:String?,
        callBack:(success:Bool,message:String?)->())->(){
            print("imageFilePath \(imageFilePath)")
            let dmgManager=BsyncImageDiskManager()
            do{
                let result = try dmgManager.createImageDisk(imageFilePath, volumeName: volumeName, size: size, password: password)
                callBack(success: result, message:nil)
            }catch {
                callBack(success: false, message:"An error has occured")
            }
    }
    
    /**
     Attaches a Volume from a Dmg path
     
     - parameter path:         the path
     - parameter withPassword: the password
     - parameter callBack:      the XPC callback
     
     - returns: return value description
     */
    func attachVolume(from path:String,withPassword:String?,
        callBack:(success:Bool,message:String?)->())->(){
            let dmgManager=BsyncImageDiskManager()
            do{
                let result = try dmgManager.attachVolume(from: path, withPassword: withPassword)
                callBack(success: result, message:nil)
            }catch {
                callBack(success: false, message:"An error has occured")
            }
    }
    
    /**
     Attaches a Volume identified by its card
     
     - parameter card:         the card
     - parameter callBack:      the XPC callback
     
     
     - returns: N/A
     */
    func attachVolume(identifiedBy card:BsyncDMGCard,
        callBack:(success:Bool,message:String?)->())->(){
            let password=card.getPasswordForDMG()
            self.attachVolume(from: card.path, withPassword: password, callBack:callBack)
            
    }
    
    
    /**
     Detaches the volume
     
     - parameter named:    name of the volume
     - parameter callBack: the XPC Call back
     
     */
    func detachVolume(named:String,
        callBack:(success:Bool,message:String?)->())->(){
            let dmgManager=BsyncImageDiskManager()
            do{
                let result = try dmgManager.detachVolume(named)
                callBack(success: result, message:nil)
            }catch {
                callBack(success: false, message:"An error has occured")
            }
    }
    
    
    
    // MARK: - Directives
    
    /**
    Create the directives
    
    - parameter directives: the directives
    - parameter secretKey:  the secret key to encrypt the directives
    - parameter sharedSalt: the shared salt
    - parameter callBack:   the call back
    
    - returns: N/A
    */
    func createDirectives(directives:BsyncDirectives,secretKey:String,sharedSalt:String, filePath:String,
        callBack:(success:Bool,message:String?)->())->(){
            
            // Check the validity
            
            let validity=directives.areValid()
            guard validity.valid else{
                var validityMessage=""
                if let explanation=validity.message{
                    validityMessage="Directives are not valid : \(explanation)"
                }else{
                    validityMessage="Directives are not valid"
                }
                callBack(success: false, message: validityMessage)
                return;
            }
        
            Bartleby.configuration.KEY=secretKey
            Bartleby.configuration.SHARED_SALT=sharedSalt
            Bartleby.configuration.API_CALL_TRACKING_IS_ENABLED=false
            Bartleby.sharedInstance.configureWith(Bartleby.configuration)
     
            // Save the file
            if var JSONString:NSString = Mapper().toJSONString(directives){
                do{
                    JSONString = try Bartleby.cryptoDelegate.encryptString(JSONString as String)
                    try JSONString.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
                }catch{
                    callBack(success: false, message: "\(error)")
                    return;
                }
                callBack(success: true, message: "Directives have be saved to:\(filePath)")
            }else{
                callBack(success: false, message: "Serialization failure")
            }
            
    }
    
    
    /**
     Runs the directives.
     
     - parameter filePath:      the directives file path
     - parameter secretKey:     the secret key
     - parameter sharedSalt:    the shared salt
     - parameter handler:       the progress and completion block (we can pass only one block per XPC call)
     
     
     - returns: N/A
     */
    func runDirectives(filePath:String,secretKey:String,sharedSalt:String
        ,handler:ComposedProgressAndCompletionHandler)->(){
            
            
            // Those handlers produce an adaptation 
            // From the unique handler form 
            // progress and completion handlers.
       
            let handlers=ProgressAndCompletionHandler.handlersFrom(handler)
        
            // This command is composed and complex
            // So we have adopted a versatile completion and progress
            // To reuse the command implementation.
            let runDirectivesCommand=RunDirectivesCommand()
            if handlers.progressBlock != nil {
                runDirectivesCommand.addProgressBlock(handlers.progressBlock!)
            }
            runDirectivesCommand.addcompletionBlock(handlers.completionBlock)
            
            
            //run the directive command itself
            runDirectivesCommand.runDirectives(filePath, secretKey: secretKey, sharedSalt: sharedSalt, verbose: false)
        
    
            
    }
    
    

    
    
}