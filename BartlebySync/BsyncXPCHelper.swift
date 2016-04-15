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


class BsyncXPCHelperHandler {
    
    var detachImageOnCompletion:Bool
    
    var callBlock:((success:Bool,message:String?)->())
    
    init(onCompletion:((success:Bool,message:String?)->()), detach:Bool){
        callBlock=onCompletion
        detachImageOnCompletion=detach
    }
    
}


// Simplifies the complex XPC workflow.
// When using DMG.
class BsyncXPCHelper{
    
    static var masterFileName="Master"
    
    /// The BsyncXPC connection
    lazy var bsyncConnection: NSXPCConnection = {
        let connection = NSXPCConnection(serviceName: "fr.chaosmos.BsyncXPC")
        connection.remoteObjectInterface = NSXPCInterface(withProtocol: BsyncXPCProtocol.self)
        connection.resume()
        return connection
    }()
    
    
    // MARK: Dmg Creation
  
    
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
        ,thenDo:(remoteObjectProxy:BsyncXPCProtocol,volumePath:String,whenDone:BsyncXPCHelperHandler)->()
        ,completion:BsyncXPCHelperHandler)->(){
            
            // The card must be valid
            let validation=card.evaluate()
            if validation.isValid == false {
                completion.callBlock(success:false,message: validation.message)
                return
            }
            
            
            let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
                completion.callBlock(success:false, message: NSLocalizedString("XPC connection error ",comment:"XPC connection error ")+"\(error.localizedDescription)")
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
                            xpc.fileExistsAtPath(card.path, callBack: { (exists, isADirectory, message) -> () in
                                if exists {
                                    // We preserve existing DMGs !
                                    completion.callBlock(success: false,
                                        message: NSLocalizedString("The disk image already exists ",comment:"The disk image already exists ") + "\(card.path)"
                                    )
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
                                        callBack:{ (success, message) -> () in
                                            if success {
                                                
                                                // If a volume with this name is already mounted
                                                // We detach the volume
                                                
                                                xpc.fileExistsAtPath(card.volumePath,
                                                    callBack: { (exists, isADirectory, message) -> () in
                                                        if exists{
                                                            xpc.detachVolume(card.volumeName,
                                                                callBack:{ (success, message) -> () in
                                                                    self.mountDMG(card, thenDo: thenDo, completion: completion)
                                                            })
                                                        }else{
                                                            self.mountDMG(card, thenDo: thenDo, completion: completion)
                                                        }
                                                })
                                                
                                            }else{
                                                // Failure on DMG Creation
                                                
                                                completion.callBlock(success: false,
                                                    message: NSLocalizedString("The disk creation has failed with message: ",
                                                        comment:"The disk creation has failed with message:" ) + "\(message)"
                                                )
                                                self.bsyncConnection.invalidate()
                                                return
                                            }
                                            
                                        }
                                    )
                                }
                            })
                            
                        }else{
                            completion.callBlock(success:false,
                                message: NSLocalizedString("Destination folder creation Failure. Path=",
                                    comment:"Destination folder creation Failure. Path=")+imageFolderPath)
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
                  thenDo:(remoteObjectProxy:BsyncXPCProtocol,volumePath:String,whenDone:BsyncXPCHelperHandler)->(),
                  completion:BsyncXPCHelperHandler)->() {
            
            // The car must be valid
            let validation=card.evaluate()
            if validation.isValid == false {
                completion.callBlock(success:false,message: validation.message)
                return
            }
            
            let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
                completion.callBlock(success:false, message: NSLocalizedString("XPC connection error ",comment:"XPC connection error ")+"\(error.localizedDescription)")
                return;
            }
            
            if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
                
                // For better readability we alias completion to finalCompletion
                let finalCompletion = completion
                // Then Create an encapsulated internal "completion" object
                // That will be called before to call the externalCompletion
                let internalCompletion = BsyncXPCHelperHandler(onCompletion: { (success, message) -> () in
                    if success && completion.detachImageOnCompletion {
                        // We must detach
                            xpc.detachVolume(card.volumeName,
                                callBack: { (success, message) -> () in
                                    if success {
                                        // END
                                       
                                        finalCompletion.callBlock(success: true,
                                            message: "Successful creation of \(card.volumePath)")
                                         self.bsyncConnection.invalidate()
                                    }else{
                                        // END
                                        finalCompletion.callBlock(success: false,
                                            message:NSLocalizedString("A failure has occured while detaching the Volume: ",
                                                comment:"A failure has occured when detaching the Volume: ")+"\(message)")
                                        self.bsyncConnection.invalidate()
                                    }
                            })
                            
                        }else{
                             finalCompletion.callBlock(success: success, message:message)
                        }
                    }, detach: finalCompletion.detachImageOnCompletion)
                
                
                // This sub method can be called directly
                // Or after detaching the volume (if there is volume with the name of this DMG)
                func mountDMG(){
                    xpc.attachVolume(from: card.path,
                        withPassword: card.getPasswordForDMG(),
                        callBack: {
                            (success, message) -> () in
                            if success {
                                
                                // Invoke the doWhen block
                                // And wait for its result.
                                
                                thenDo(remoteObjectProxy:xpc, volumePath:card.volumePath,whenDone: internalCompletion)
                    
                            }else{
                                // It is a failure.
                                internalCompletion.callBlock(success:false,message:NSLocalizedString("A failure has occured while attaching the Volume: ",
                                    comment:"A failure has occured when detaching the Volume: ")+"\(message)")
                            }
                    })
                    
                }
                
                // If a volume with this name is already mounted
                // We detach the volume
                
                xpc.fileExistsAtPath(card.volumeName,
                    callBack: { (exists, isADirectory, message) -> () in
                        if exists{
                            xpc.detachVolume(card.volumeName,
                                callBack:{ (success, message) -> () in
                                    mountDMG()
                            })
                        }else{
                            mountDMG()
                        }
                })
            }
    }
    
    
    
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
                if validation.isValid == false {
                    handlers.completionBlock(success:false,message: validation.message)
                    return
                }
                
                let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
                    handlers.completionBlock(success:false, message: NSLocalizedString("XPC connection error ",comment:"XPC connection error ")+"\(error.localizedDescription)")
                    return;
                }
                
                
                // We need to provide a unique block to be compatible with the XPC context
                // So we use an handler adapter that relays to the progress and completion handlers
                // to mask the constraint.
                let indirectHandler:((taskIndex:Int,totalTaskCount:Int,taskProgress:Double,progressMessage:String?,completed:Bool,successfulCompletion:Bool,completionMessage:String?)->())={
                    (taskIndex,totalTaskCount,taskProgress,progressMessage,completed,successfulCompletion,completionMessage)-> Void in
                    if let progressBlock=handlers.progressBlock{
                        progressBlock(taskIndex:taskIndex,totalTaskCount:totalTaskCount,taskProgress:taskProgress,message:progressMessage)
                    }
                    if completed{
                        handlers.completionBlock(success: completed,message: completionMessage)
                        self.bsyncConnection.invalidate()
                    }
                }
                
                if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
                    xpc.runDirectives(card.standardDirectivesPath, secretKey:"", sharedSalt: "", handler: indirectHandler)
                }
                
                
    }
    
    
    
    
    
    
}
