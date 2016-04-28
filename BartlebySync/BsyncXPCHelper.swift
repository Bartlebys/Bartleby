//
//  BsyncXPCDMGManager.swift
//  BsyncXPC Client
//
//  Created by Benoit Pereira da silva on 29/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import ObjectMapper
    import BartlebyKit
#endif


public class BsyncXPCHelperDMGHandler {
    
    public var detachImageOnCompletion:Bool
    
    public var callBlock:CompletionHandler
    
    init(onCompletion:CompletionHandler, detach:Bool){
        callBlock=onCompletion
        detachImageOnCompletion=detach
    }
    
}

// MARK: -

// Simplifies the complex XPC workflow.
// When using DMG.
@objc(BsyncXPCHelper) public class BsyncXPCHelper:NSObject,BartlebyFileIO{
    
    static var masterFileName="Master"
    
    /// The BsyncXPC connection
    lazy var bsyncConnection: NSXPCConnection = {
        let connection = NSXPCConnection(serviceName: "fr.chaosmos.BsyncXPC")
        connection.remoteObjectInterface = NSXPCInterface(withProtocol: BsyncXPCProtocol.self)
        connection.resume()
        return connection
    }()
    
    // MARK: - DMG Creation
  
    
    /**
    
    IMPORTANT NOTES:
    
        - Any file system action while in the "thenDo block" should be done by calling FS method of remoteObjectProxy
        - Within the "thenDo Block" to conclude call whenDone.callBlock(success: succes,message: message)
        it will call the conclusiveHandler in wich you can put the next thing to do on completion.
     
    Sequence:
     
     1 Creates A DMG from a Card
     2 Creates the destination folder
     3 Creates DMG
     4 Invoke the attachFromCard SEQUENCE (5 more steps)
     
     - parameter card:                   the card
     - parameter thenDo: what do you want to do when the dmg will be mounted block.
     - parameter completionBlock:        the completionBlock
     */
    func createDMG(card:BsyncDMGCard
        ,thenDo:(remoteObjectProxy:BsyncXPCProtocol,volumePath:String,whenDone:BsyncXPCHelperDMGHandler)->()
        ,completion:BsyncXPCHelperDMGHandler)->(){
            
            // The card must be valid
            let validation = card.evaluate()
            if !validation.success {
                // TODO: @md change callblock to adopt
                completion.callBlock(Completion(success: validation.success, message: validation.message))
                return
            }
            
            
            let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
                completion.callBlock(Completion(success:false, message: NSLocalizedString("XPC connection error ",comment:"XPC connection error ")+"\(error.localizedDescription)"))
                return;
            }
            
            
            
            // The url is validated by card.evaluate()
            let url=NSURL(fileURLWithPath:card.path)
            let imageFolderPath:String!=url.URLByDeletingLastPathComponent?.path!
            
            if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
                
                
                // *********************************
                // 0# Create the destination folder
                // *********************************
                
                xpc.createDirectoryAtPath(imageFolderPath!, withIntermediateDirectories: true, attributes: nil,
                    callBack: { (success, message) -> () in
                        
                        if success {
                            // The destination has been Successfully created
                            xpc.fileExistsAtPath(card.path, callBack: { (exists, isADirectory,success, message) -> () in
                                if exists {
                                    // We preserve existing DMGs !
                                    completion.callBlock(Completion(success: false,message: NSLocalizedString("The disk image already exists ",comment:"The disk image already exists ") + "\(card.path)"))
                                    self.bsyncConnection.invalidate()
                                }else{
                                    
                                    
                                    // *********************************
                                    // 1# Create DMG
                                    // *********************************
                                    
                                    xpc.createImageDisk(
                                        card.path,
                                        volumeName:card.volumeName ,
                                        size:card.size,
                                        password:card.getPasswordForDMG(),
                                        callBack:{ (completionRef) -> () in
                                            if completionRef.success {
                                                
                                                // If a volume with this name is already mounted
                                                // We detach the volume
                                                
                                                xpc.fileExistsAtPath(card.volumePath,
                                                    callBack: { (exists, isADirectory,success, message) -> () in
                                                        if exists{
                                                            xpc.detachVolume(card.volumeName,
                                                                callBack:{ (detachCompletionRef) -> () in
                                                                    self.mountDMG(card, thenDo: thenDo, completion: completion)
                                                            })
                                                        }else{
                                                            self.mountDMG(card, thenDo: thenDo, completion: completion)
                                                        }
                                                })
                                                
                                            }else{
                                                // Failure on DMG Creation
                                                
                                                completion.callBlock(Completion(success: false,
                                                    message: NSLocalizedString("The disk creation has failed with message: ",
                                                        comment:"The disk creation has failed with message:" ) + "\(message)")
                                                )
                                                self.bsyncConnection.invalidate()
                                                return
                                            }
                                            
                                        }
                                    )
                                }
                            })
                            
                        }else{
                            completion.callBlock(Completion(success:false,
                                message: NSLocalizedString("Destination folder creation Failure. Path=",
                                    comment:"Destination folder creation Failure. Path=")+imageFolderPath))
                            self.bsyncConnection.invalidate()

                        }
                })
            }
    }

    
    // MARK: Attach and do...
    
    /**
     Sequence||Sub sequence of createFromCard:
     
    IMPORTANT NOTES:
    
    - Any file system action while in the "thenDo block" should be done by calling FS method of remoteObjectProxy
    - Within the "thenDo Block" to conclude call whenDone.callBlock(success: succes,message: message)
    it will call the conclusiveHandler in wich you can put the next thing to do on completion.
    
     1||5 Unmount if there is a volume with the current card volumeName
     2||6 Mounts the DMG
     3||7 Execute thenDo (the caller should invoke whenDone when it has done the job)
     4||8 Unmount the DMG
      ||9 Call The completionBlock on any error or on successfull completion
     
     - parameter card:             the card
     - parameter thenDo:           what do you want to do when the dmg will be mounted block.
     - parameter completionBlock:  the completion block
     */
    func mountDMG(card:BsyncDMGCard,
                  thenDo:(remoteObjectProxy:BsyncXPCProtocol,volumePath:String,whenDone:BsyncXPCHelperDMGHandler)->(),
                  completion:BsyncXPCHelperDMGHandler)->() {
            
            // The car must be valid
            let validation=card.evaluate()
            if validation.success == false {
                completion.callBlock(Completion(success:false,message: validation.message))
                return
            }
            
            let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
                completion.callBlock(Completion(success:false, message: NSLocalizedString("XPC connection error ",comment:"XPC connection error ")+"\(error.localizedDescription)"))
                return;
            }
            
            if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
                
                // For better readability we alias completion to finalCompletion
                let finalCompletion = completion
                // Then Create an encapsulated internal "completion" object
                // That will be called before to call the externalCompletion
                let internalCompletion = BsyncXPCHelperDMGHandler(onCompletion: { (completionRef) -> () in
                    if completionRef.success && completion.detachImageOnCompletion {
                        // We must detach
                            xpc.detachVolume(card.volumeName,
                                callBack: { (detachCompletionRef) -> () in
                                    if detachCompletionRef.success {
                                        // END
                                       
                                        finalCompletion.callBlock(Completion(success: true,
                                            message: "Successful creation of \(card.volumePath)"))
                                         self.bsyncConnection.invalidate()
                                    }else{
                                        // END
                                        finalCompletion.callBlock(Completion(success: false,
                                            message:NSLocalizedString("A failure has occured while detaching the Volume: ",
                                                comment:"A failure has occured when detaching the Volume: ")+"\(detachCompletionRef.message)"))
                                        self.bsyncConnection.invalidate()
                                    }
                            })
                            
                        }else{
                             finalCompletion.callBlock(Completion(success: completionRef.success, message:completionRef.message))
                        }
                    }, detach: finalCompletion.detachImageOnCompletion)
                
                
                // This sub method can be called directly
                // Or after detaching the volume (if there is volume with the name of this DMG)
                func mountDMG(){
                    xpc.attachVolume(from: card.path,
                        withPassword: card.getPasswordForDMG(),
                        callBack: {
                            (mountCompletionRef) -> () in
                            if mountCompletionRef.success {
                                
                                // Invoke the doWhen block
                                // And wait for its result.
                                
                                thenDo(remoteObjectProxy:xpc, volumePath:card.volumePath,whenDone: internalCompletion)
                    
                            }else{
                                // It is a failure.
                                internalCompletion.callBlock(Completion(success:false,message:NSLocalizedString("A failure has occured while attaching the Volume: ",
                                    comment:"A failure has occured when detaching the Volume: ")+"\(mountCompletionRef.message)"))
                            }
                    })
                    
                }
                
                // If a volume with this name is already mounted
                // We detach the volume
                
                xpc.fileExistsAtPath(card.volumeName,
                    callBack: { (exists, isADirectory,success, message) -> () in
                        if exists{
                            xpc.detachVolume(card.volumeName,
                                callBack:{ (fileExitsCompltionRef) -> () in
                                    mountDMG()
                            })
                        }else{
                            mountDMG()
                        }
                })
            }
    }
    
    // MARK: DMG unmout
    
    /**
     Unmount the DMG using BsyncXPC
     
     - parameter volumeName: the volume name
     - parameter completion: the completion handler
     */
    func unMountDMG(volumeName:String, completion:(success:Bool, message:String?, volumeName:String)->()) {
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            let message=NSLocalizedString("XPC connection error ",comment:"XPC connection error ")+"\(error.localizedDescription)"
            completion(success: false, message: message, volumeName: volumeName)
            return;
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.detachVolume(volumeName, callBack: { (detachVolumeCompletionRef) in
                completion(success: detachVolumeCompletionRef.success, message: detachVolumeCompletionRef.message, volumeName: volumeName)
            })
        }
    }
    
    // MARK: - Card and Directives
    
    
    /**
     Creates a card 
     
    the default card is accessible via project.dmgCard
     
     - parameter user:          the user
     - parameter context:       the IdentifiableCardContext
     - parameter withImagePath: the imagePath
     - parameter isMaster:      is it a master?
     
     - returns: the card
     */
    func cardFor(   user:User,
                    context:IdentifiableCardContext,
                    withImagePath:String,
                    isMaster:Bool)->BsyncDMGCard {
        
        let destination=withImagePath
        
        let hashName=CryptoHelper.hash(user.UID+context.UID)
        let imageFolderPath = (isMaster ? "\(destination)\(hashName)" : "\(destination)\(hashName)")
        
        let imagePath =  "\(imageFolderPath).sparseimage"
        let volumeName = (isMaster ? "Master_"+context.name : hashName)
        
        let card=BsyncDMGCard()
        card.contextUID=context.UID
        card.userUID=user.UID
        card.path=imagePath
        card.volumeName=volumeName
        card.directivesRelativePath=BsyncDirectives.DEFAULT_FILE_NAME
        return card
    }

    
    
    /**
     Simplifies the run directives for card call by using hanlders indirections
     
     - parameter card:     the card
     - parameter handlers: the handlers
     */
    func runDirectiveForCard(card:BsyncDMGCard
        ,handlers: ProgressAndCompletionHandler)->(){
        
        // The card must be valid
        let validation=card.evaluate()
        if validation.success == false {
            handlers.on(validation)
            return
        }
        
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            handlers.on(Completion(success:false, message: NSLocalizedString("XPC connection error ",comment:"XPC connection error ")+"\(error.localizedDescription)"))
            return;
        }
        
        
        // We need to provide a unique block to be compatible with the XPC context
        // So we use an handler adapter that relays to the progress and completion handlers
        // to mask the constraint.
        // TODO: @md Check if we can use ProgressAndCompletionHandler.getComposedProgressAndCompletionHandler()
        // !!! Response to Mr @md i do consider that's not possible by design... 
        // feel free to try or delete this if you cannot doit
        let indirectHandler:ComposedProgressAndCompletionHandler = {
            (currentTaskIndex,totalTaskCount,currentTaskProgress,message,data,completed,success)-> Void in
            handlers.notify?(Progression(currentTaskIndex:currentTaskIndex,
                          totalTaskCount:totalTaskCount,
                          currentTaskProgress:currentTaskProgress,
                          message:message,
                            data: data))
            if completed{
                handlers.on(Completion(success: success,message: message))
                
                self.bsyncConnection.invalidate()
            }
        }
        
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.runDirectives(card.standardDirectivesPath, secretKey:"", sharedSalt: "", handler: indirectHandler)
        }
        
    }
    
    
    
    // MARK: - Local File System BartlebyFileIO implementation
    

    /**
     Creates a directory
     
     - parameter path:                the path
     - parameter createIntermediates: create intermediates paths ?
     - parameter attributes:          attributes
     - parameter callBack:            the call back
     
     - returns: N/A
     */
    public func createDirectoryAtPath(path: String,
                               withIntermediateDirectories createIntermediates: Bool,
                                                           attributes: [String : AnyObject]?,
                                                           callBack:(success:Bool,message:String?)->())->(){
        
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            let message=NSLocalizedString("XPC connection error ",comment:"XPC connection error ")+"\(error.localizedDescription)"
            callBack(success: false, message: message)
            return;
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.createDirectoryAtPath(path, withIntermediateDirectories: createIntermediates, attributes:attributes, callBack: callBack)
        }
    }
    
    
    
    /**
     Reads the data
     
     - parameter path:            from file path
     - parameter readOptionsMask: readOptionsMask
     - parameter callBack:        the callBack
     
     - returns: NSData
     */
    public func readData( contentsOfFile path: String,
                                  options readOptionsMask: NSDataReadingOptions,
                                          callBack:(data:NSData?, success:Bool,message:String?)->())->(){
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            let message=NSLocalizedString("XPC connection error ",comment:"XPC connection error ")+"\(error.localizedDescription)"
            callBack(data:nil, success: false, message: message)
            return;
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.readData(contentsOfFile: path, options: readOptionsMask, callBack: callBack)
        }
    }
    
    
    /**
     Reads the data
     
     - parameter path:     the data file path
     - parameter callBack: the call back
     
     - returns: NSData
     */
    public func readData( contentsOfFile path: String,
                                  callBack:(data:NSData?)->())->(){
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            callBack(data:nil)
            return;
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.readData(contentsOfFile: path, callBack: callBack)
        }
    }
    
    
    /**
     Writes data to the given path
     
     - parameter data:             the data
     - parameter path:             the path
     - parameter useAuxiliaryFile: useAuxiliaryFile
     - parameter callBack:          the call back
     
     - returns: N/A
     */
    public func writeData( data:NSData,
                    path: String,
                    atomically useAuxiliaryFile: Bool,
                               callBack:(success:Bool,message:String?)->())->(){
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            let message=NSLocalizedString("XPC connection error ",comment:"XPC connection error ")+"\(error.localizedDescription)"
            callBack(success: false, message: message)
            return;
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.writeData(data, path:path, atomically: useAuxiliaryFile, callBack: callBack)
        }
    }
    
    /**
     Reads a string from a file
     
     - parameter path:     the file path
     - parameter enc:      the encoding
     - parameter callBack: the callBack
     
     - returns : N/A
     */
    public func readString(contentsOfFile path: String,
                                   encoding enc: NSStringEncoding,
                                            callBack:(string:String?,success:Bool,message:String?)->())->(){
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            let message=NSLocalizedString("XPC connection error ",comment:"XPC connection error ")+"\(error.localizedDescription)"
            callBack(string:nil, success: false, message: message)
            return;
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.readString(contentsOfFile: path, encoding: enc, callBack: callBack)
        }
    }
    
    
    /**
     Writes String to the given path
     
     - parameter string:            the string
     - parameter path:             the path
     - parameter useAuxiliaryFile: useAuxiliaryFile
     - parameter enc:              encoding
     - parameter callBack:          the call back
     
     - returns: N/A
     */
    public func writeString( string:String,
                      path: String,
                      atomically useAuxiliaryFile: Bool,
                                 encoding enc: NSStringEncoding,
                                          callBack:(success:Bool,message:String?)->())->(){
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            let message=NSLocalizedString("XPC connection error ",comment:"XPC connection error ")+"\(error.localizedDescription)"
            callBack(success: false, message: message)
            return;
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.writeString(string, path: path, atomically: useAuxiliaryFile, encoding: enc, callBack: callBack)
        }
    }
    
    
    /**
     Determines if a file exists and is a directory.
     
     - parameter path:     the path
     - parameter callBack: the call back
     
     - returns:  N/A
     */
    public func fileExistsAtPath(path: String,
                          callBack:(exists:Bool,isADirectory:Bool,success:Bool,message:String?)->())->(){
        
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            let message=NSLocalizedString("XPC connection error ",comment:"XPC connection error ")+"\(error.localizedDescription)"
            callBack(exists:false, isADirectory:false,success:false, message: message)
            return;
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.fileExistsAtPath(path, callBack: callBack)
        }
        
    }
    
    
    
    /**
     Removes the item at a given path
     Use with caution !
     
     - parameter path:     path
     - parameter callBack: the call back
     */
    public func removeItemAtPath(path: String,
                          callBack:(success:Bool,message:String?)->())->(){
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            let message=NSLocalizedString("XPC connection error ",comment:"XPC connection error ")+"\(error.localizedDescription)"
            callBack(success:false, message: message)
            return;
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.removeItemAtPath(path, callBack: callBack)
        }
    }

    
    /**
     Copies the file
     
     - parameter srcPath:  srcPath
     - parameter dstPath:  dstPath
     - parameter callBack: callBack
     
     - returns: N/A
     */
    public func copyItemAtPath(srcPath: String,
                        toPath dstPath: String,
                               callBack:(success:Bool,message:String?)->())->(){
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            let message=NSLocalizedString("XPC connection error ",comment:"XPC connection error ")+"\(error.localizedDescription)"
            callBack(success: false, message: message)
            return;
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.copyItemAtPath(srcPath, toPath:dstPath, callBack: callBack)
        }
    }
    
    /**
     Moves the file
     
     - parameter srcPath:  srcPath
     - parameter dstPath:  dstPath
     - parameter callBack: callBack
     
     - returns: N/A
     */
    public func moveItemAtPath(srcPath: String,
                        toPath dstPath: String,
                               callBack:(success:Bool,message:String?)->())->(){
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            let message=NSLocalizedString("XPC connection error ",comment:"XPC connection error ")+"\(error.localizedDescription)"
            callBack(success: false, message: message)
            return;
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.moveItemAtPath(srcPath, toPath: dstPath, callBack: callBack)
        }
    }
    
    
    /**
     Lists the content of the directory
     
     - parameter path:     the path
     - parameter callBack: the callBack
     
     - returns: N/A
     */
    public func contentsOfDirectoryAtPath(path: String,
                                   callBack:(success:Bool,content:[String],message:String?)->())->(){
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            let message=NSLocalizedString("XPC connection error ",comment:"XPC connection error ")+"\(error.localizedDescription)"
            callBack(success: false,content:[String](),message: message)
            return;
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.contentsOfDirectoryAtPath(path, callBack: callBack)
        }
    }

    
    
}
