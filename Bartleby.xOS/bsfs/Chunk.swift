//
//  Chunk.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 12/11/2016.
//
//

import Foundation


public struct Chunk {

    var rank:Int
    var baseDirectory:String
    var relativePath:String
    var sha1:String
    var startsAt:Int
    var originalSize:Int


    /// Designated initializer
    ///
    /// - Parameters:
    ///   - rank: the rank
    ///   - baseDirectory: the base directory
    ///   - relativePath: the relative path
    ///   - sha1: the sha1 digest of the chunk
    ///   - startsAt: the position in the node
    ///   - originalSize: the original size (before compression, encryption)
    init(rank:Int,baseDirectory:String,relativePath:String,sha1:String,startsAt:Int, originalSize:Int){
        self.rank=rank
        self.baseDirectory=baseDirectory
        self.relativePath=relativePath
        self.sha1=sha1
        self.startsAt=startsAt
        self.originalSize=originalSize
    }



    /// Creates a Chunk from a Block
    ///
    /// - Parameter block: the block
    init(from block:Block){
        self.rank=block.rank
        if let box=block.node?.box{
            self.baseDirectory=box.absoluteFolderPath
        }else{
            self.baseDirectory=Default.NO_PATH
        }
        self.relativePath=block.blockRelativePath()
        self.sha1=block.digest
        self.startsAt=block.startsAt
        self.originalSize=block.size
    }



}
