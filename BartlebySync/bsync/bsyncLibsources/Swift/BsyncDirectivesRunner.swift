//
//  BsyncDirectivesRunner.swift
//  bsync
//
//  Created by Martin Delille on 22/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

class BsyncDirectivesRunner {

    /**
     Run the directives

     - parameter filePath:   the directives filePath
     - parameter secretKey:  the secret key to decrypt the directives
     - parameter sharedSalt: the shared salt
     - parameter handlers:    verbose or not
     */


    func runDirectives(filePath: String, secretKey: String, sharedSalt: String, handlers: Handlers) {
        if NSFileManager.defaultManager().fileExistsAtPath(filePath)==false {
            handlers.on(Completion.failureState("Bad directives path \(filePath)", statusCode: .Bad_Request))
            return
        }

        // Load the directives
        var JSONString="{}"
        do {
            // If the file is named .json the file is deleted.
            JSONString = try NSString(contentsOfFile: filePath, encoding: Default.STRING_ENCODING) as String
            if !BsyncCredentials.DEBUG_DISABLE_ENCRYPTION {
                JSONString = try Bartleby.cryptoDelegate.decryptString(JSONString as String)
            }
        } catch {
            handlers.on(Completion.failureState("Deserialization of directives has failed \(filePath) \(JSONString)", statusCode: .Bad_Request))
            return
        }

        if let directives: BsyncDirectives = Mapper<BsyncDirectives>().map(JSONString) {

            guard directives.sourceURL != nil else {
                handlers.on(Completion.failureState("Source URL is void", statusCode: .Bad_Request))
                return
            }


            guard directives.destinationURL != nil else {
                handlers.on(Completion.failureState("Destination URL is void", statusCode: .Bad_Request))
                return
            }

            // IMPORTANT !
            let validity=directives.areValid()
            guard validity.valid else {
                if let explanation=validity.message {
                    handlers.on(Completion.failureState("Directives are not valid : \(explanation)", statusCode: .Bad_Request))
                    return
                } else {
                    handlers.on(Completion.failureState("Directives are not valid", statusCode: .Bad_Request))
                    return
                }
            }


            func runSynchronizationCommand() {

                let hashMapviewName: String?=(directives.hashMapViewName == BsyncDirectives.NO_HASHMAPVIEW) ? nil : directives.hashMapViewName

                self.synchronize( directives.sourceURL!,
                                  destinationURL: directives.destinationURL!,
                                  hashMapViewName: hashMapviewName,
                                  user: directives.user,
                                  password: directives.password,
                                  sharedSalt: directives.salt,
                                  autoCreateTrees: directives.automaticTreeCreation,
                                  handlers: handlers)
            }



            if directives.computeTheHashMap==true {

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



                var url: NSURL?
                switch context.mode() {
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
                        if let folderPath=url!.path {

                            let fm=NSFileManager.defaultManager()
                            var isAFolder: ObjCBool = false
                            if directives.automaticTreeCreation {
                                try fm.createDirectoryAtPath(folderPath, withIntermediateDirectories: true, attributes:nil)
                            }
                            if fm.fileExistsAtPath(folderPath, isDirectory: &isAFolder) {
                                if isAFolder {
                                    Bartleby.bprint("# hash map computation #", file: #file, function: #function, line: #line)
                                    try analyzer.createHashMapFromLocalPath(folderPath,
                                                                            progressBlock: { (hash, path, index) -> Void in
                                                                                bprint("\(index) checksum of \(path) is \(hash)", file: #file, function: #function, line: #line)
                                        }, completionBlock: { (hashMap) -> Void in
                                            bprint("# End of hash map computation#", file: #file, function: #function, line: #line)
                                            runSynchronizationCommand()
                                    })
                                } else {
                                    handlers.on(Completion.failureState("\(folderPath) is not a directory", statusCode: .Bad_Request))
                                    return
                                }
                            } else {
                                handlers.on(Completion.failureState("Unexisting folder path: \(folderPath)", statusCode: .Bad_Request))
                                return
                            }

                        } else {
                            handlers.on(Completion.failureState("Url to filtered path error: \(url)", statusCode: .Bad_Request))
                            return
                        }
                    } catch BsyncLocalAnalyzerError.InvalidURL(let explanations) {
                        handlers.on(Completion.failureState(explanations, statusCode: .Bad_Request))
                        return
                    } catch {
                        handlers.on(Completion.failureState("Unexpected error \(error)", statusCode: .Bad_Request))
                        return
                    }
                } else {
                    handlers.on(Completion.failureState("Unsupported mode \(context.mode())", statusCode: .Bad_Request))
                    return
                }

            } else {
                // There is no need to compute
                // Run the synchro directly
                runSynchronizationCommand()
            }
        }

    }

    /**
     The synchronization implementation

     - parameter sourceURL:       the sourceURL
     - parameter destinationURL:  the destinationURL
     - parameter hashMapViewName: hashMapViewName
     - parameter user:            the user
     - parameter password:        password
     - parameter sharedSalt:      sharedSalt
     - parameter verbose :        verbose or not
     - parameter autoCreateTrees: autoCreateTrees or not


     */
    func synchronize( sourceURL: NSURL,
                      destinationURL: NSURL,
                      hashMapViewName: String?,
                      user: User?,
                      password: String?,
                      sharedSalt: String?,
                      autoCreateTrees: Bool=false,
                      handlers: Handlers
        ) {

        // Syncronization context

        let context=BsyncContext(   sourceURL: sourceURL,
                                    andDestinationUrl: destinationURL,
                                    restrictedTo: hashMapViewName,
                                    autoCreateTrees:autoCreateTrees
        )

        context.credentials=BsyncCredentials()
        context.credentials?.user=user
        context.credentials?.salt=sharedSalt
        context.credentials?.password=password

        var url: NSURL?
        switch context.mode() {
        case BsyncMode.SourceIsDistantDestinationIsLocal:
            url=sourceURL
        case BsyncMode.SourceIsLocalDestinationIsDistant:
            url=destinationURL
        default:
            url=nil
        }
        // If there is an url let's determine the API base url.
        // it should be before baseAPI_URL/BartlebySync/tree/...
        // eg.: http://yd.local/api/v1/BartlebySync/tree/nameOfTree/

        if var stringURL=url?.absoluteString {
            let r=stringURL.rangeOfString("/BartlebySync")
            if let foundIndex=r?.startIndex {
                // extract the base URL
                url=NSURL(string: stringURL.substringToIndex(foundIndex))
            }
        }

        // Synchronization handler
        func doSync() {

            let admin: BsyncAdmin=BsyncAdmin(context:context)
            admin.synchronizeWithprogressBlock(handlers)
        }

        if (context.mode() == BsyncMode.SourceIsLocalDestinationIsDistant) || (context.mode() == BsyncMode.SourceIsDistantDestinationIsLocal) {
            // We need to login before performing sync
            if let user = user, let password = password {

                LoginUser.execute(user, withPassword: password, sucessHandler: {
                    print ("Successful login")
                    doSync()
                    }, failureHandler: { (context) in
                        // Print a JSON failure description
                        handlers.on(Completion.failureStateFromJHTTPResponse(context))
                        return
                })
            }
        } else {
            doSync()
        }

    }

}
