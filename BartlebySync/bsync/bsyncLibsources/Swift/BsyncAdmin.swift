//
//  BsyncAdmin.swift
//  Bartleby's Sync client aka "bsync"
//
//
//  Created by Benoit Pereira da silva on 26/12/2015.
//  Copyright © 2015 Benoit Pereira da silva. All rights reserved.
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
    import BartlebyKit
#endif


public enum BsyncAdminError: Error {
    case hashMapViewError(explanations:String)
    case deserializationError
    case serializationError
    case directivesError(explanations:String)
}

// Port to swift 2.0 is in progress
// so we bridge most of the calls to a PdSSyncAdmin
// And implement new functionalities directly in swift.
@objc open class BsyncAdmin: NSObject, PdSSyncFinalizationDelegate {

    // MARK: - Synchronisation


    /**
     Cleanup the hashmap, session, snapshots, directive and sys folders.

     - parameter folderPath: the folder path
     */
    open static func cleanupFolder(_ folderPath: String)throws->[String] {
        // TODO @md Implementation required (Clarification with bpds may be required)
        let messages=[String]()
        return messages
    }

    /**
     The synchronization method

     - parameter context:   the synchronization context
     - parameter handlers: the progress and completion handlers
     */
    open func synchronizeWithprogressBlock(_ context: BsyncContext, handlers: Handlers) {
        let admin = PdSSyncAdmin(context:context)
        admin.finalizationDelegate = self
        admin.synchronizeWithprogressBlock({(taskIndex, totalTaskCount, taskProgress, message, data) in
            handlers.notify(Progression(currentTaskIndex:taskIndex, totalTaskCount: totalTaskCount, currentPercentProgress: taskProgress, message: message, data: data))
            }, andCompletionBlock: {(success, statusCode, message) in
                let c = Completion()
                c.success = success
                // TODO: @md #bsync Use StatusOfCompletion  in PdsSync
                c.statusCode = statusCode
                c.message = message
                handlers.on(c)
        })
    }


    //MARK: - HashMapView

    /**
     Creates an hashMapView file.
     A hashMapview is a normal synchronizable file.

     IMPORTANT : bartleby needs to configured
     The hash map view is a crypted file that will fail if the secret key and Salt is not set.


     - parameter hashMap:         the hashMap that contains only the files to be included in the view
     - parameter hashMapViewName: the hashMapViewName
     - parameter treeFolderPath:  the tree folderPath
     */
    open static func createAHashMapViewFrom(_ hashMap: HashMap, hashMapViewName: String, treeFolderPath: String) throws {
        let fs=FileManager.default
        var isDirectory: ObjCBool = false
        guard fs.fileExists(atPath: treeFolderPath, isDirectory: &isDirectory) else {
            throw BsyncAdminError.hashMapViewError(explanations: "Directory \(treeFolderPath) does not exit")
        }
        let prefix=PdSSyncAdmin.value(forConst: "kBsyncHashmapViewPrefixSignature")
        let hashmapviewPath=treeFolderPath+prefix!+hashMapViewName
        do {
            let dictionary=hashMap.dictionaryRepresentation()
            let data=try JSONSerialization.data(withJSONObject: dictionary, options: [])
            guard let string: NSString=NSString.init(data: data, encoding: Default.STRING_ENCODING.rawValue) else {
                throw BsyncAdminError.hashMapViewError(explanations: "Data encoding as failed")
            }
            let crypted=try Bartleby.cryptoDelegate.encryptString(string as String)
            try crypted.write(toFile: hashmapviewPath, atomically: true, encoding: Default.STRING_ENCODING)
        }
    }

    /**
     Returns the url of a hashMapView File

     - parameter hashMapViewName: the name of hash map view
     - parameter treeFolderURL:   the tree folder url (without the trailing /)

     - returns: the url of the hashMapView File
     */
    open static func hashMapViewURL(_ hashMapViewName: String, treeFolderURL: URL) -> URL {
        let prefix=PdSSyncAdmin.value(forConst: "kBsyncHashmapViewPrefixSignature")!
        return treeFolderURL.appendingPathComponent("/"+prefix+hashMapViewName)
    }


    // MARK: - Advanced Actions

    /**
     *  Proceed to installation of the Repository
     *
     *  @param content the syncrhonization context
     *  @param handlers   the progress and completion handlers
     */
    open func installWithCompletionBlock(_ context: BsyncContext, handlers: Handlers) {
        let admin = PdSSyncAdmin(context: context)
        admin.install { (success, message, statusCode) in
            let completion = Completion.defaultState()
            completion.success = success
            completion.message = message
            completion.statusCode = statusCode
            handlers.on(completion)
        }
    }


    /**
     *  Creates a tree
     *
     *  @param content the syncrhonization context
     *  @param handlers   the progress and completion handlers
     */
    open func createTreesWithCompletionBlock(_ context: BsyncContext, handlers: Handlers) {
        let admin = PdSSyncAdmin(context: context)
        admin.createTrees { (success, message, statusCode) in
            let completion = Completion.defaultState()
            completion.success = success
            completion.message = message
            completion.statusCode = statusCode
            handlers.on(completion)
        }
    }

    /**
     *  Touches the trees (changes the public ID )
     *
     *  @param content the syncrhonization context
     *  @param handlers   the progress and completion handlers
     */
    open func touchTreesWithCompletionBlock(_ context: BsyncContext, handlers: Handlers) {
        let admin = PdSSyncAdmin(context: context)
        admin.touchTrees { (success, message, statusCode) in
            let completion = Completion.defaultState()
            completion.success = success
            completion.message = message
            completion.statusCode = statusCode
            handlers.on(completion)

        }
    }


    //MARK : PdSSyncFinalizationDelegate

    @objc open func ready(forFinalization reference: PdSCommandInterpreter!) {
        reference.finalize()
    }


    @objc open func progressMessage(_ message: String!) {
        print(message)
    }

    // MARK: Directives

    /**
     Load directives from file

     */
    open func loadDirectives(_ path: String) throws -> BsyncDirectives {
        // Load the directives
        var JSONString="{}"
        // If the file is named .json the file is deleted.
        // TODO: @bpds @md #io Using BFileManager with handlers is not very comod here...
        JSONString = try NSString(contentsOfFile: path, encoding: Default.STRING_ENCODING.rawValue) as String
        // TODO: @bpds @md #crypto Since we already crypt json content, do we need to encrypt again directives? (currently not symetric btw
        //        JSONString = try Bartleby.cryptoDelegate.decryptString(JSONString as String)

        if let directives: BsyncDirectives = Mapper<BsyncDirectives>().map(JSONString:JSONString) {
            return directives
        } else {
            throw BsyncAdminError.deserializationError
        }

    }
    /**

     Save directives.

     - parameter directive: the synchronization directive
     - parameter fileURL: the folder URL

     - throws: Explanation is something wrong happened
     */
    open func saveDirectives(_ directives: BsyncDirectives, path: String) throws {
        let result = directives.areValid()
        if result.valid {
            if let jsonString = Mapper().toJSONString(directives) {
                try jsonString.write(toFile: path, atomically: true, encoding: Default.STRING_ENCODING)
            } else {
                throw BsyncAdminError.serializationError
            }
        } else {
            throw BsyncAdminError.directivesError(explanations: result.message)
        }
    }

    /**
     Run the directives

     - parameter filePath:   the directives filePath
     - parameter sharedSalt: the shared salt
     - parameter handlers:    verbose or not
     */


    func runDirectives(_ directives: BsyncDirectives, sharedSalt: String, handlers: Handlers) {

        let validity=directives.areValid()

        if let sourceURL = directives.sourceURL, let destinationURL = directives.destinationURL , validity.valid {

            // Before to Proceed to hash.
            // We need to determine what ?
            // The source or the destination ?

            // Syncronization context
            let context = BsyncContext(
                sourceURL: sourceURL,
                andDestinationUrl: destinationURL,
                restrictedTo: directives.hashMapViewName,
                autoCreateTrees: directives.automaticTreeCreation
            )

            context.credentials=BsyncCredentials()
            context.credentials?.user = directives.user
            context.credentials?.password = directives.password
            context.credentials?.salt = sharedSalt

            if directives.computeTheHashMap {

                let analyzer = BsyncLocalAnalyzer()

                switch context.mode() {
                case BsyncMode.SourceIsLocalDestinationIsDistant:
                    let sourcePath = sourceURL.path
                    analyzer.createHashMapFromLocalPath(sourcePath, handlers: Handlers(completionHandler: { (result) in
                        if result.success {
                            self.synchronize(context, handlers: handlers)
                        } else {
                            handlers.on(result)
                        }
                        }, progressionHandler: handlers.notify))

                case BsyncMode.SourceIsDistantDestinationIsLocal:
                    let destinationPath = destinationURL.path
                    analyzer.createHashMapFromLocalPath(destinationPath, handlers: Handlers { (result) in
                        if result.success {
                            self.synchronize(context, handlers: handlers)
                        } else {
                            handlers.on(result)
                        }
                    })

                case BsyncMode.SourceIsLocalDestinationIsLocal:
                    let sourcePath = sourceURL.path
                    let destinationPath = destinationURL.path
                    analyzer.createHashMapFromLocalPath(sourcePath, handlers: Handlers { (result) in
                        if result.success {
                            analyzer.createHashMapFromLocalPath(destinationPath, handlers: Handlers { (result) in
                                if result.success {
                                    self.synchronize(context, handlers: handlers)
                                } else {
                                    handlers.on(result)
                                }
                            })
                        } else {
                            handlers.on(result)
                        }
                    })

                default:
                    handlers.on(Completion.failureState("Unsupported mode \(context.mode())", statusCode: .bad_Request))
                }
            } else {
                // There is no need to compute
                // Run the synchro directly
                synchronize(context, handlers: handlers)
            }
        } else {
            handlers.on(Completion.failureState(validity.message, statusCode: .bad_Request))
        }

    }

    /**
     The synchronization implementation

     - parameter context:      the synchronization context
     - parameter handlers: the progress and completion handlers

     

     */
    func synchronize(_ context: BsyncContext, handlers: Handlers) {
        if (context.mode() == BsyncMode.SourceIsLocalDestinationIsDistant) || (context.mode() == BsyncMode.SourceIsDistantDestinationIsLocal) {
            // We need to login before performing sync
            if let user = context.credentials?.user {
                user.login(sucessHandler: {
                    print ("Successful login")
                    self.synchronizeWithprogressBlock(context, handlers: handlers)
                    }, failureHandler: { (context) in
                        // Print a JSON failure description
                        handlers.on(Completion.failureStateFromHTTPContext(context))
                        return
                })
            }
        } else {
            self.synchronizeWithprogressBlock(context, handlers: handlers)
        }
        
    }
}
