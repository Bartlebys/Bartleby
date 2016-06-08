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


public enum BsyncAdminError: ErrorType {
    case HashMapViewError(explanations:String)
    case DeserializationError
    case SerializationError
    case DirectivesError(explanations:String)
}

// Port to swift 2.0 is in progress
// so we bridge most of the calls to a PdSSyncAdmin
// And implement new functionalities directly in swift.
@objc public class BsyncAdmin: NSObject, PdSSyncFinalizationDelegate {

    // MARK: - Synchronisation


    /**
     Cleanup the hashmap, session, snapshots, directive and sys folders.

     - parameter folderPath: the folder path
     */
    public static func cleanupFolder(folderPath: String)throws->[String] {
        // TODO @md Implementation required (Clarification with bpds may be required)
        let messages=[String]()
        return messages
    }

    /**
     The synchronization method

     - parameter context:   the synchronization context
     - parameter handlers: the progress and completion handlers
     */
    public func synchronizeWithprogressBlock(context: BsyncContext, handlers: Handlers) {
        let admin = PdSSyncAdmin(context:context)
        admin.finalizationDelegate = self
        admin.synchronizeWithprogressBlock({(taskIndex, totalTaskCount, taskProgress, message, data) in
            handlers.notify(Progression(currentTaskIndex:taskIndex, totalTaskCount: totalTaskCount, currentTaskProgress: taskProgress, message: message, data: data))
            }, andCompletionBlock: {(success, statusCode, message) in
                let c = Completion()
                c.success = success
                // TODO: @md #bsync Use CompletionStatus in PdsSync
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
    public static func createAHashMapViewFrom(hashMap: HashMap, hashMapViewName: String, treeFolderPath: String) throws {
        let fs=NSFileManager.defaultManager()
        var isDirectory: ObjCBool = false
        guard fs.fileExistsAtPath(treeFolderPath, isDirectory: &isDirectory) else {
            throw BsyncAdminError.HashMapViewError(explanations: "Directory \(treeFolderPath) does not exit")
        }
        let prefix=PdSSyncAdmin.valueForConst("kBsyncHashmapViewPrefixSignature")
        let hashmapviewPath=treeFolderPath+prefix!+hashMapViewName
        do {
            let dictionary=hashMap.dictionaryRepresentation()
            let data=try NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
            guard let string: NSString=NSString.init(data: data, encoding: Default.STRING_ENCODING) else {
                throw BsyncAdminError.HashMapViewError(explanations: "Data encoding as failed")
            }
            let crypted: NSString=try Bartleby.cryptoDelegate.encryptString(string as String)
            try crypted.writeToFile(hashmapviewPath, atomically: true, encoding: Default.STRING_ENCODING)
        }
    }

    /**
     Returns the url of a hashMapView File

     - parameter hashMapViewName: the name of hash map view
     - parameter treeFolderURL:   the tree folder url (without the trailing /)

     - returns: the url of the hashMapView File
     */
    public static func hashMapViewURL(hashMapViewName: String, treeFolderURL: NSURL) -> NSURL {
        let prefix=PdSSyncAdmin.valueForConst("kBsyncHashmapViewPrefixSignature")!
        return treeFolderURL.URLByAppendingPathComponent("/"+prefix+hashMapViewName)
    }


    // MARK: - Advanced Actions

    /**
     *  Proceed to installation of the Repository
     *
     *  @param content the syncrhonization context
     *  @param handlers   the progress and completion handlers
     */
    public func installWithCompletionBlock(context: BsyncContext, handlers: Handlers) {
        let admin = PdSSyncAdmin(context: context)
        admin.installWithCompletionBlock { (success, message, statusCode) in
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
    public func createTreesWithCompletionBlock(context: BsyncContext, handlers: Handlers) {
        let admin = PdSSyncAdmin(context: context)
        admin.createTreesWithCompletionBlock { (success, message, statusCode) in
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
    public func touchTreesWithCompletionBlock(context: BsyncContext, handlers: Handlers) {
        let admin = PdSSyncAdmin(context: context)
        admin.touchTreesWithCompletionBlock { (success, message, statusCode) in
            let completion = Completion.defaultState()
            completion.success = success
            completion.message = message
            completion.statusCode = statusCode
            handlers.on(completion)

        }
    }


    //MARK : PdSSyncFinalizationDelegate

    @objc public func readyForFinalization(reference: PdSCommandInterpreter!) {
        reference.finalize()
    }


    @objc public func progressMessage(message: String!) {
        print(message)
    }

    // MARK: Directives

    /**
     Load directives from file

     */
    public func loadDirectives(path: String) throws -> BsyncDirectives {
        // Load the directives
        var JSONString="{}"
        // If the file is named .json the file is deleted.
        // TODO: @bpds @md #io Using BFileManager with handlers is not very comod here...
        JSONString = try NSString(contentsOfFile: path, encoding: Default.STRING_ENCODING) as String
        // TODO: @bpds @md #crypto Since we already crypt json content, do we need to encrypt again directives? (currently not symetric btw
        //        JSONString = try Bartleby.cryptoDelegate.decryptString(JSONString as String)

        if let directives: BsyncDirectives = Mapper<BsyncDirectives>().map(JSONString) {
            return directives
        } else {
            throw BsyncAdminError.DeserializationError
        }

    }
    /**

     Save directives.

     - parameter directive: the synchronization directive
     - parameter fileURL: the folder URL

     - throws: Explanation is something wrong happened
     */
    public func saveDirectives(directives: BsyncDirectives, path: String) throws {
        let result = directives.areValid()
        if result.valid {
            if let jsonString = Mapper().toJSONString(directives) {
                try jsonString.writeToFile(path, atomically: true, encoding: Default.STRING_ENCODING)
            } else {
                throw BsyncAdminError.SerializationError
            }
        } else {
            throw BsyncAdminError.DirectivesError(explanations: result.message)
        }
    }

    /**
     Run the directives

     - parameter filePath:   the directives filePath
     - parameter sharedSalt: the shared salt
     - parameter handlers:    verbose or not
     */


    func runDirectives(directives: BsyncDirectives, sharedSalt: String, handlers: Handlers) {

        let validity=directives.areValid()

        if let sourceURL = directives.sourceURL, let destinationURL = directives.destinationURL where validity.valid {

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

                var analyzer = BsyncLocalAnalyzer()

                switch context.mode() {
                case BsyncMode.SourceIsLocalDestinationIsDistant:
                    if let sourcePath = sourceURL.path {
                        analyzer.createHashMapFromLocalPath(sourcePath, handlers: Handlers(completionHandler: { (result) in
                            if result.success {
                                self.synchronize(context, handlers: handlers)
                            } else {
                                handlers.on(result)
                            }
                            }, progressionHandler: handlers.notify))
                    } else {
                        handlers.on(Completion.failureState("Bad source URL: \(sourceURL)", statusCode: .Bad_Request))
                    }
                case BsyncMode.SourceIsDistantDestinationIsLocal:
                    if let destinationPath = destinationURL.path {
                        analyzer.createHashMapFromLocalPath(destinationPath, handlers: Handlers { (result) in
                            if result.success {
                                self.synchronize(context, handlers: handlers)
                            } else {
                                handlers.on(result)
                            }
                            })
                    } else {
                        handlers.on(Completion.failureState("Bad destination URL: \(destinationURL)", statusCode: .Bad_Request))
                    }
                case BsyncMode.SourceIsLocalDestinationIsLocal:
                    if let sourcePath = sourceURL.path, let destinationPath = destinationURL.path {
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
                    } else {
                        handlers.on(Completion.failureState("Bad source or destination URL: \(sourceURL) /  \(destinationURL)", statusCode: .Bad_Request))
                    }
                default:
                    handlers.on(Completion.failureState("Unsupported mode \(context.mode())", statusCode: .Bad_Request))
                }
            } else {
                // There is no need to compute
                // Run the synchro directly
                synchronize(context, handlers: handlers)
            }
        } else {
            handlers.on(Completion.failureState(validity.message, statusCode: .Bad_Request))
        }

    }

    /**
     The synchronization implementation

     - parameter context:      the synchronization context
     - parameter handlers: the progress and completion handlers


     */
    func synchronize(context: BsyncContext, handlers: Handlers) {
        if (context.mode() == BsyncMode.SourceIsLocalDestinationIsDistant) || (context.mode() == BsyncMode.SourceIsDistantDestinationIsLocal) {
            // We need to login before performing sync
            if let user = context.credentials?.user, let password = context.credentials?.password {

                LoginUser.execute(user, withPassword: password, sucessHandler: {
                    print ("Successful login")
                    self.synchronizeWithprogressBlock(context, handlers: handlers)
                    }, failureHandler: { (context) in
                        // Print a JSON failure description
                        handlers.on(Completion.failureStateFromJHTTPResponse(context))
                        return
                })
            }
        } else {
            self.synchronizeWithprogressBlock(context, handlers: handlers)
        }

    }
}
