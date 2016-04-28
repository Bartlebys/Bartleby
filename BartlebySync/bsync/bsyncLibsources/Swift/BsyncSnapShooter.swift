//
//  BsyncSnapShooter.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 06/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
    import BartlebyKit
#endif

public enum BsyncSnapShooterError:ErrorType{
    case InvalidPath(explanations:String)
}

// TODO: @bpds implement a delta snapshot algo.
// We could use a local delta sync

/**
 *  The snap shooter
 *  generates and recovers from snapshots.
 *  the snap shooter does not currently perform using a delta algorythm.
 *  It generates a hashmap is used by the delta synchronization engine during distribution.
 */
struct BsyncSnapShooter{

    static var chunkSize:Int=1024*1024 // 1MB
    
    /**
    A snapshot is global
    
    - parameter source:        the source path
    - parameter secretKey:      the optionnal crypt key if not set the chunks are crypted using a default key
    - parameter progressBlock: the progress block
    
    - throws: throws contextualized errors.
    */
    func createSnapshotFromPath(source:String,secretKey:String?,
        progressBlock: ((taskIndex:uint, progress:Float,filePath:String,chunkPath:String, message:String?) -> Void)?) throws ->(){
            // Preflight check
            guard _pathIsValid(source) else{
                throw BsyncSnapShooterError.InvalidPath(explanations: "Attempt to create a snapshot has failed because \(source) is not a valid path")
            }
            // A snapshot is global
    }
    

    /**
     A snapshot recovery is global
     
     - parameter source:        the snapshot path
     - parameter destination:   the destination path
     - parameter secretKey:      the optionnal crypt key if not set the chunks are crypted using a default key
     - parameter progressBlock: the progress block
     
     - throws: throws contextualized errors.
     */
    func recoverSnapshotForPath(source:String,destination:String,secretKey:String?,progressBlock: ((taskIndex:uint, progress:Float,filePath:String,chunkPath:String, message:String?) -> Void)?)throws->(){
        // Preflight check
        guard _pathIsValid(source) else{
            throw BsyncSnapShooterError.InvalidPath(explanations: "Attempt to create a snapshot has failed because the source path \(source) is not a valid path")
        }
        guard _pathIsValid(destination) else{
            throw BsyncSnapShooterError.InvalidPath(explanations: "Attempt to create a snapshot has failed because the destination path \(destination) is not a valid path")
        }
        // A recovery is global
    }
    
    
    
    
    // MARK:- Private implementation
    
    /**
     For each file we create a folder with its chunk named from 0 to n
     
     - parameter filePath:      the source file path
     - parameter secretKey:      the optionnal crypt key if not set the chunks are crypted using a default key
     - parameter progressBlock: the progress block
     
     - throws: throws contextualized errors.
     */
    private func _createChunksFromFilePath(filePath:String,secretKey:String?,
        progressBlock: ((taskIndex:uint, progress:Float,filePath:String,chunkPath:String, message:String?) -> Void)?) throws ->(){
            
    }
    
    
    /**
     Recovers a single file from its chunks
     
     - parameter source:        the chunks folder
     - parameter destination:   the file destination
     - parameter secretKey:       the optionnal crypt key if not set the chunks are crypted using a default key
     - parameter progressBlock: the progress block
     */
    private func _recoverFile(source:String,destination:String,secretKey:String?,progressBlock: ((taskIndex:uint, progress:Float,filePath:String,chunkPath:String, message:String?) -> Void)?)throws->(){
    }
    
    /**
     Determines if a path is valid or not
     
     - parameter path: the path
     
     - returns: its validaty
     */
    private func _pathIsValid(path:String)->Bool{
        return true
    }


}