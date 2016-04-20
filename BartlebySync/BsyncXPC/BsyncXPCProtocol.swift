//
//  BsyncXPCProtocol.swift
//  BsyncXPC
//
//  Created by Benoit Pereira da silva on 20/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

/**
 * The BsyncXPC services protocol
 * (IMPORTANT) Keep in mind that each call may setup the XPC Bartleby shared instance.
 *  So be careful with secret and shared salt.
 */
@objc(BsyncXPCProtocol) protocol BsyncXPCProtocol:BartlebyFileIO{
    
    
    // MARK:- Disk Image Management
    
    /**
     
     Creates an image disk using bsync
     
     - parameter imageFilePath: the file path (absolute nix style)
     - parameter volumeName:    the volume name
     - parameter size:          a size e.g : "10m" = 10MB "1g"=1GB
     - parameter password:      the password (if omitted the disk image will not be crypted
     - parameter callBack:      the XPC callback
    
    
    - returns: N/A
     */
    func createImageDisk(imageFilePath:String,volumeName:String,size:String,password:String?,
        callBack:(success:Bool,message:String?)->())->()
    
 
    /**
     Attaches a Volume from a Dmg path
     
     - parameter path:         the path
     - parameter withPassword: the password
     - parameter callBack:      the XPC callback
     
     
     - returns: N/A
     */
    func attachVolume(from path:String,withPassword:String?,
        callBack:(success:Bool,message:String?)->())->()

    
    /**
     Attaches a Volume identified by its card
     
     - parameter card:         the card
     - parameter callBack:      the XPC callback
     
     
     - returns: N/A
     */
    func attachVolume(identifiedBy card:BsyncDMGCard,
        callBack:(success:Bool,message:String?)->())->()


    /**
     Detaches the volume
     
     - parameter named:    name of the volume
     - parameter callBack: the XPC Call back
     
     */
    func detachVolume(named:String,
        callBack:(success:Bool,message:String?)->())->()
    
    
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
        callBack:(success:Bool,message:String?)->())->()
    
    /**
     Runs the directives.
     
     - parameter filePath:      the directives file path
     - parameter secretKey:     the secret key
     - parameter sharedSalt:    the shared salt
     - parameter handler:       the progress and completion block (we can pass only one block per XPC call)
     
     
     - returns: N/A
     */
    func runDirectives(filePath:String,secretKey:String,sharedSalt:String
        ,handler:ComposedProgressAndCompletionHandler)->()
    
    

    
    // MARK: - Local File System Api
    
    
    // Those method are accessor to NSFileManager's related methods.
    // Due to XPC context they are not throwing exception but using a block call back.
    
    
    
    
}
