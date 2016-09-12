//
//  BsyncXPCHelper.swift
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

// MARK: -

// Simplifies the complex XPC workflow.
// When using DMG.
open class BsyncXPCHelper: NSObject, BartlebyFileIO {

    static var masterFileName="Master"

    /// The BsyncXPC connection
    lazy var bsyncConnection: NSXPCConnection = {
        let connection = NSXPCConnection(serviceName: "fr.chaosmos.BsyncXPC")
        connection.remoteObjectInterface = NSXPCInterface(with: BsyncXPCProtocol.self)
        connection.resume()
        return connection
    }()


    func touch(_ handlers: Handlers) {
        if let xpc = self.bsyncConnection.remoteObjectProxy as? BsyncXPCProtocol {
            xpc.touch(handlers.composedHandler())
        } else {
            handlers.on(Completion.failureState("Error connecting XPC", statusCode: .undefined))
        }
    }

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
    func createDMG(_ card: BsyncDMGCard,
                   thenDo:@escaping (_ whenDone: Handlers)->(),
                   detachImageOnCompletion: Bool,
                   handlers: Handlers) {

        // The card must be valid
        let validation = card.evaluate()
        if validation.success {

            if let xpc = bsyncConnection.remoteObjectProxy as? BsyncXPCProtocol {

                // *********************************
                // 0# Create the destination folder
                // *********************************

                xpc.createDMG(card, handler: Handlers { (creation) -> () in
                    if creation.success {
                        thenDo(Handlers { (done) in
                            if detachImageOnCompletion {
                                xpc.detachVolume(card.volumeName, handler: Handlers { (detach) in
                                    handlers.on(detach)
                                    }.composedHandler())
                            } else {
                                handlers.on(done)
                            }
                            })
                    } else {
                        handlers.on(creation)
                    }


                    }.composedHandler())
            } else {
                handlers.on(Completion.failureState("Error connecting XPC", statusCode: .undefined))
            }
        } else {
            handlers.on(validation)
        }
    }

    /*
     Resizes the image the image must be mounted.

     - parameter size:       the size according to sizeSpecs ??b|??k|??m|??g|??t|??p|??e
     - parameter volumePath: the volume path
     - parameter handler:    the handler
     */
    open func resizeDMG(_ size:String,imageFilePath:String,password:String?,completionHandler:CompletionHandler){
        if let xpc = bsyncConnection.remoteObjectProxy as? BsyncXPCProtocol {
            xpc.resizeDMG(size, imageFilePath: imageFilePath, password: password, completionHandler: completionHandler)
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
    func mountDMG(_ card: BsyncDMGCard,
                  thenDo:@escaping (_ whenDone: Handlers)->(),
                  detachImageOnCompletion: Bool,
                  handlers: Handlers) {

        // The card must be valid
        let validation=card.evaluate()
        if validation.success {

            if let xpc = bsyncConnection.remoteObjectProxy as? BsyncXPCProtocol {

                // Then Create an encapsulated internal "completion" object
                // That will be called before to call the externalCompletion
                let internalHandler = Handlers { (done) in
                    if detachImageOnCompletion {
                        // We must detach
                        xpc.detachVolume(card.volumeName, handler: handlers.composedHandler())
                    } else {
                        handlers.on(done)
                    }
                }

                // This sub method can be called directly
                // Or after detaching the volume (if there is volume with the name of this DMG)
                func mountDMG() {
                    xpc.mountDMG(card, handler: Handlers {
                                        (mountCompletionRef) -> () in
                                        if mountCompletionRef.success {

                                            // Invoke the doWhen block
                                            // And wait for its result.

                                            thenDo(internalHandler)

                                        } else {
                                            // It is a failure.
                                            internalHandler.on(mountCompletionRef)
                                        }
                                        }.composedHandler())
                }

                // If a volume with this name is already mounted
                // We detach the volume

                xpc.directoryExistsAtPath(card.volumeName,
                                          handler: Handlers(completionHandler: { (existence) -> () in
                                            if existence.success {
                                                xpc.detachVolume(card.volumeName,
                                                    handler: Handlers { (fileExitsCompltionRef) -> () in
                                                        mountDMG()
                                                        }.composedHandler())
                                            } else {
                                                mountDMG()
                                            }
                                          }).composedHandler())
            } else {
                handlers.on(Completion.failureState("Error connecting XPC", statusCode: .undefined))
            }
        } else {
            handlers.on(validation)
        }

    }

    // MARK: DMG unmout

    /**
     Unmount the DMG using BsyncXPC

     - parameter volumeName: the volume name
     - parameter completion: the completion handler
     */
    func unMountDMG(_ card: BsyncDMGCard, handlers: Handlers) {
        // The card must be valid
        let validation=card.evaluate()
        if validation.success {
            if let xpc = bsyncConnection.remoteObjectProxy as? BsyncXPCProtocol {
                xpc.unMountDMG(card, handler: handlers.composedHandler())
            } else {
                handlers.on(Completion.failureState("Error connecting XPC", statusCode: .undefined))
            }
        } else {
            handlers.on(validation)
        }
    }

    // MARK: - Card and Directives


    /**
     Creates a card

     the default card is accessible via project.dmgCard

     - parameter user:          the user
     - parameter context:       the IdentifiableCardContext
     - parameter folderPath: the imagePath
     - parameter isMaster:      is it a master?

     - returns: the card
     */
    func cardFor(   _ user: User,
                    context: IdentifiableCardContext,
                    folderPath: String,
                    isMaster: Bool) -> BsyncDMGCard {

        let destination=folderPath

        let hashName=CryptoHelper.hash(user.UID+context.UID)
        let imageFolderPath = (isMaster ? "\(destination)\(hashName)" : "\(destination)\(hashName)")

        let imagePath =  "\(imageFolderPath)."+BsyncDMGCard.DMG_EXTENSION

        let card=BsyncDMGCard()
        card.contextUID=context.UID
        card.userUID=user.UID
        card.imagePath=imagePath
        card.volumeName=hashName
        card.directivesRelativePath=BsyncDirectives.DEFAULT_FILE_NAME
        return card
    }



    /**
     Simplifies the run directives for card call by using hanlders indirections

     - parameter card:     the card
     - parameter handlers: the handlers
     */
    func runDirectivesFromCard(_ card: BsyncDMGCard, handlers: Handlers)->() {

        // The card must be valid
        let validation=card.evaluate()
        if validation.success {
            if let xpc = bsyncConnection.remoteObjectProxy as? BsyncXPCProtocol {
                xpc.runDirectives(card.standardDirectivesPath, secretKey:"", sharedSalt: "", handler: handlers.composedHandler())
            } else {
                handlers.on(Completion.failureState("Error connecting XPC", statusCode: .undefined))
            }
        } else {
            handlers.on(validation)
        }

    }



    // MARK: - Local File System BartlebyFileIO implementation


    /**
     Creates a directory

     - parameter path:                the path
     - parameter handlers:            the progress and completion handlers

     - returns: N/A
     */
    open func createDirectoryAtPath(_ path: String, handlers: Handlers) -> () {

        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            handlers.on(Completion.failureStateFromError(error))
            return
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.createDirectoryAtPath(path, handler: handlers.composedHandler())
        } else {
            handlers.on(Completion.failureState("Error connecting XPC", statusCode: .undefined))
        }
    }

    /**
     Reads the data

     - parameter path:     the data file path
     - parameter handlers:            the progress and completion handlers

     - returns: NSData
     */
    open func readData( contentsOfFile path: String,
                                         handlers: Handlers) -> () {
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            handlers.on(Completion.failureStateFromError(error))
            return
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.readData(contentsOfFile: path, handler: handlers.composedHandler())
        } else {
            handlers.on(Completion.failureState("Error connecting XPC", statusCode: .undefined))
        }
    }


    /**
     Writes data to the given path

     - parameter data:             the data
     - parameter path:             the path
     - parameter handlers:            the progress and completion handlers

     - returns: N/A
     */
    open func writeData( _ data: Data,
                           path: String,
                           handlers: Handlers) -> () {
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            handlers.on(Completion.failureStateFromError(error))
            return
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.writeData(data, path:path, handler: handlers.composedHandler())
        } else {
            handlers.on(Completion.failureState("Error connecting XPC", statusCode: .undefined))
        }
    }

    /**
     Reads a string from a file

     - parameter path:     the file path
     - parameter handlers:            the progress and completion handlers

     - returns : N/A
     */
    open func readString(contentsOfFile path: String,
                                          handlers: Handlers) -> () {
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            handlers.on(Completion.failureStateFromError(error))
            return
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.readString(contentsOfFile: path, handler: handlers.composedHandler())
        } else {
            handlers.on(Completion.failureState("Error connecting XPC", statusCode: .undefined))
        }
    }


    /**
     Writes String to the given path

     - parameter string:            the string
     - parameter path:             the path
     - parameter handlers:            the progress and completion handlers

     - returns: N/A
     */
    open func writeString( _ string: String,
                             path: String,
                             handlers: Handlers) -> () {
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            handlers.on(Completion.failureStateFromError(error))
            return
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.writeString(string, path: path, handler: handlers.composedHandler())
        } else {
            handlers.on(Completion.failureState("Error connecting XPC", statusCode: .undefined))
        }
    }

    /**
     Determines if a file or a directory exists.

     - parameter path:     the path
     - parameter handlers: the handlers

     - returns:  N/A
     */
    open func itemExistsAtPath(_ path: String,
                                 handlers: Handlers) -> () {

        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            handlers.on(Completion.failureStateFromError(error))
            return
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.itemExistsAtPath(path, handler: handlers.composedHandler())
        } else {
            handlers.on(Completion.failureState("Error connecting XPC", statusCode: .undefined))
        }
    }

    /**
     Determines if a file exists.

     - parameter path:     the path
     - parameter handlers:            the progress and completion handlers

     - returns:  N/A
     */
    open func fileExistsAtPath(_ path: String,
                                 handlers: Handlers) -> () {

        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            handlers.on(Completion.failureStateFromError(error))
            return
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.fileExistsAtPath(path, handler: handlers.composedHandler())
        } else {
            handlers.on(Completion.failureState("Error connecting XPC", statusCode: .undefined))
        }

    }

    /**
     Determines if a directory exists.

     - parameter path:     the path
     - parameter handlers:            the progress and completion handlers

     - returns:  N/A
     */
    open func directoryExistsAtPath(_ path: String,
                                      handlers: Handlers) -> () {

        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            handlers.on(Completion.failureStateFromError(error))
            return
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.directoryExistsAtPath(path, handler: handlers.composedHandler())
        } else {
            handlers.on(Completion.failureState("Error connecting XPC", statusCode: .undefined))
        }
    }


    /**
     Removes the item at a given path
     Use with caution !

     - parameter path:     path
     - parameter handlers:            the progress and completion handlers
     */
    open func removeItemAtPath(_ path: String,
                                 handlers: Handlers) -> () {
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            handlers.on(Completion.failureStateFromError(error))
            return
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.removeItemAtPath(path, handler: handlers.composedHandler())
        } else {
            handlers.on(Completion.failureState("Error connecting XPC", statusCode: .undefined))
        }
    }


    /**
     Copies the file

     - parameter srcPath:  srcPath
     - parameter dstPath:  dstPath
     - parameter handlers:            the progress and completion handlers

     - returns: N/A
     */
    open func copyItemAtPath(_ srcPath: String,
                               toPath dstPath: String,
                                      handlers: Handlers) -> () {
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            handlers.on(Completion.failureStateFromError(error))
            return
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.copyItemAtPath(srcPath, toPath:dstPath, handler: handlers.composedHandler())
        } else {
            handlers.on(Completion.failureState("Error connecting XPC", statusCode: .undefined))
        }
    }

    /**
     Moves the file

     - parameter srcPath:  srcPath
     - parameter dstPath:  dstPath
     - parameter handlers:            the progress and completion handlers

     - returns: N/A
     */
    open func moveItemAtPath(_ srcPath: String,
                               toPath dstPath: String,
                                      handlers: Handlers) -> () {
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            handlers.on(Completion.failureStateFromError(error))
            return
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.moveItemAtPath(srcPath, toPath: dstPath, handler: handlers.composedHandler())
        } else {
            handlers.on(Completion.failureState("Error connecting XPC", statusCode: .undefined))
        }
    }


    /**
     Lists the content of the directory

     - parameter path:     the path
     - parameter handlers:            the progress and completion handlers

     - returns: N/A
     */
    open func contentsOfDirectoryAtPath(_ path: String,
                                          handlers: Handlers) -> () {
        let remoteObjectProxy=bsyncConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
            handlers.on(Completion.failureStateFromError(error))
            return
        }
        if let xpc = remoteObjectProxy as? BsyncXPCProtocol {
            xpc.contentsOfDirectoryAtPath(path, handler: handlers.composedHandler())
        } else {
            handlers.on(Completion.failureState("Error connecting XPC", statusCode: .undefined))
        }
    }
}
