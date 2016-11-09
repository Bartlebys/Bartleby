//
//  FSReference.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 08/11/2016.
//
//

import Foundation


/// A file or a folder reference (used to add references to a box)
public struct FSReference{

    /// The absolutePath
    var absolutePath:String
    /// the User UIDS or "*" if public no authorization by Default
    var authorized:[String]=[String]()
    /// Should we compress using LZ4
    var compressed:Bool=true
    /// Should we crypt using AES256
    var crypted:Bool=true
    ///  priority: synchronization priority (higher == will be synchronized before the other nodes)
    var priority:Int=0

    /// The nature of the reference
    public enum Natures{
        case file
        case flock
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
    var nodeNature:Natures = Natures.file

    /// Designated initializer
    ///
    /// - Parameter absolutePath: the absolute path of the reference
    init(at absolutePath:String) {
        self.absolutePath=absolutePath
    }

    /// Authorize the users with UID
    ///
    /// - Parameter userUID: the user UID to authorize
    public mutating func authorize(userUID:String){
        if !self.authorized.contains(userUID){
            self.authorized.append(userUID)
        }
    }

    /// Creates a private file reference.
    ///
    /// - Parameters:
    ///   - absolutePath: the external absolute path
    ///   - usersUIDs: the authorized users UIDS
    /// - Returns: return a private file instance
    public static func privateFSReference(at absolutePath:String, authorized usersUIDs:[String])->FSReference{
        var r=FSReference(at: absolutePath)
        r.authorized=usersUIDs
        return r
    }

    /// Return a public file reference
    ///
    /// - Parameter absolutePath: the external absolute path
    /// - Returns: the public file reference
    public static func publicFSReference(at absolutePath:String)->FSReference{
        var r=FSReference(at:absolutePath)
        r.authorized=["*"]
        return r
    }

}
