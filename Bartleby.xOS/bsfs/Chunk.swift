//
//  Chunk.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 12/11/2016.
//
//

import Foundation


public struct Chunk {


    // Chunks folder base Directory
    var baseDirectory:String=Default.NO_PATH
    // Chunk's relative path in chunk folder
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
    // the parent node file path (or the alias destination)
    var nodePath:String=Default.NO_PATH

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
    init(rank:Int,baseDirectory:String,relativePath:String,sha1:String,startsAt:Int, originalSize:Int,nature:Nature = .file,nodePath:String = Default.NO_PATH){
        self.rank=rank
        self.baseDirectory=baseDirectory
        self.relativePath=relativePath
        self.sha1=sha1
        self.startsAt=startsAt
        self.originalSize=originalSize
        self.nodeNature=nature
        self.nodePath=nodePath
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


    /// Extracts the information from a file at a given path.
    ///
    /// - Parameters:
    ///   - relativePath: the relative path
    ///   - folderPath: the box or referent folder path
    public mutating func extractInformationsFromFile(at relativePath:String,within folderPath:String)throws->(){
        let fm=FileManager.default
        let p=folderPath+relativePath
        if fm.fileExists(atPath:p){
            self.relativePath=relativePath
            let attributes:[FileAttributeKey : Any]=try fm.attributesOfItem(atPath: p)
            if let size=attributes[FileAttributeKey.size] as? Int{
                self.originalSize=size
            }
            if let type=attributes[FileAttributeKey.type] as? FileAttributeType{
                if type==FileAttributeType.typeRegular{
                    self.nodeNature = .file
                }
                if type==FileAttributeType.typeSymbolicLink{
                    self.nodeNature = .alias
                    self.nodePath = self._resolveAliasPath(at: p)
                }
                if type==FileAttributeType.typeDirectory{
                    self.nodeNature = .folder
                }
            }
        }else{
            throw NodeExtractionError.message("Unexisting file at: \(p)")
        }
    }

    func _resolveAliasPath(at path:String)-> String {
        do{
            let pathURL=URL(fileURLWithPath: path)
            let original = try URL(resolvingAliasFileAt: pathURL, options:[])
            return original.path
        }catch{
            return Default.NO_PATH
        }

    }


}
