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

 The footer contains a Serialized Box

 - Box.nodes
 - Box.blocks

 */

// COMPRESSION is using LZFSE https://developer.apple.com/reference/compression/1665429-data_compression
// CRYPTO is using CommonCrypto

// NOTE : By default any .flk file is unflocked on reception in a BSFS

struct Flocker{

    static var disabledCompressionExtensions=["zip","data","crypted","png","mov","mp3","mp4","flk"]

    // MARK: - Flocking

    /// Flocks the files means you transform a tree of file to a box of Nodes and flock it to
    ///
    /// - Parameters:
    ///   - path: the path to flock
    ///   - flockedFilePath: the path
    func flockFilesFromPath(folderPath:String, destination flockedFilePath:String){
        // The result is single file containing a box.
        // It allow to group set of files
        // The relative box path will be computed relatively to the app container (if sandboxed)
    }

    /// Flocks the files means you transform a box of Nodes to a single file
    ///
    /// - Parameters:
    ///   - path: the path to flock
    ///   - flockedFilePath: the path
    func flockTheBox(box:Box, destination flockedFilePath:String){
        // The result is single file containing a box.
        // It allow to group set of files
    }

    // MARK: - UnFlocking

    /// Transforms a Binary Flock to a set of files.
    ///
    /// - Parameters:
    ///   - flockedFile: the flock
    func unFlock(flockedFile:String){
    }

}
