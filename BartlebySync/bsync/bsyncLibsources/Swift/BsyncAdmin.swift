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
}

// Port to swift 2.0 is in progress
// so we bridge most of the calls to a PdSSyncAdmin
// And implement new functionalities directly in swift.
@objc public class BsyncAdmin: NSObject, PdSSyncFinalizationDelegate {

    // The bridged Sync Admin
    private var _admin: PdSSyncAdmin?

    init(context: BsyncContext) {
        super.init()
        _admin=PdSSyncAdmin(context: context)
        _admin?.finalizationDelegate=self
    }

    // MARK: - Synchronisation


    /**
     Cleanup the hashmap, session, snapshots, directive and sys folders.

     - parameter folderPath: the folder path
     */
    public static func cleanupFolder(folderPath: String)throws->[String] {
        // TODO Implementation required
        let messages=[String]()
        return messages
    }

    /**
     The synchronization method

     - parameter progressBlock:   its progress block
     - parameter completionBlock: its completion block
     */
    public func synchronizeWithprogressBlock(handler: Handlers) {
        if let admin=self._admin {
            admin.synchronizeWithprogressBlock({(taskIndex, totalTaskCount, taskProgress, message, data) in
                handler.notify(Progression(currentTaskIndex:taskIndex, totalTaskCount: totalTaskCount, currentTaskProgress: taskProgress, message: message, data: data))
                }, andCompletionBlock: {(success, statusCode, message) in
                    let c = Completion()
                    c.success = success
                    // TODO: @md #bsync Use CompletionStatus in PdsSync
                    c.statusCode = statusCode
                    c.message = message
                    handler.on(c)
            })
        } else {
            handler.on(Completion.failureState("Unexisting PdsSyncAdmin", statusCode: .Precondition_Failed))
        }
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
    public static func hashMapViewURL(hashMapViewName: String, treeFolderURL: NSURL)->NSURL {
        let prefix=PdSSyncAdmin.valueForConst("kBsyncHashmapViewPrefixSignature")!
        return treeFolderURL.URLByAppendingPathComponent("/"+prefix+hashMapViewName)
    }


    // MARK: - Advanced Actions

    /**
    *  Proceed to installation of the Repository
    *  @param block   the completion block
    */
    public func installWithCompletionBlock(block:(success: Bool, statusCode: Int)->()) {
        if let admin=self._admin {
            admin.installWithCompletionBlock(block)
        }
    }


    /**
    *  Creates a tree
    *  @param block      the completion block
    */
    public func createTreesWithCompletionBlock(block:(success: Bool, statusCode: Int)->()) {
        if let admin=self._admin {
            admin.createTreesWithCompletionBlock(block)
        }
    }

    /**
    *  Touches the trees (changes the public ID )
    *
    *  @param block      the completion block
    */
    public func touchTreesWithCompletionBlock(block:(success: Bool, statusCode: Int)->()) {
        if let admin=self._admin {
            admin.touchTreesWithCompletionBlock(block)
        }
    }


    //MARK : PdSSyncFinalizationDelegate

    @objc public func readyForFinalization(reference: PdSCommandInterpreter!) {
        reference.finalize()
    }


    @objc public func progressMessage(message: String!) {
        print(message)
    }
}
