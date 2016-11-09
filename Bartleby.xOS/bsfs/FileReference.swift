//
//  FileReference.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 08/11/2016.
//
//

import Foundation


/// A file or a folder reference (used for example to import files in box)
public struct FileReference{

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
    // We define the node nature
    var nodeNature:Node.Nature = .file

}
