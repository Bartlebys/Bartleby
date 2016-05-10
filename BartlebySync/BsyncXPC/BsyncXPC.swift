//
//  BsyncXPC.swift
//  BsyncXPC
//
//  Created by Benoit Pereira da silva on 20/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation


@objc class BsyncXPC: BFileManager, BsyncXPCProtocol {


    // MARK:- Disk Image Management

    /**

     Creates an image disk using bsync

     - parameter imageFilePath: the file path (absolute nix style)
     - parameter volumeName:    the volume name
     - parameter size:          a size e.g : "10m" = 10MB "1g"=1GB
     - parameter password:      the password (if omitted the disk image will not be crypted
     - parameter callBack:      the result of the creation

     - returns: nothing
     */
    func createImageDisk(imageFilePath: String, volumeName: String, size: String, password: String?,
                         handler: ComposedHandler) {
        print("imageFilePath \(imageFilePath)")
        let dmgManager=BsyncImageDiskManager()
        let completion = Completion.defaultState()
        do {
            completion.success = try dmgManager.createImageDisk(imageFilePath, volumeName: volumeName, size: size, password: password)
        } catch {
            completion.message = "An error has occured: \(error)"
        }
        let handlers = Handlers.handlersFrom(handler)
        handlers.on(completion)
    }

    /**
     Attaches a Volume from a Dmg path

     - parameter path:         the path
     - parameter withPassword: the password
     - parameter callBack:      the XPC callback

     - returns: return value description
     */
    func attachVolume(from path: String, withPassword: String?,
                           handler: ComposedHandler) {
        let dmgManager=BsyncImageDiskManager()
        let completion = Completion.defaultState()
        do {
            completion.success = try dmgManager.attachVolume(from: path, withPassword: withPassword)
        } catch {
            completion.message = "An error has occured: \(error)"
        }
        let handlers = Handlers.handlersFrom(handler)
        handlers.on(completion)
    }

    /**
     Attaches a Volume identified by its card

     - parameter card:         the card
     - parameter callBack:      the XPC callback


     - returns: N/A
     */
    func attachVolume(identifiedBy card: BsyncDMGCard,
                                   handler: ComposedHandler) {
        let password=card.getPasswordForDMG()
        attachVolume(from: card.imagePath, withPassword: password, handler: handler)

    }


    /**
     Detaches the volume

     - parameter named:    name of the volume
     - parameter callBack: the XPC Call back

     */
    func detachVolume(named: String,
                      handler: ComposedHandler) {
        let dmgManager=BsyncImageDiskManager()
        let completion = Completion.defaultState()
        do {
            completion.success = try dmgManager.detachVolume(named)
        } catch {
            completion.message = "An error has occured"
        }
        let handlers = Handlers.handlersFrom(handler)
        handlers.on(completion)
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
    func createDirectives(directives: BsyncDirectives, secretKey: String, sharedSalt: String, filePath: String,
                          handler: (ComposedHandler)) {

        let handlers = Handlers.handlersFrom(handler)
        // Check the validity

        let validity=directives.areValid()
        guard validity.valid else {
            var validityMessage=""
            if let explanation=validity.message {
                validityMessage="Directives are not valid : \(explanation)"
            } else {
                validityMessage="Directives are not valid"
            }
            handlers.on(Completion.failureState(validityMessage, statusCode: .Precondition_Failed))
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
                // TODO: @md Use self.writeToFile
                try JSONString.writeToFile(filePath, atomically: true, encoding: Default.TEXT_ENCODING)
            } catch {
                handlers.on(Completion.failureState("\(error)", statusCode: .Undefined))
                return
            }
            handlers.on(Completion.successState("Directives have be saved to:\(filePath)"))
        } else {
            handlers.on(Completion.failureState("Serialization failure", statusCode: .Undefined))
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
    func runDirectives(filePath: String, secretKey: String, sharedSalt: String, handler: ComposedHandler) {

        // Those handlers produce an adaptation
        // From the unique handler form
        // progress and completion handlers.
        let handlers=Handlers.handlersFrom(handler)

        let runner = BsyncDirectivesRunner()

        Bartleby.configuration.KEY=secretKey
        Bartleby.configuration.SHARED_SALT=sharedSalt
        Bartleby.configuration.API_CALL_TRACKING_IS_ENABLED=false
        Bartleby.sharedInstance.configureWith(Bartleby.configuration)

        runner.runDirectives(filePath, secretKey: secretKey, sharedSalt: sharedSalt, handlers: handlers)
    }

    // MARK: File IO
    func createDirectoryAtPath(path: String, handler: ComposedHandler) {
        self.createDirectoryAtPath(path, handlers: Handlers.handlersFrom(handler))
    }

    func readData(contentsOfFile path: String, handler: ComposedHandler) {
        self.readData(contentsOfFile: path, handlers: Handlers.handlersFrom(handler))
    }

    func writeData(data: NSData, path: String, handler: ComposedHandler) {
        self.writeData(data, path: path, handlers: Handlers.handlersFrom(handler))
    }

    func readString(contentsOfFile path: String, handler: ComposedHandler) {
        self.readString(contentsOfFile: path, handlers: Handlers.handlersFrom(handler))
    }

    func writeString(string: String, path: String, handler: ComposedHandler) {
        self.writeString(string, path: path, handlers: Handlers.handlersFrom(handler))
    }

    func itemExistsAtPath(path: String, handler: ComposedHandler) {
        self.itemExistsAtPath(path, handlers: Handlers.handlersFrom(handler))
    }

    func directoryExistsAtPath(path: String, handler: ComposedHandler) {
        self.directoryExistsAtPath(path, handlers: Handlers.handlersFrom(handler))
    }

    func fileExistsAtPath(path: String, handler: ComposedHandler) {
        self.fileExistsAtPath(path, handlers: Handlers.handlersFrom(handler))
    }

    func removeItemAtPath(path: String, handler: ComposedHandler) {
        self.removeItemAtPath(path, handlers: Handlers.handlersFrom(handler))
    }

    func copyItemAtPath(path: String, toPath: String, handler: ComposedHandler) {
        self.copyItemAtPath(path, toPath: toPath, handlers: Handlers.handlersFrom(handler))
    }

    func moveItemAtPath(path: String, toPath: String, handler: ComposedHandler) {
        self.moveItemAtPath(path, toPath: toPath, handlers: Handlers.handlersFrom(handler))
    }

    func contentsOfDirectoryAtPath(path: String, handler: ComposedHandler) {
        self.contentsOfDirectoryAtPath(path, handlers: Handlers.handlersFrom(handler))
    }

}
