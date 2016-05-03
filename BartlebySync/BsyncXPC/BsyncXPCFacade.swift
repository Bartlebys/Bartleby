//
//  BsyncXPCFacade.swift
//  BsyncXPC
//
//  Created by Benoit Pereira da silva on 20/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation


@objc(BsyncXPCFacade) class BsyncXPCFacade: BFileManager, BsyncXPCProtocol {


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
                         callBack: (CompletionHandler))->() {
        print("imageFilePath \(imageFilePath)")
        let dmgManager=BsyncImageDiskManager()
        let completion = Completion.defaultState()
        do {
            completion.success = try dmgManager.createImageDisk(imageFilePath, volumeName: volumeName, size: size, password: password)
        } catch {
            completion.message = "An error has occured"
        }
        // TODO: @md Use progress and completion handler
        callBack(completion)
    }

    /**
     Attaches a Volume from a Dmg path

     - parameter path:         the path
     - parameter withPassword: the password
     - parameter callBack:      the XPC callback

     - returns: return value description
     */
    func attachVolume(from path: String, withPassword: String?,
                           callBack: (CompletionHandler))->() {
        let dmgManager=BsyncImageDiskManager()
        let completion = Completion.defaultState()
        do {
            completion.success = try dmgManager.attachVolume(from: path, withPassword: withPassword)
        } catch {
            completion.message = "An error has occured"
        }
        // TODO: @md Use progress and completion handler
        callBack(completion)
    }

    /**
     Attaches a Volume identified by its card

     - parameter card:         the card
     - parameter callBack:      the XPC callback


     - returns: N/A
     */
    func attachVolume(identifiedBy card: BsyncDMGCard,
                                   callBack: (CompletionHandler))->() {
        let password=card.getPasswordForDMG()
        self.attachVolume(from: card.imagePath, withPassword: password, callBack:callBack)

    }


    /**
     Detaches the volume

     - parameter named:    name of the volume
     - parameter callBack: the XPC Call back

     */
    func detachVolume(named: String,
                      callBack: (CompletionHandler))->() {
        let dmgManager=BsyncImageDiskManager()
        let completion = Completion.defaultState()
        do {
            completion.success = try dmgManager.detachVolume(named)
        } catch {
            completion.message = "An error has occured"
        }
        // TODO: @md Use progress and completion handler
        callBack(completion)
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
                          callBack: (CompletionHandler))->() {

        // Check the validity

        let validity=directives.areValid()
        guard validity.valid else {
            var validityMessage=""
            if let explanation=validity.message {
                validityMessage="Directives are not valid : \(explanation)"
            } else {
                validityMessage="Directives are not valid"
            }
            callBack(Completion.failureState(validityMessage, statusCode: .Precondition_Failed))
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
                try JSONString.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
            } catch {
                callBack(Completion.failureState("\(error)", statusCode: .Undefined))
                return
            }
            callBack(Completion.successState("Directives have be saved to:\(filePath)"))
        } else {
            callBack(Completion.failureState("Serialization failure", statusCode: .Undefined))
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
    func runDirectives(filePath: String, secretKey: String, sharedSalt: String, handler: ComposedProgressAndCompletionHandler)->() {

        // Those handlers produce an adaptation
        // From the unique handler form
        // progress and completion handlers.
        let handlers=ProgressAndCompletionHandler.handlersFrom(handler)

        let runner = BsyncDirectivesRunner()

        Bartleby.configuration.KEY=secretKey
        Bartleby.configuration.SHARED_SALT=sharedSalt
        Bartleby.configuration.API_CALL_TRACKING_IS_ENABLED=false
        Bartleby.sharedInstance.configureWith(Bartleby.configuration)

        runner.runDirectives(filePath, secretKey: secretKey, sharedSalt: sharedSalt, handlers: handlers)
    }
}
