//
//  DeltaAnalyzer.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 12/11/2016.
//
//

import Foundation

enum DeltaAnalyzerError:Error {
    case boxUIDmissmatch
}

struct DeltaAnalyzer {

    fileprivate var _cryptoKey:String
    fileprivate var _cryptoSalt:String


    ///  The designated Initializer
    ///
    /// - Parameters:
    ///   - cryptoKey: the key used for crypto 32 char min.
    ///   - cryptoSalt: the salt
    init(cryptoKey:String,cryptoSalt:String) {
        self._cryptoKey=cryptoKey
        self._cryptoSalt=cryptoSalt
    }
    


    /// Computes the blocks to preserve and the Chunk to delete when remplacing a node by the content of file.
    ///
    /// - Parameters:
    ///   - path: the file path
    ///   - node: the current node
    ///   - fileManager: the file manager to use (queue dependent)
    ///   - completed: the closure with the DeltaMap
    ///   - failure: the failure closure
    func deltaChunks(fromFileAt path:String,
                     to node:Node,
                     using fileManager:FileManager,
                     chunkMaxSize:Int=10*MB,
                     completed:@escaping(_ preserve:[Chunk],_ delete:[Chunk])->(),
                     failure:@escaping(_ message:String)->())->(){
        // We use a Chunker is .digestOnly mode.
        // simulated mode can be 5 X times faster and do not consume Disk Room.
        let chunker=Chunker(fileManager: fileManager,cryptoKey:self._cryptoKey,cryptoSalt:self._cryptoSalt, mode:.digestOnly)
        chunker.breakIntoChunk( fileAt: path,
                                relativePath: node.relativePath,
                                chunksFolderPath: "/",// The destination is not important at all.
                                chunkMaxSize: chunkMaxSize,//
                                compress: false,// We use the simulated mode ( there will be no compression)
                                encrypt: false,// We use the simulated mode ( there will be no encryption)
                                externalId: node.UID,// Just an id for the progression
                                excludeChunks: [Chunk](),//Nothing to exclude
            progression: { (Progression) in

        },success: { (chunks) in
            var toBePreserved=[Chunk]()
            var toBeDeleted=[Chunk]()
            for chunk in chunks{
                if node.blocks.contains(where: { (block) -> Bool in
                    return chunk.sha1==block.digest && chunk.rank==block.rank
                }){
                    toBePreserved.append(chunk)
                }else{
                    toBeDeleted.append(chunk)
                }
            }
        }, failure: { (message) in
            failure(message)
        })

    }

}
