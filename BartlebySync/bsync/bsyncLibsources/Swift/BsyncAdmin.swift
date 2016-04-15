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


public enum BsyncAdminError:ErrorType{
    case DirectivesAreNotValid(explanations:String)
    case UnexistingPdSyncAdmin
    case HashMapViewError(explanations:String)
}

// Port to swift 2.0 is in progress
// so we bridge most of the calls to a PdSSyncAdmin
// And implement new functionalities directly in swift.
@objc public class BsyncAdmin:NSObject,PdSSyncFinalizationDelegate{
    
    // The bridged Sync Admin
    private var _admin:PdSSyncAdmin?

    init(context: BsyncContext){
        super.init()
        _admin=PdSSyncAdmin(context: context)
        _admin?.finalizationDelegate=self;
    }
    
    // MARK: - Synchronisation

    
    /**
     Cleanup the hashmap, session, snapshots, directive and sys folders.
     
     - parameter folderPath: the folder path
     */
    public static func cleanupFolder(folderPath:String)throws->[String]{
        // TODO
        let messages=[String]()
        return messages
    }
    
    
    /**
     
     Create directives.
     
     - parameter directive: the synchronization directive
     - parameter fileURL: the folder URL
     
     - throws: Explanation is something wrong happened
     */
    public static func createDirectives(directives:BsyncDirectives,saveTo fileURL:NSURL)->(success:Bool,message:String?){
        do{
            let result=directives.areValid()
            if result.valid==false{
                if let explanations=result.message{
                    throw BsyncAdminError.DirectivesAreNotValid(explanations:explanations )
                }else{
                    throw BsyncAdminError.DirectivesAreNotValid(explanations:NSLocalizedString("Humm... That's not clear", comment: "Humm... That's not clear") )
                }
            }
            if let jsonString=Mapper().toJSONString(directives){
                do{
                    try jsonString.writeToURL(fileURL, atomically: true,encoding:NSUTF8StringEncoding)
                }catch{
                    let baseMessage=NSLocalizedString("We were not able to save the directives", comment: "We were not able to save the directives")
                    throw BsyncAdminError.DirectivesAreNotValid(explanations:"\(baseMessage)\n\(error)")
                }
            }else{
                throw BsyncAdminError.DirectivesAreNotValid(explanations:NSLocalizedString("We have encountered directives deserialization issues", comment: "We have encountered directives deserialization issues"))
            }
        }catch BsyncAdminError.DirectivesAreNotValid(let explanations) {
           return (false,explanations)
        }catch{
            return (false,"An error has occured \(error)")
        }
        return (true,nil);
    }
    
    
    /**
     The synchronization method
     
     - parameter progressBlock:   its progress block
     - parameter completionBlock: its completion block
     */
    public func synchronizeWithprogressBlock(progressBlock : ((taskIndex:Int,totalTaskCount:Int,taskProgress:Double,message:String?)->())?,
                                            completionBlock : ((success:Bool, message:String?) -> Void)) throws{
        if let admin=self._admin{
            admin.synchronizeWithprogressBlock(progressBlock, andCompletionBlock:completionBlock)
        }else{
            throw BsyncAdminError.UnexistingPdSyncAdmin
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
    public static func createAHashMapViewFrom(hashMap:HashMap, hashMapViewName:String,treeFolderPath:String) throws{
        let fs=NSFileManager.defaultManager()
        var isDirectory: ObjCBool = false
        guard fs.fileExistsAtPath(treeFolderPath, isDirectory: &isDirectory) else{
            throw BsyncAdminError.HashMapViewError(explanations: "Directory \(treeFolderPath) does not exit")
        }
        let prefix=PdSSyncAdmin.valueForConst("kBsyncHashmapViewPrefixSignature")
        let hashmapviewPath=treeFolderPath+prefix!+hashMapViewName
        do{
            let dictionary=hashMap.dictionaryRepresentation()
            let data=try NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
            guard let string:NSString=NSString.init(data: data, encoding: NSUTF8StringEncoding) else{
                throw BsyncAdminError.HashMapViewError(explanations: "Data encoding as failed")
            }
            let crypted:NSString=try Bartleby.cryptoDelegate.encryptString(string as String)
            try crypted.writeToFile(hashmapviewPath, atomically: true, encoding: NSUTF8StringEncoding)
        }
    }
    
    /**
     Returns the url of a hashMapView File
     
     - parameter hashMapViewName: the name of hash map view
     - parameter treeFolderURL:   the tree folder url (without the trailing /)
     
     - returns: the url of the hashMapView File
     */
    public static func hashMapViewURL(hashMapViewName:String,treeFolderURL:NSURL)->NSURL{
        let prefix=PdSSyncAdmin.valueForConst("kBsyncHashmapViewPrefixSignature")!
        return treeFolderURL.URLByAppendingPathComponent("/"+prefix+hashMapViewName)
    }
    
    
    // MARK: - Advanced Actions
    
    /**
    *  Proceed to installation of the Repository
    *  @param block   the completion block
    */
    public func installWithCompletionBlock(block:(success:Bool, statusCode:Int)->()){
        if let admin=self._admin{
            admin.installWithCompletionBlock(block)
        }
    }
    
    
    /**
    *  Creates a tree
    *  @param block      the completion block
    */
    public func createTreesWithCompletionBlock(block:(success:Bool, statusCode:Int)->()){
        if let admin=self._admin{
            admin.createTreesWithCompletionBlock(block)
        }
    }
    
    /**
    *  Touches the trees (changes the public ID )
    *
    *  @param block      the completion block
    */
    public func touchTreesWithCompletionBlock(block:(success:Bool, statusCode:Int)->()){
        if let admin=self._admin{
            admin.touchTreesWithCompletionBlock(block)
        }
    }
    
    
    //MARK : PdSSyncFinalizationDelegate
    
    @objc public func readyForFinalization(reference: PdSCommandInterpreter!) {
        reference.finalize();
    }
    
    
    @objc public func progressMessage(message: String!) {
        print(message);
    }

}