//
//  FileReference.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 08/11/2016.
//
//

import Foundation


/// A file or a folder reference (used to add references to a box)
public class FileReference:NSObject{

    /// The absolutePath
    public var absolutePath:String
    /// the User UIDS or "*" if public no authorization by Default
    public var authorized:[String]=[String]()
    /// Should we compress using LZ4
    public var compressed:Bool=true
    /// Should we crypt using AES256
    public var crypted:Bool=true
    ///  priority: synchronization priority (higher == will be synchronized before the other nodes)
    public var priority:Int=0
    /// The chunks or blocks max size
    public var chunkMaxSize:Int=10*MB
    /// You can set a password.
    public var password:String=Default.NO_PASSWORD

    /// The nature of the reference
    /// We support file and Flock only
    public enum Nature{

        case file
        case flock

        static func fromNodeNature(nodeNature:Node.Nature)->Nature?{
            if nodeNature == .file{
                return Nature.file
            }
            if nodeNature == .flock{
                return Nature.flock
            }
            return nil
        }
        
        var forNode:Node.Nature{
            switch self {
            case .file:
                return Node.Nature.file
            case .flock:
                return Node.Nature.flock
            }
        }
    }

    // We define the node nature
    var nodeNature:Nature = Nature.file


    /// Creates a private file reference.
    ///
    /// - Parameters:
    ///   - absolutePath: the external absolute path
    ///   - usersUIDs: the authorized users UIDS
    /// - Returns: return a private file instance
    public static func privateFileReference(at absolutePath:String, authorized usersUIDs:[String])->FileReference{
        let r=FileReference(at: absolutePath)
        r.authorized=usersUIDs
        return r
    }

    /// Return a public file reference
    ///
    /// - Parameter absolutePath: the external absolute path
    /// - Returns: the public file reference
    public static func publicFileReference(at absolutePath:String)->FileReference{
        let r=FileReference(at:absolutePath)
        r.authorized=["*"]
        return r
    }


    /// Designated initializer
    ///
    /// - Parameter absolutePath: the absolute path of the reference
    init(at absolutePath:String) {
        self.absolutePath=absolutePath
    }

    /// Authorize the users with UID
    ///
    /// - Parameter userUID: the user UID to authorize
    public func authorize(userUID:String){
        if !self.authorized.contains(userUID){
            self.authorized.append(userUID)
        }
    }


}
