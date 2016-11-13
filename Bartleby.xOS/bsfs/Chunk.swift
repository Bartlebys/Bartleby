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
    var baseDirectory:String=Default.NO_PATH
    var relativePath:String
    var sha1:String
    var startsAt:Int
    var originalSize:Int
    var nodeNature:Nature = .file
    var parentFilePath:String=Default.NO_PATH

    /// The nature of the reference
    /// We support files, aliases and folders (not SymLinks)
    public enum Nature{
        
        case file
        case alias
        case folder

        static func fromNodeNature(_ nodeNature:Node.Nature)->Nature?{
            if nodeNature == .file{
                return Nature.file
            }
            if nodeNature == .alias{
                return Nature.alias
            }
            if nodeNature == .folder{
                return Nature.folder
            }
            return nil
        }

        var forNode:Node.Nature{
            switch self {
            case .file:
                return Node.Nature.file
            case .alias:
                return Node.Nature.alias
            case .folder:
                return Node.Nature.folder
            }
        }
    }



    /// Designated initializer
    ///
    /// - Parameters:
    ///   - rank: the rank
    ///   - baseDirectory: the base directory
    ///   - relativePath: the relative path
    ///   - sha1: the sha1 digest of the chunk
    ///   - startsAt: the position in the node
    ///   - originalSize: the original size (before compression, encryption)
    ///   - nature: the nature of the parent of the chunk
    ///   - parentFilePath: the parent file path (or the alias destination)
    init(rank:Int,baseDirectory:String,relativePath:String,sha1:String,startsAt:Int, originalSize:Int,nature:Nature = .file,parentFilePath:String = Default.NO_PATH){
        self.rank=rank
        self.baseDirectory=baseDirectory
        self.relativePath=relativePath
        self.sha1=sha1
        self.startsAt=startsAt
        self.originalSize=originalSize
        self.nodeNature=nature
        self.parentFilePath=parentFilePath
    }



    /// Creates a Chunk from a Block
    ///
    /// - Parameter block: the block
    init(from block:Block){
        self.rank=block.rank
        if let node=block.node{
            self.nodeNature=Chunk.Nature.fromNodeNature(node.nature) ?? .file
            if let box=node.box{
                self.baseDirectory=box.absoluteFolderPath
            }
        }
        self.relativePath=block.blockRelativePath()
        self.sha1=block.digest
        self.startsAt=block.startsAt
        self.originalSize=block.size
    }
        
}
