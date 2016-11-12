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


    /// Computes the blocks to preserve and the block to delete when remplacing a node by the content of file.
    ///
    /// - Parameters:
    ///   - path: the file path
    ///   - node: the current node
    ///   - completed: the closure with the DeltaMap
    func deltaBlocks(fromFileAt path:String, to node:Node,
                     completed:@escaping(_ preserve:[Block],_ delete:[Block])->(),
                     failure:@escaping(_ message:String)->())->(){
        let shadower=Shadower()
        if let folderPath=node.box?.absoluteFolderPath{
            shadower.blocksShadowsFromFile(within: folderPath, relativePath: node.relativePath, success: { (nodeBlocks) in

                var toBePreserved=[Block]()
                var toBeDeleted=[Block]()

                // We use the distant reference
                // Not the local nodes.
                for block in node.blocks{
                    if nodeBlocks.blocks.contains(where: { (b) -> Bool in
                        return b.digest==block.digest
                    }){
                        toBePreserved.append(block)
                    }else{
                        toBeDeleted.append(block)
                    }
                }
                completed(toBePreserved,toBeDeleted)

            }, progression: { (progression) in
                // Nothing to do
            }, failure: { (message) in
                failure(message)
            })
        }else{
            failure("Node.box folder path not found")
        }
    }
    
}
