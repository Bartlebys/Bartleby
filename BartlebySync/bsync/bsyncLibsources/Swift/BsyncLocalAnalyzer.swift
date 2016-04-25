//
//  BsyncLocalAnalyzer.swift
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

// Port to swift 2.0 is in progress 
// so we bridge the calls to a PdSLocalAnalyzer
// And implement new functionalities directly in swift.
// We try to simplify BsyncLocalAnalyzer offers a reduced api
public enum BsyncLocalAnalyzerError:ErrorType{
    case InvalidURL(explanations:String)
}

public struct BsyncLocalAnalyzer {
    
    /// Used if saveHashInAFile=true to determinate if the hash should be recomputed even if there is a hash file
    var recomputeHash=false
    
    /// if set to true we use one hash file for each file.
    var saveHashInAFile=false
    
    private lazy var _localAnalyzer:PdSLocalAnalyzer=PdSLocalAnalyzer()
    
    
    mutating public func createHashMapFromLocalPath(folderPath:String, progressBlock: ((hash:String, path:String, index:UInt) -> Void)?, completionBlock: (hashMap:HashMap) -> Void) throws{
        
        guard NSFileManager.defaultManager().fileExistsAtPath(folderPath) else{
            throw BsyncLocalAnalyzerError.InvalidURL(explanations: "Attempt to create an HashMap has failed. \nUnexisting folderPath \(folderPath)")
        }
        
       let folderURL=NSURL(fileURLWithPath: folderPath, isDirectory:true)
        self._localAnalyzer.recomputeHash=self.recomputeHash
        self._localAnalyzer.saveHashInAFile=self.saveHashInAFile
        self._localAnalyzer.createHashMapFromLocalFolderURL(folderURL, dataBlock: nil, progressBlock: progressBlock, andCompletionBlock: completionBlock)
    }
    
    
    
}