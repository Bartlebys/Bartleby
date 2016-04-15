//
//  BsyncSession.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 31/12/2015.
//  Copyright © 2015 Benoit Pereira da silva. All rights reserved.
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
    import BartlebyKit
#endif

public enum BsyncSessionError:ErrorType{
    case DoneCommandNotFound(encodedCommand:String)
    case SerializedSessionFileNotFound
    case NothingTodo
    case MissingSyncID
    case SerializationIssue
    case DeserializationIssue
    case UnDefined
    case UnInterruptibleMode // SourceIsDistantDestinationIsDistant is currently not interruptible
}


// The sync session insure the persistency of synchronization commands.
// It is hold by an interpreter.
@objc public class BsyncSession:NSObject,Mappable{
    
    static public let filePrefix="._"
    static public let fileExtension=".bsync_session"
    
    private var _interruptible=true
    
    private var _syncContext:BsyncContext=BsyncContext()
    private var _encodedCommands:[String]=[String]()
    private var _todo:[String]=[String]()
    private var _done:[String]=[String]()
    private var _localURL=NSURL()
    
    public var syncContext:PdSSyncContext{
        get{
            return _syncContext
        }
    }
    
    // The initial encodedCommands
    public var encodedCommands:[String]{
        get{
            return _encodedCommands
        }
    }
    
    public var todo:[String]{
        get{
            return _todo
        }
    }
    
    public var done:[String]{
        get{
            return _done
        }
    }
    
    public var localURL:NSURL{
        get{
            return _localURL
        }
    }
    
    static public func fileName(syncID:String)->String{
        return "\(BsyncSession.filePrefix)\(syncID).\(BsyncSession.fileExtension)"
    }
    
    
    public init(context:BsyncContext,encodedCommands:[String]){
        _syncContext=context
        _encodedCommands=encodedCommands
        let mode=context.mode()
        switch mode {
        case BsyncMode.SourceIsLocalDestinationIsDistant:
            _localURL=context.sourceBaseUrl
            break
        case BsyncMode.SourceIsLocalDestinationIsLocal:
            _localURL=context.sourceBaseUrl// Ambigous situation ?
            break
        case BsyncMode.SourceIsDistantDestinationIsLocal:
            _localURL=context.destinationBaseUrl
            break
        case BsyncMode.SourceIsDistantDestinationIsDistant:
            _interruptible=false
            break
        }
    }
    
    public func markCommandAsDone(encodedCommand:String) throws{
        if let idx=todo.indexOf(encodedCommand){
            _todo.removeAtIndex(idx)
            _done.append(encodedCommand)
            if todo.count==0{
                if let syncID=_syncContext.syncID{
                    let fileURL=localURL.URLByAppendingPathComponent(BsyncSession.fileName(syncID))
                    try NSFileManager.defaultManager().removeItemAtURL(fileURL)
                }else{
                    throw BsyncSessionError.MissingSyncID
                }
            }else{
                try self.save()
            }
        }else{
            throw BsyncSessionError.DoneCommandNotFound(encodedCommand:encodedCommand)
        }
    }
    

    
    public func save()throws{
        if _interruptible{
            if let json=Mapper<BsyncSession>().toJSONString(self){
                if let syncID=_syncContext.syncID{
                    let fileURL=localURL.URLByAppendingPathComponent(BsyncSession.fileName(syncID))
                    try json.writeToURL(fileURL, atomically: true,encoding:NSUTF8StringEncoding)
                }else{
                    throw BsyncSessionError.MissingSyncID
                }
            }else{
                throw BsyncSessionError.SerializationIssue
            }
        }else{
            throw BsyncSessionError.UnInterruptibleMode
        }
        
    }
    
    /**
     Recreates a new instance
     
     - parameter localURL: the local folder url
     - parameter syncID:   the synchronization id
     
     - throws:
     
     - returns: a BsyncSession object
     */
    static public func sessionFrom(localURL:NSURL,syncID:String) throws ->BsyncSession {
        let fileURL=localURL.URLByAppendingPathComponent(BsyncSession.fileName(syncID))
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!){
            let json = try String(contentsOfURL: fileURL, encoding: NSUTF8StringEncoding)
            if let session=Mapper<BsyncSession>().map(json){
                if session.todo.count==0{
                    throw BsyncSessionError.NothingTodo
                }
                return session
            }else{
                BsyncSessionError.DeserializationIssue
            }
        }else{
            throw BsyncSessionError.SerializedSessionFileNotFound
        }
        // Should never occur
        throw BsyncSessionError.UnDefined
    }
    
    
    /**
     Removes all the previous sessions
     
     - parameter localURL: the folder local url
     */
    static public func cleanUpOlderBsyncSession(localURL:NSURL){
        let enumerator=NSFileManager.defaultManager().enumeratorAtURL(localURL, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: []){ (url, error) -> Bool in
            return true
        }
        while let fileURL=enumerator?.nextObject(){
            if let url=fileURL as? NSURL{
                if let fileName=url.lastPathComponent{
                    if fileName.rangeOfString(BsyncSession.filePrefix) != nil {
                        do{
                            try NSFileManager.defaultManager().removeItemAtURL(url)
                        }catch{
                            // Silent catch
                        }
                    }
                }
            }
        }
    }
    
    

    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init()
        self.mapping(map)
    }

    public func mapping(map: Map) {
        self._syncContext <- map["_syncContext"]
        self._encodedCommands <- map["_encodedCommands"]
        self._todo <- map["_todo"]
        self._done <- map["_done"]
    }

}