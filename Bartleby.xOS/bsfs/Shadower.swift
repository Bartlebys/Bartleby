//
//  Shadower.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 11/11/2016.
//
//

import Foundation

public struct  Shadower {

    /// Computes the blocks shadows from a folder entry point  on a utility Queue
    ///
    /// - Parameters:
    ///   - path: the folder path
    ///   - chunkMaxSize: the max size for a chunk block
    ///   - success: success description
    ///   - progression: progress closure called on each discreet progression.
    ///   - success: the success closure returns collection of BlockShadow
    ///   - failure: the failure closure
    public func blocksShadowsFromFolder(folderPath:String,
                                        chunkMaxSize:Int=10*MB,
                                        success:@escaping ([NodeBlocksShadows])->(),
                                        progression:@escaping((Progression)->()),
                                        failure:@escaping (String)->()){

        Async.utility{
            let progressionState=Progression()
            progressionState.silentGroupedChanges {
                progressionState.totalTaskCount=1
                progressionState.currentTaskIndex=0
                progressionState.externalIdentifier=folderPath
                progressionState.message=NSLocalizedString("Scanning", tableName:"system", comment: "Scanning")+" \(folderPath)"
            }
            progression(progressionState)

            var failuresMessages=[String]()
            var fShadows=[NodeBlocksShadows]()

            let fm:FileManager = FileManager()
            if let folderURL=URL(string: folderPath){
                let keys:[URLResourceKey]=[URLResourceKey.fileSizeKey,URLResourceKey.fileResourceTypeKey, URLResourceKey.attributeModificationDateKey,URLResourceKey.pathKey,URLResourceKey.isRegularFileKey]
                let options: FileManager.DirectoryEnumerationOptions = .skipsHiddenFiles
                var paths=[String]()

                let enumerator=fm.enumerator(at: folderURL, includingPropertiesForKeys: keys, options: options, errorHandler: { (URL, error) -> Bool in
                    return false
                })
                while let url:URL = enumerator?.nextObject() as? URL {
                    let set:Set=Set(keys)
                    if let r:URLResourceValues = try? url.resourceValues(forKeys:set){
                        if r.isRegularFile! == true{
                            let path:String=r.path!.replacingOccurrences(of: folderPath, with: "")
                            paths.append(path)
                        }
                    }
                }
                progressionState.totalTaskCount += paths.count
                let pathNb=paths.count
                var counter=1
                for relativePath in paths{
                    self.blocksShadowsFromFile(within: folderPath, relativePath: relativePath,chunkMaxSize: chunkMaxSize, success: { (NodeBlocksShadows) in
                        counter += 1
                        progressionState.silentGroupedChanges {
                            progressionState.message=NodeBlocksShadows.nodeShadow.relativePath
                            progressionState.currentTaskIndex=counter
                        }
                        fShadows.append(NodeBlocksShadows)
                        progressionState.currentPercentProgress=Double(counter)*Double(100)/Double(progressionState.totalTaskCount)
                        Async.main{
                            // Relay the progression
                            progression(progressionState)

                            if counter > pathNb{
                                if fShadows.count==pathNb{
                                    // it is a success
                                    success(fShadows)
                                }else{
                                    failure(failuresMessages.reduce("Errors: ", { (r, s) -> String in
                                        return r + " \(s)"
                                    }))
                                }
                            }

                        }
                    }, progression: { (progression) in
                        // We donnot need to consign discreet progression
                    }, failure: { (message) in
                        failuresMessages.append(message)
                    })
                }
            }else{
                Async.main{
                    failure(NSLocalizedString("Invalid URL", tableName:"system", comment: "Invalid URL")+" \(folderPath)")
                }
            }
        }

    }





    /// Computes the blocks shadows from a single file on an utility Queue
    ///
    /// - Parameters:
    ///   - folderPath: the box folder path
    ///   - relativePath: the box to file relative path
    ///   - chunkMaxSize: the max size for a chunk block
    ///   - success: success description
    ///   - progression: progress closure called on each discreet progression.
    ///   - success: the success closure returns a tupple
    ///   - failure: the failure closure
    public func blocksShadowsFromFile( within folderPath:String,
                                      relativePath:String,
                                      chunkMaxSize:Int=10*MB,
                                      success:@escaping (NodeBlocksShadows)->(),
                                      progression:@escaping((Progression)->()),
                                      failure:@escaping (String)->()){

        Async.utility {
            do{
                let path=folderPath+relativePath

                let nodeShadow=NodeShadow()
                // Extract the information before usisng the fileHandle
                try nodeShadow.extractInformationsFromFile(at:relativePath,within:folderPath)

                // Read each chunk efficiently
                if let fileHandle=FileHandle(forReadingAtPath:path ){

                    var nodeBlocksShadows=NodeBlocksShadows()

                    nodeBlocksShadows.nodeShadow=nodeShadow

                    let _=fileHandle.seekToEndOfFile()
                    let l=fileHandle.offsetInFile
                    fileHandle.seek(toFileOffset: 0)
                    let maxSize:UInt64 = UInt64(chunkMaxSize)
                    let n:UInt64=l/maxSize
                    var r:UInt64=l % maxSize
                    var nb:UInt64=1
                    if r>0 && l >= maxSize{
                        nb += n
                    }
                    if l < maxSize{
                        r = l
                    }

                    let progressionState=Progression()
                    progressionState.silentGroupedChanges {
                        progressionState.totalTaskCount=Int(nb)
                        progressionState.currentTaskIndex=0
                        progressionState.externalIdentifier=path
                        progressionState.message=""
                    }

                    var offset:UInt64=0
                    var position:UInt64=0
                    var counter=0

                    for i in 0 ... nb{

                        // We donnot want to reduce the memory usage
                        // To the footprint of a Chunk +  Derivated Data.
                        autoreleasepool(invoking: { () -> Void in
                            fileHandle.seek(toFileOffset: position)
                            offset = ( i==nb ? r : maxSize )
                            position += offset
                            let data=fileHandle.readData(ofLength: Int(offset))
                            let sha1=data.sha1

                            let blockShadow=BlockShadow()
                            blockShadow.startsAt=Int(position)
                            blockShadow.size=Int(offset)
                            blockShadow.digest=sha1
                            nodeBlocksShadows.blocksShadows.append(blockShadow)

                            Async.main{
                                counter += 1
                                progressionState.silentGroupedChanges {
                                    progressionState.message=path
                                    progressionState.currentTaskIndex=counter
                                }
                                progressionState.currentPercentProgress=Double(counter)*Double(100)/Double(progressionState.totalTaskCount)
                                // Relay the progression
                                progression(progressionState)
                            }
                        })
                    }
                    
                    fileHandle.closeFile()
                    Async.main{
                        success(nodeBlocksShadows)
                    }
                    
                }else{
                    Async.main{
                        failure(NSLocalizedString("Enable to create file Handle", tableName:"system", comment: "Enable to create file Handle")+" \(path)")
                    }
                }

            }catch{
                Async.main{
                    failure("\(error)")
                }
            }
        }
    }
    
}
