//
//  BSFS.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 02/11/2016.
//
//

import Foundation

enum BSFSError {
    case BoxIsInBox(existingBox:URL)
}

public struct BSFS{

    // The File manager
    static public var fileManager: BartlebyFileIO=BFileManager()

    /// The standard singleton shared instance
    public static let sharedInstance: BSFS = {
        let instance = BSFS()
        return instance
    }()

    func initializeBox(at path:String)throws ->Box?{
        // #1 Check if there is a box in the top of this path
        // #2 create the .bsfs folder + content
        // #3 return the Box
        return nil
    }
    

}
