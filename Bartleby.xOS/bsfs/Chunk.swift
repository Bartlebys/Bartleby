//
//  Chunk.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 12/11/2016.
//
//

import Foundation


/// A chunk is part of a file , or a refernce to a folder or an Alias/SymLink.
public struct Chunk {

    // Chunks folder base Directory
    var chunksFolderPath:String=Default.NO_PATH

    // Chunk's relative path in chunk folder chunksFolderPath
    var relativePath:String

    // The rank in its parent node
    var rank:Int
    // Chunk's sha1 digest
    var sha1:String
    // The position in its parent.
    var startsAt:Int
    // The original size of the chunk (before compression)
    var originalSize:Int

    // The parent node nature
    var nodeNature:Nature = .file

    // the parent node relative path (relative to the box)
    var nodePath:String=Default.NO_PATH

    // If Nature == .alias the destination of the alias (is an absolute path)
    var aliasDestination=Default.NO_PATH

    /// The nature of the reference
    /// We support files, aliases and folders
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
    ///   - nodePath: the parent file path (or the alias destination)
    init(rank:Int,baseDirectory:String,relativePath:String,sha1:String,startsAt:Int, originalSize:Int,nature:Nature = .file,nodeRelativePath:String = Default.NO_PATH){
        self.rank=rank
        self.chunksFolderPath=baseDirectory
        self.relativePath=relativePath
        self.sha1=sha1
        self.startsAt=startsAt
        self.originalSize=originalSize
        self.nodeNature=nature
        self.nodePath=nodeRelativePath
    }



    /// Creates a Chunk from a Block
    ///
    /// - Parameter block: the block
    init(from block:Block){
        self.rank=block.rank
        if let node=block.node{
            self.nodeNature=Chunk.Nature.fromNodeNature(node.nature) ?? .file
            if let box=node.box{
                self.chunksFolderPath=box.nodesFolderPath
            }
        }
        self.relativePath=block.blockRelativePath()
        self.sha1=block.digest
        self.startsAt=block.startsAt
        self.originalSize=block.size
    }



    /// A facility that groups chunks per relative paths
    ///
    /// - Parameter chunks: the chunks to group
    /// - Returns: the grouped chunks
    static func groupByNodePath(chunks:[Chunk])->[String:[Chunk]]{
        var groupedPerPath=[String:[Chunk]]()
        for chunk in chunks{
            if !groupedPerPath.contains(where: { (key, _) -> Bool in
                return key == chunk.nodePath
            }){
                groupedPerPath[chunk.nodePath]=[Chunk]()
            }
            groupedPerPath[chunk.nodePath]!.append(chunk)
        }
        return groupedPerPath
    }



}
