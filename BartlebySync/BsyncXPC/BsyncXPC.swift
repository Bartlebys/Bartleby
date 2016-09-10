//
//  BsyncXPC.swift
//  BsyncXPC
//
//  Created by Benoit Pereira da silva on 20/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import BartlebyKit
    import ObjectMapper
#endif


@objc class BsyncXPC: BFileManager, BsyncXPCProtocol {
    
    fileprivate let _dm = BsyncImageDiskManager()
    
    // MARK: Minimal protocol
    
    func touch(_ handler: ComposedHandler) {
        handler(nil, Completion.successState())
    }
    func createDMG(_ card: BsyncDMGCard, handler: ComposedHandler) {
        let handlers = Handlers.handlersFrom(handler)
        createDMG(card, handlers: handlers)
    }
    
    func createDMG(_ card: BsyncDMGCard, handlers: Handlers) {
        // The card must be valid
        let validation = card.evaluate()
        if validation.success {
            // The url is validated by card.evaluate()
            let url=URL(fileURLWithPath:card.imagePath)
            let imageFolderPath: String!=url.deletingLastPathComponent().path
            self.createDirectoryAtPath(imageFolderPath, handlers: Handlers { (directoryCreation) in
                if directoryCreation.success {
                    // The destination has been Successfully created
                    self.itemExistsAtPath(card.imagePath, handlers: Handlers { (existence) -> () in
                        if existence.success {
                            // We preserve existing DMGs !
                            handlers.on(Completion.failureState(NSLocalizedString("The disk image already exists ", comment:"The disk image already exists ") + "\(card.imagePath)", statusCode: .conflict))
                        } else {
                            
                            
                            // *********************************
                            // 1# Create DMG
                            // *********************************
                            
                            self.createImageDisk(
                                card.imagePath,
                                volumeName:card.volumeName ,
                                size:card.size,
                                password:card.getPasswordForDMG(),
                                handlers: Handlers { (imageCreation) -> () in
                                    if imageCreation.success {
                                        self.mountDMG(card, handlers: handlers)
                                    } else {
                                        // Failure on DMG Creation
                                        handlers.on(imageCreation)
                                        return
                                    }
                                })
                        }
                        })
                    
                } else {
                    handlers.on(directoryCreation)
                }
                })
            
        } else {
            handlers.on(validation)
            return
        }
    }
    
    func mountDMG(_ card: BsyncDMGCard, handler: ComposedHandler) {
        let handlers = Handlers.handlersFrom(handler)
        mountDMG(card, handlers: handlers)
    }
    
    func mountDMG(_ card: BsyncDMGCard, handlers: Handlers) {
        // The car must be valid
        let validation=card.evaluate()
        if validation.success {
            // If a volume with this name is already mounted
            // We detach the volume
            
            self.directoryExistsAtPath(card.volumeName,
                                       handlers: Handlers(completionHandler: { (existence) -> () in
                                        if existence.success {
                                            self.detachVolume(card.volumeName,
                                                handlers: Handlers { (fileExitsCompltionRef) -> () in
                                                    self.attachVolume(identifiedBy: card, handlers: handlers)
                                                })
                                        } else {
                                            self.attachVolume(identifiedBy: card, handlers: handlers)
                                        }
                                       }))
            
        } else {
            handlers.on(validation)
            return
        }
    }
    
    func unMountDMG(_ card: BsyncDMGCard, handler: ComposedHandler) {
        let handlers = Handlers.handlersFrom(handler)
        unMountDMG(card, handlers: handlers)
    }

    func unMountDMG(_ card: BsyncDMGCard, handlers: Handlers) {
        let validation = card.evaluate()
        if validation.success {
            self.detachVolume(card.volumeName, handlers: handlers)
        } else {
            handlers.on(validation)
        }
    }

    // MARK:- Disk Image Management
    
    /**
     
     Creates an image disk using bsync
     
     - parameter imageFilePath: the file path (absolute nix style)
     - parameter volumeName:    the volume name
     - parameter size:          a size e.g : "10m" = 10MB "1g"=1GB
     - parameter password:      the password (if omitted the disk image will not be crypted
     - parameter handler:       the composed handler for progress and completion
     
     - returns: nothing
     */
    func createImageDisk(_ imageFilePath: String, volumeName: String, size: String, password: String?,
                         handler: ComposedHandler) {
        let handlers = Handlers.handlersFrom(handler)
        createImageDisk(imageFilePath, volumeName: volumeName, size: size, password: password, handlers: handlers)
    }

    func createImageDisk(_ imageFilePath: String, volumeName: String, size: String, password: String?,
                         handlers: Handlers) {
        self._dm.createImageDisk(imageFilePath, volumeName: volumeName, size: size, password: password, handlers: handlers)
    }


    /**
     Resizes the image (!) the image must be detached.

     - parameter size:       the size according to sizeSpecs ??b|??k|??m|??g|??t|??p|??e
     - parameter volumePath: the volume path
     - parameter handler:    the handler
     */
    func resizeDMG(_ size:String,imageFilePath:String,password:String?,completionHandler:CompletionHandler){
        self._dm.resizeDMG(size, imageFilePath: imageFilePath, password: password, completionHandler: completionHandler)
    }


    /**
     Attaches a Volume from a Dmg path
     
     - parameter path:         the path
     - parameter withPassword: the password
     - parameter handler:       the composed handler for progress and completion
     
     - returns: return value description
     */
    func attachVolume(from path: String, withPassword: String?, handler: ComposedHandler) {
        let handlers = Handlers.handlersFrom(handler)
        attachVolume(from: path, withPassword: withPassword, handlers: handlers)
    }
    
    func attachVolume(from path: String, withPassword: String?, handlers: Handlers) {
        self._dm.attachVolume(from: path, withPassword: withPassword, handlers: handlers)
    }
    
    /**
     Attaches a Volume identified by its card
     
     - parameter card:         the card
     - parameter handler:       the composed handler for progress and completion
     
     
     - returns: N/A
     */
    func attachVolume(identifiedBy card: BsyncDMGCard, handler: ComposedHandler) {
        let password=card.getPasswordForDMG()
        attachVolume(from: card.imagePath, withPassword: password, handler: handler)
        
    }
    
    func attachVolume(identifiedBy card: BsyncDMGCard, handlers: Handlers) {
        let password=card.getPasswordForDMG()
        attachVolume(from: card.imagePath, withPassword: password, handlers: handlers)
        
    }

    /**
     Detaches the volume
     
     - parameter named:    name of the volume
     - parameter handler:       the composed handler for progress and completion
     
     */
    func detachVolume(_ named: String, handler: ComposedHandler) {
        let handlers = Handlers.handlersFrom(handler)
        detachVolume(named, handlers: handlers)
    }
    
    func detachVolume(_ named: String, handlers: Handlers) {
        handlers.appendCompletionHandler { (test) in
            print("test")
        }
        self._dm.detachVolume(named, handlers: handlers)
    }
    
    // MARK: - Directives
    
    /**
     Create the directives
     
     - parameter directives: the directives
     - parameter secretKey:  the secret key to encrypt the directives
     - parameter sharedSalt: the shared salt
     - parameter handler:       the composed handler for progress and completion
     
     - returns: N/A
     */
    func createDirectives(_ directives: BsyncDirectives, secretKey: String, sharedSalt: String, filePath: String,
                          handler: (ComposedHandler)) {
        
        let handlers = Handlers.handlersFrom(handler)
        // Check the validity
        
        let validity=directives.areValid()
        guard validity.valid else {
            var validityMessage=""
            validityMessage="Directives are not valid : \(validity.message)"
            handlers.on(Completion.failureState(validityMessage, statusCode: .precondition_Failed))
            return
        }
        
        Bartleby.configuration.KEY=secretKey
        Bartleby.configuration.SHARED_SALT=sharedSalt
        Bartleby.configuration.API_CALL_TRACKING_IS_ENABLED=false
        Bartleby.sharedInstance.configureWith(Bartleby.configuration)
        
        // Save the file
        if var JSONString: NSString = Mapper().toJSONString(directives) {
            do {
                JSONString = try Bartleby.cryptoDelegate.encryptString(JSONString as String)
                try JSONString.write(toFile: filePath, atomically: true, encoding: Default.STRING_ENCODING.rawValue)
            } catch {
                handlers.on(Completion.failureState("\(error)", statusCode: .undefined))
                return
            }
            handlers.on(Completion.successState("Directives have be saved to:\(filePath)"))
        } else {
            handlers.on(Completion.failureState("Serialization failure", statusCode: .undefined))
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
    func runDirectives(_ filePath: String, secretKey: String, sharedSalt: String, handler: ComposedHandler) {
        
        // Those handlers produce an adaptation
        // From the unique handler form
        // progress and completion handlers.
        let handlers=Handlers.handlersFrom(handler)

        Bartleby.configuration.KEY=secretKey
        Bartleby.configuration.SHARED_SALT=sharedSalt
        Bartleby.configuration.API_CALL_TRACKING_IS_ENABLED=false
        Bartleby.sharedInstance.configureWith(Bartleby.configuration)

        do {
            let admin = BsyncAdmin()
            let directives = try admin.loadDirectives(filePath)
            admin.runDirectives(directives, sharedSalt: sharedSalt, handlers: handlers)
        } catch {
            handlers.on(Completion.failureStateFromError(error))
        }
    }
    
    // MARK: File IO
    func createDirectoryAtPath(_ path: String, handler: ComposedHandler) {
        self.createDirectoryAtPath(path, handlers: Handlers.handlersFrom(handler))
    }
    
    func readData(contentsOfFile path: String, handler: ComposedHandler) {
        self.readData(contentsOfFile: path, handlers: Handlers.handlersFrom(handler))
    }
    
    func writeData(_ data: Data, path: String, handler: ComposedHandler) {
        self.writeData(data, path: path, handlers: Handlers.handlersFrom(handler))
    }
    
    func readString(contentsOfFile path: String, handler: ComposedHandler) {
        self.readString(contentsOfFile: path, handlers: Handlers.handlersFrom(handler))
    }
    
    func writeString(_ string: String, path: String, handler: ComposedHandler) {
        self.writeString(string, path: path, handlers: Handlers.handlersFrom(handler))
    }
    
    func itemExistsAtPath(_ path: String, handler: ComposedHandler) {
        self.itemExistsAtPath(path, handlers: Handlers.handlersFrom(handler))
    }
    
    func directoryExistsAtPath(_ path: String, handler: ComposedHandler) {
        self.directoryExistsAtPath(path, handlers: Handlers.handlersFrom(handler))
    }
    
    func fileExistsAtPath(_ path: String, handler: ComposedHandler) {
        self.fileExistsAtPath(path, handlers: Handlers.handlersFrom(handler))
    }
    
    func removeItemAtPath(_ path: String, handler: ComposedHandler) {
        self.removeItemAtPath(path, handlers: Handlers.handlersFrom(handler))
    }
    
    func copyItemAtPath(_ path: String, toPath: String, handler: ComposedHandler) {
        self.copyItemAtPath(path, toPath: toPath, handlers: Handlers.handlersFrom(handler))
    }
    
    func moveItemAtPath(_ path: String, toPath: String, handler: ComposedHandler) {
        self.moveItemAtPath(path, toPath: toPath, handlers: Handlers.handlersFrom(handler))
    }
    
    func contentsOfDirectoryAtPath(_ path: String, handler: ComposedHandler) {
        self.contentsOfDirectoryAtPath(path, handlers: Handlers.handlersFrom(handler))
    }
    
}
