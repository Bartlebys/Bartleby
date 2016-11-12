//
//  Chunker.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 09/11/2016.
//
//

import Foundation



//MARK: - Chunk level: chunk->file and file->chunk

// High performance Chunker, with a reduced memory foot print
struct  Chunker {

    fileprivate let _fileManager:FileManager

    /// The designated Initializer
    ///
    /// - Parameter fileManager: the file manager instance (should be only used on the Utility Queue)
    init(fileManager:FileManager) {
        self._fileManager=fileManager
    }


    /// This breaks efficiently a file to chunks.
    /// - The hard stuff is done Asynchronously on a the Utility queue
    /// - we use an Autorelease pool to lower the memory foot print
    /// - closures are called on the Main thread
    ///
    /// - Parameters:
    ///   - path: the file path
    ///   - folderPath: the destination folder path
    ///   - chunkMaxSize: the max size for a chunk / future block
    ///   - compress: should we compress (using LZ4)
    ///   - encrypt: should we encrypt (using AES256)
    ///   - externalId: this identifier allow to map the progression
    ///   - excludeChunks: chunks to be excluded (Advanced Optimization: if you already know that you have some chunk you can by pass their processing)
    ///   - progression: progress closure called on each discreet progression.
    ///   - success: the success closure returns a Chunk Struct to be used to create/update Block instances
    ///   - failure: the failure closure
    public func breakIntoChunk(  fileAt path:String,
                                 destination folderPath:String,
                                 chunkMaxSize:Int=10*MB,
                                 compress:Bool,
                                 encrypt:Bool,
                                 externalId:String=Default.NO_UID,
                                 excludeChunks:[Chunk]=[Chunk](),
                                 progression:@escaping((Progression)->()),
                                 success:@escaping ([Chunk])->(),
                                 failure:@escaping (String)->()){

        // Don't block the main thread with those intensive IO  processing
        Async.utility {

            // Read each chunk efficiently
            if let fileHandle=FileHandle(forReadingAtPath:path ){

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
                    progressionState.externalIdentifier=externalId
                    progressionState.message=""
                }

                let _ = try? self._fileManager.removeItem(atPath: folderPath)
                let _ = try? self._fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)

                var offset:UInt64=0
                var position:UInt64=0
                var chunks=[Chunk]()

                var counter=0

                func __writeData(rank:Int,data:Data,to folderPath:String,digest sha1:String, position:Int)throws->(){
                    // Generate a Classified Block Tree.
                    let c1=PString.substr(sha1, 0, 1)
                    let c2=PString.substr(sha1, 1, 1)
                    let c3=PString.substr(sha1, 2, 1)
                    let relativeFolderPath="\(c1)/\(c2)/\(c3)/"
                    let bFolderPath=folderPath+relativeFolderPath
                    let _ = try self._fileManager.createDirectory(atPath: bFolderPath, withIntermediateDirectories: true, attributes: nil)
                    let destination=bFolderPath+"/\(sha1)"
                    let chunkRelativePath=relativeFolderPath+"\(sha1)"

                    let chunk=Chunk( rank:rank,
                                    baseDirectory:folderPath,
                                    relativePath: chunkRelativePath,
                                    sha1: sha1,
                                    startsAt:position,
                                    originalSize:Int(offset))

                    chunks.append(chunk)
                    let url=URL(fileURLWithPath: destination)
                    let _ = try data.write(to:url )
                    Async.main{
                        counter += 1
                        progressionState.silentGroupedChanges {
                            progressionState.message=chunkRelativePath
                            progressionState.currentTaskIndex=counter
                        }
                        progressionState.currentPercentProgress=Double(counter)*Double(100)/Double(progressionState.totalTaskCount)
                        // Relay the progression
                        progression(progressionState)
                    }
                }

                do {
                    for i in 0 ... nb{
                        // We donnot want to reduce the memory usage
                        // To the footprint of a Chunk +  Derivated Data.
                        try autoreleasepool(invoking: { () -> Void in
                            fileHandle.seek(toFileOffset: position)
                            offset = (i==nb ? r : maxSize)
                            position += offset
                            if let idx=excludeChunks.index(where: {$0.rank == Int(i) }) {
                                // Do not read nor process the data
                                 fileHandle.seek(toFileOffset: position)
                                 chunks.append(excludeChunks[idx])
                            }else{
                                var data=fileHandle.readData(ofLength: Int(offset))
                                let sha1=data.sha1
                                if compress{
                                    data = try data.compress(algorithm: .lz4)
                                }
                                if encrypt {
                                    data = try Bartleby.cryptoDelegate.encryptData(data)
                                }
                                try __writeData(rank:Int(i), data: data,to:folderPath,digest:sha1,position:Int(position))
                            }

                        })
                        
                    }
                    fileHandle.closeFile()
                    Async.main{
                        success(chunks)
                    }

                }catch{
                    Async.main{
                        failure("\(error)")
                    }
                }
            }else{
                Async.main{
                    failure(NSLocalizedString("Enable to create file Handle", tableName:"system", comment: "Enable to create file Handle")+" \(path)")
                }
            }

        }

    }


    /// Joins the chunks to form a file
    /// - The hard stuff is done Asynchronously on a the Utility queue
    /// - we use an Autorelease pool to lower the memory foot print
    /// - closures are called on the Main thread
    ///
    /// - Parameters:
    ///   - paths: the chunks absolute paths
    ///   - destinationFilePath: the joined file destination
    ///   - decompress: should we decompress using LZ4
    ///   - decrypt: should we decrypt usign AES256
    ///   - externalId: this identifier allow to map the progression
    ///   - progression: progress closure called on each discreet progression.
    ///   - success: the success closure
    ///   - failure: the failure closure
    public func joinChunks (   from paths:[String],
                               to destinationFilePath:String,
                               decompress:Bool,
                               decrypt:Bool,
                               externalId:String=Default.NO_UID,
                               progression:@escaping((Progression)->()),
                               success:@escaping ()->(),
                               failure:@escaping (String)->()){

        // Don't block the main thread with those intensive IO  processing
        Async.utility {
            do{
                let folderPath=(destinationFilePath as NSString).deletingLastPathComponent
                try self._fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
                self._fileManager.createFile(atPath: destinationFilePath, contents: nil, attributes: nil)

                // Assemble
                if let writeFileHande = FileHandle(forWritingAtPath:destinationFilePath ){
                    writeFileHande.seek(toFileOffset: 0)

                    let progressionState=Progression()
                    progressionState.silentGroupedChanges {
                        progressionState.totalTaskCount=paths.count
                        progressionState.currentTaskIndex=0
                        progressionState.message=""
                        progressionState.externalIdentifier=externalId
                    }

                    var counter=0
                    for source in paths{
                        try autoreleasepool(invoking: { () -> Void in
                            let url=URL(fileURLWithPath: source)
                            var data = try Data(contentsOf:url)
                            if decrypt{
                                data = try Bartleby.cryptoDelegate.decryptData(data)
                            }
                            if decompress{
                                data = try data.decompress(algorithm: .lz4)
                            }
                            writeFileHande.write(data)
                            Async.main{
                                counter += 1
                                progressionState.silentGroupedChanges {
                                    progressionState.message=source
                                    progressionState.currentTaskIndex=counter
                                }
                                progressionState.currentPercentProgress=Double(counter)*Double(100)/Double(progressionState.totalTaskCount)
                                // Relay the progression
                                progression(progressionState)
                            }
                        })
                    }
                    Async.main{
                        success()
                    }

                }else{
                    Async.main{
                        failure(NSLocalizedString("Enable to create file Handle", tableName:"system", comment: "Enable to create file Handle")+" \(destinationFilePath)")
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
