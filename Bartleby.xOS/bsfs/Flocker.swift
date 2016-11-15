//
//  Flocker.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 05/11/2016.
//
//

import Foundation



/*

 Binary Format specs

 --------
 data -> the Chunked file
 --------
 footer -> serialized crypted and compressed FSShadowContainer
 --------
 8Bytes for one Int -> gives the footer size
 --------

 */
struct Flocker{


    // MARK: - Flocking

    /// Flocks the files means you transform all the files to a single file
    /// By using this method you preserve the ACL
    ///
    /// - Parameters:
    ///   - folderReference: the reference to folder to flock
    ///   - path: the destination path
    func flockFolder(folderReference:FileReference, destination path:String){
        // The result is single file containing Chunks.
        // It allow to group set of files
    }

    // MARK: - UnFlocking

    /// Transforms a Binary Flock to a set of files.
    ///
    /// - Parameters:
    ///   - flockedFile: the flock
    ///   - relativePath: the folder path 
    func unFlock(flockedFile:String,to folderPath:String?){
    }

}
