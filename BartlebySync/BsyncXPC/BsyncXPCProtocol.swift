//
//  BsyncXPCProtocol.swift
//  BsyncXPC
//
//  Created by Benoit Pereira da silva on 20/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//
#if !USE_EMBEDDED_MODULES
    import BartlebyKit
#endif

/**
 * The BsyncXPC services protocol
 * (IMPORTANT) Keep in mind that each call may setup the XPC Bartleby shared instance.
 *  So be careful with secret and shared salt.
 */
@objc(BsyncXPCProtocol) protocol BsyncXPCProtocol {


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
    func createImageDisk(imageFilePath: String, volumeName: String, size: String, password: String?,
        callBack: (CompletionHandler))->()


    /**
     Attaches a Volume from a Dmg path

     - parameter path:         the path
     - parameter withPassword: the password
     - parameter callBack:      the XPC callback


     - returns: N/A
     */
    func attachVolume(from path: String, withPassword: String?,
        callBack: (CompletionHandler))->()


    /**
     Attaches a Volume identified by its card

     - parameter card:         the card
     - parameter callBack:      the XPC callback


     - returns: N/A
     */
    func attachVolume(identifiedBy card: BsyncDMGCard,
        callBack: (CompletionHandler))->()


    /**
     Detaches the volume

     - parameter named:    name of the volume
     - parameter callBack: the XPC Call back

     */
    func detachVolume(named: String,
        callBack: (CompletionHandler))->()


    // MARK: - Directives

    /**
    Create the directives

    - parameter directives: the directives
    - parameter secretKey:  the secret key to encrypt the directives
    - parameter sharedSalt: the shared salt
    - parameter callBack:   the call back

    - returns: N/A
    */
    func createDirectives(directives: BsyncDirectives, secretKey: String, sharedSalt: String, filePath: String,
        callBack: (CompletionHandler))->()

    /**
     Runs the directives.

     - parameter filePath:      the directives file path
     - parameter secretKey:     the secret key
     - parameter sharedSalt:    the shared salt
     - parameter handler:       the progress and completion block (we can pass only one block per XPC call)


     - returns: N/A
     */
    func runDirectives(filePath: String, secretKey: String, sharedSalt: String, handler: ComposedHandler)->()

    // MARK: File IO
    
    /**
     Creates a directory
     
     - parameter path:                the path
     - parameter createIntermediates: create intermediates paths ?
     - parameter handlers:            the handlers
     
     - returns: N/A
     */
    // TODO
    func createDirectoryAtPath(path: String,
                               handler: ComposedHandler)->()
    
    /**
     Reads the data with options
     
     - parameter path:            from file path
     - parameter readOptionsMask: readOptionsMask
     - parameter handlers:        the handlers
     
     - returns: N/A
     */
    func readData(contentsOfFile path: String,
                                 handler: ComposedHandler)->()
    
    /**
     Writes data to the given path
     
     - parameter data:             the data
     - parameter path:             the path
     - parameter useAuxiliaryFile: useAuxiliaryFile
     - parameter handlers:          the handlers
     
     - returns: N/A
     */
    func writeData(data: NSData,
                   path: String,
                   handler: ComposedHandler)->()
    
    /**
     Reads the data with options
     
     - parameter path:            from file path
     - parameter handlers:        the handlers
     
     Here is an example showing how to extract the string
     in the completion handler:
     
     { (read) in
     if let s = read.getStringResult() where read.success {
     // Handle success
     ...
     } else {
     // Handle error
     ...
     }
     }
     */
    func readString(contentsOfFile path: String,
                                   handler: ComposedHandler)->()
    
    /**
     Writes String to the given path using utf8 encoding
     
     - parameter string:            the string
     - parameter path:             the path
     - parameter useAuxiliaryFile: useAuxiliaryFile
     - parameter enc:              encoding
     - parameter handlers:          the handlers
     
     - returns: N/A
     */
    func writeString(string: String,
                     path: String,
                     handler: ComposedHandler)->()
    
    
    /**
     Determines if a file or directory exists.
     
     - parameter path:     the path
     - parameter handlers: The progress and completion handler
     
     - returns: N/A
     */
    func itemExistsAtPath(path: String,
                          handler: ComposedHandler)->()
    
    /**
     Determines if a file exists and is a directory.
     
     - parameter path:     the path
     - parameter handlers: The progress and completion handler
     
     - returns: N/A
     */
    func fileExistsAtPath(path: String,
                          handler: ComposedHandler)->()
    
    /**
     Determines if a directory exists.
     
     - parameter path:     the path
     - parameter handlers: The progress and completion handler
     
     - returns: N/A
     */
    func directoryExistsAtPath(path: String,
                               handler: ComposedHandler)->()
    
    /**
     Removes the item at a given path
     Use with caution !
     
     - parameter path:     path
     - parameter handlers: The progress and completion handler
     */
    func removeItemAtPath(path: String,
                          handler: ComposedHandler)->()
    
    /**
     Copies the file
     
     - parameter srcPath:  srcPath
     - parameter dstPath:  dstPath
     - parameter handlers: The progress and completion handler
     
     - returns: N/A
     */
    func copyItemAtPath(srcPath: String,
                        toPath dstPath: String,
                               handler: ComposedHandler)->()
    
    /**
     Moves the file
     
     - parameter srcPath:  srcPath
     - parameter dstPath:  dstPath
     - parameter handlers: The progress and completion handler
     
     - returns: N/A
     */
    func moveItemAtPath(srcPath: String,
                        toPath dstPath: String,
                               handler: ComposedHandler)->()
    
    
    /**
     Lists the content of the directory
     
     - parameter path:     the path
     - parameter handlers: The progress and completion handler
     */
    // TODO @md Explain how to extract result
    func contentsOfDirectoryAtPath(path: String,
                                   handler: ComposedHandler)->()
}
