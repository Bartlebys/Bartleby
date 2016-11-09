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
 8Bytes for one Int -> footer size
 --------
 data
 --------
 footer
 --------

 The footer contains
 - [ box, nodes , blocks ]

 */
struct Flocker{


    // MARK: - Flocking

    /// Flocks the files means you transform all the files to a single file
    /// By using this method you preserve the ACL
    ///
    /// - Parameters:
    ///   - folderReference: the reference to folder to flock
    ///   - path: the destination path
    func flockFolder(folderReference:FSReference, destination path:String){
        // The result is single file containing a box.
        // It allow to group set of files
    }

    /// Flocks the box means you transform a box of Nodes to a single file
    /// By using this method you preserve the ACL
    ///
    /// - Parameters:
    ///   - box: the box to be flocked
    ///   - flockedFilePath: the flock path
    ///   - holders: the targeted user UID
    func flockTheBox(box:Box, destination flockedFilePath:String, authorized holders:[String]=["*"]){
        // The result is single file containing a box.
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
