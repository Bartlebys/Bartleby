//
//  Chunker.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 09/11/2016.
//
//

import Foundation


// An High performance Chunker, with a reduced memory foot print
struct  Chunker {

    fileprivate let _fileManager:FileManager

    // Destroys the chunks destination folder
    var destroyChunksFolder:Bool

    enum Mode{
        case digestAndProcessing
        case digestOnly
    }

    // When using `.real` mode the file are chunked, when using `.digestOnly` we compute their digest only
    // Simulated can be 5X faster than real mode and do not require Disk room.
    var mode:Chunker.Mode

    // MARK: - Init

    ///  The designated Initializer
    ///
    /// - Parameters:
    ///   - fileManager: the file manager instance (should be only used on the Utility Queue)
    ///   - mode:  When using `.real` mode the file are chunked, when using `.digestOnly` we compute their digest only
    ///   - destroyChunksFolder: if set to true the chunks destination folder will be cleanup before writing the chunks (.real mode only)
    init(fileManager:FileManager,mode:Chunker.Mode = .digestAndProcessing, destroyChunksFolder:Bool=false) {
        self._fileManager=fileManager
        self.mode=mode
        self.destroyChunksFolder=destroyChunksFolder
    }



    // MARK: - Files and Folder to Chunk

    /// Breaks recursively any file, folder, alias from a given folder path.
    /// - The hard stuff is done Asynchronously on a the Utility queue
    /// - we use an Autorelease pool to lower the memory foot print
    /// - closures are called on the Main thread
    ///
    /// - Parameters:
    ///   - assembledFolderPath: the source folder path (correspond to the root folder of box)
    ///   - chunksFolderPath: the destination folder path
    ///   - chunkMaxSize: the max size for a chunk / future block
    ///   - compress: should we compress (using LZ4)
    ///   - encrypt: should we encrypt (using AES256)
    ///   - externalId: this identifier allow to map the progression
    ///   - excludeChunks: chunks to be excluded (Advanced Optimization: if you already know that you have some chunk you can by pass their processing)
    ///   - progression: progress closure called on each discreet progression.
    ///   - success: the success closure returns a Chunk Struct to be used to create/update Block instances
    ///   - failure: the failure closure including the Chunk that as been created.
    public func breakFolderIntoChunk(  filesIn assembledFolderPath:String,
                                       chunksFolderPath:String,
                                       chunkMaxSize:Int=10*MB,
                                       compress:Bool=true,
                                       encrypt:Bool=true,
                                       externalId:String=Default.NO_UID,
                                       excludeChunks:[Chunk]=[Chunk](),
                                       progression:@escaping((Progression)->()),
                                       success:@escaping ([Chunk])->(),
                                       failure:@escaping ([Chunk],String)->()){

        Async.utility{
            let progressionState=Progression()
            progressionState.silentGroupedChanges {
                progressionState.totalTaskCount=1
                progressionState.currentTaskIndex=0
                progressionState.externalIdentifier=assembledFolderPath
                progressionState.message=NSLocalizedString("Creating chunks: ", tableName:"system", comment: "Creating chunks: ")+" \(assembledFolderPath)"
            }
            progression(progressionState)

            var failuresMessages=[String]()
            var cumulatedChunks=[Chunk]()

            let fm:FileManager = self._fileManager
            if let folderURL=URL(string: assembledFolderPath){
                let keys:[URLResourceKey]=[ URLResourceKey.fileSizeKey,
                                            URLResourceKey.fileResourceTypeKey,
                                            URLResourceKey.attributeModificationDateKey,
                                            URLResourceKey.pathKey,
                                            URLResourceKey.isRegularFileKey,
                                            URLResourceKey.isDirectoryKey,
                                            URLResourceKey.isAliasFileKey,
                                            URLResourceKey.isSymbolicLinkKey ]
                let options: FileManager.DirectoryEnumerationOptions = []//.skipsHiddenFiles TODO to be verified
                var paths=[String]()
                let enumerator=fm.enumerator(at: folderURL, includingPropertiesForKeys: keys, options: options, errorHandler: { (URL, error) -> Bool in
                    return false
                })
                while let url:URL = enumerator?.nextObject() as? URL {
                    let set:Set=Set(keys)
                    if let r:URLResourceValues = try? url.resourceValues(forKeys:set){
                        if r.isRegularFile == true || r.isDirectory==true || r.isAliasFile==true{
                            let path:String=r.path!.replacingOccurrences(of: assembledFolderPath, with: "")
                            paths.append(path)
                        }
                    }
                }
                progressionState.totalTaskCount += paths.count
                let pathNb=paths.count
                var counter=1
                for relativePath in paths{

                    self.breakIntoChunk(fileAt: assembledFolderPath+relativePath,
                                        relativePath: relativePath,
                                        chunksFolderPath: chunksFolderPath,
                                        compress: compress,
                                        encrypt: encrypt,
                                        excludeChunks:excludeChunks,
                                        progression: { (progression) in
                                            // We donnot need to consign discreet progression
                    }, success: { (chunks) in
                        counter += 1
                        progressionState.silentGroupedChanges {
                            if chunks.count>0{
                                progressionState.message=chunks[0].relativePath
                            }
                            progressionState.currentTaskIndex=counter
                        }
                        cumulatedChunks.append(contentsOf: chunks)
                        progressionState.currentPercentProgress=Double(counter)*Double(100)/Double(progressionState.totalTaskCount)
                        Async.main{
                            // Relay the progression
                            progression(progressionState)
                            if counter > pathNb{
                                if failuresMessages.count==0{
                                    // it is a success
                                    success(cumulatedChunks)
                                }else{
                                    // Reduce the errors
                                    failure(cumulatedChunks,failuresMessages.reduce("Errors: ", { (r, s) -> String in
                                        return r + " \(s)"
                                    }))
                                }
                            }
                        }

                    }, failure: { (message) in
                        counter += 1
                        failuresMessages.append(message)
                    })
                }
            }else{
                Async.main{
                    failure([Chunk](),NSLocalizedString("Invalid URL", tableName:"system", comment: "Invalid URL")+" \(assembledFolderPath)")
                }
            }
        }
    }


    /// This breaks efficiently a file to chunks.
    /// - The hard stuff is done Asynchronously on a the Utility queue
    /// - we use an Autorelease pool to lower the memory foot print
    /// - closures are called on the Main thread
    ///
    /// - Parameters:
    ///   - absolutePath: the file absolute path (can be external to assembledFolderPath or box)
    ///   - relativePath: the file relative path to assembledFolderPath
    ///   - chunksfolderPath: the destination folder path for the chunk
    ///   - chunkMaxSize: the max size for a chunk / future block
    ///   - compress: should we compress (using LZ4)
    ///   - encrypt: should we encrypt (using AES256)
    ///   - externalId: this identifier allow to map the progression
    ///   - excludeChunks: chunks to be excluded (Advanced Optimization: if you already know that you have some chunk you can by pass their processing)
    ///   - progression: progress closure called on each discreet progression.
    ///   - success: the success closure returns a Chunk Struct to be used to create/update Block instances
    ///   - failure: the failure closure
    public func breakIntoChunk(  fileAt absolutePath:String,
                                 relativePath:String,
                                 chunksFolderPath:String,
                                 chunkMaxSize:Int=10*MB,
                                 compress:Bool=true,
                                 encrypt:Bool=true,
                                 externalId:String=Default.NO_UID,
                                 excludeChunks:[Chunk]=[Chunk](),
                                 progression:@escaping((Progression)->()),
                                 success:@escaping ([Chunk])->(),
                                 failure:@escaping (String)->()){

        // Don't block the main thread with those intensive IO  processing
        Async.utility {
            if self._isPathValid(absolutePath){
                if let attributes:[FileAttributeKey : Any] = try? self._fileManager.attributesOfItem(atPath: absolutePath){
                    if let type=attributes[FileAttributeKey.type] as? FileAttributeType{

                        if (URL(fileURLWithPath: absolutePath).isAnAlias){
                            // It is an alias
                            var aliasDestinationPath:String=Default.NO_PATH
                            do{
                                aliasDestinationPath = try self._resolveAlias(at:absolutePath)
                            }catch{
                                glog("Alias resolution error for path \(absolutePath) s\(error)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
                            }
                            var chunk=Chunk(rank: 0,
                                            baseDirectory:chunksFolderPath,
                                            relativePath: "/aliases/"+Bartleby.createUID(),
                                            sha1: Default.NO_DIGEST, startsAt: 0,
                                            originalSize:0,
                                            nature: Chunk.Nature.alias,
                                            nodeRelativePath:relativePath)
                            chunk.aliasDestination=aliasDestinationPath
                            chunk.sha1=chunk.relativePath.sha1
                            Async.main{
                                success([chunk])
                            }

                        }else if type==FileAttributeType.typeRegular{

                            self._breakIntoChunk( fileAt: absolutePath,
                                                  relativePath:relativePath,
                                                  chunksfolderPath: chunksFolderPath,
                                                  chunkMaxSize: chunkMaxSize,
                                                  compress: compress,
                                                  encrypt: encrypt,
                                                  externalId: externalId,
                                                  excludeChunks: excludeChunks,
                                                  progression: progression,
                                                  success: success,
                                                  failure: failure)

                        }else if type==FileAttributeType.typeDirectory{
                            var chunk=Chunk( rank: 0,
                                             baseDirectory:chunksFolderPath,
                                             relativePath: "/folders/"+Bartleby.createUID(),
                                             sha1: Default.NO_DIGEST,
                                             startsAt: 0,
                                             originalSize:0,
                                             nature: Chunk.Nature.folder,
                                             nodeRelativePath:relativePath)
                            chunk.sha1=chunk.relativePath.sha1
                            Async.main{
                                success([chunk])
                            }
                        }
                    }
                }else{
                    Async.main{
                        failure(NSLocalizedString("Unable to extract attributes at path:", tableName:"system", comment: "Unable to extract attributes at path:")+" \(absolutePath)")
                    }
                }
            }else{
                Async.main{
                    failure(NSLocalizedString("Invalid file at path:", tableName:"system", comment: "Unexisting file at path:")+" \(absolutePath)")
                }
            }
        }
    }



    fileprivate func _breakIntoChunk(   fileAt path:String,
                                        relativePath:String,
                                        chunksfolderPath:String,
                                        chunkMaxSize:Int=10*MB,
                                        compress:Bool,
                                        encrypt:Bool,
                                        externalId:String=Default.NO_UID,
                                        excludeChunks:[Chunk]=[Chunk](),
                                        progression:@escaping((Progression)->()),
                                        success:@escaping ([Chunk])->(),
                                        failure:@escaping (String)->()){

        Async.utility {


            // Read each chunk efficiently
            if let fileHandle=FileHandle(forReadingAtPath:path ){

                let _=fileHandle.seekToEndOfFile()
                let l=fileHandle.offsetInFile
                fileHandle.seek(toFileOffset: 0)
                let maxSize:UInt64 = UInt64(chunkMaxSize)
                let n:UInt64=l/maxSize
                var r:UInt64=l % maxSize
                var nb:UInt64=0
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
                if self.mode == .digestAndProcessing{
                    if self.destroyChunksFolder{
                        let _ = try? self._fileManager.removeItem(atPath: chunksfolderPath)
                    }

                    let _ = try? self._fileManager.createDirectory(atPath: chunksfolderPath, withIntermediateDirectories: true, attributes: nil)

                }

                var offset:UInt64=0
                var position:UInt64=0
                var chunks=[Chunk]()

                var counter=0


                func __writeData(rank:Int,size:Int, data:Data,to chunksFolderPath:String,digest sha1:String, position:Int,relativePath:String)throws->(){
                    // Generate a Classified Block Tree.
                    let c1=PString.substr(sha1, 0, 1)
                    let c2=PString.substr(sha1, 1, 1)
                    let c3=PString.substr(sha1, 2, 1)
                    let relativeFolderPath="/\(c1)/\(c2)/\(c3)/"
                    let bFolderPath=chunksFolderPath+relativeFolderPath
                    if self.mode == .digestAndProcessing{
                        let _ = try self._fileManager.createDirectory(atPath: bFolderPath, withIntermediateDirectories: true, attributes: nil)
                    }
                    let destination=bFolderPath+"/\(sha1)"
                    let chunkRelativePath=relativeFolderPath+"\(sha1)"

                    let chunk=Chunk( rank:rank,
                                     baseDirectory:chunksFolderPath,
                                     relativePath: chunkRelativePath,
                                     sha1: sha1,
                                     startsAt:position,
                                     originalSize:size,
                                     nodeRelativePath:relativePath)

                    chunks.append(chunk)
                    if self.mode == .digestAndProcessing{
                        let url=URL(fileURLWithPath: destination)
                        let _ = try data.write(to:url )
                    }

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
                                if compress && self.mode == .digestAndProcessing{
                                    data = try data.compress(algorithm: .lz4)
                                }
                                if encrypt && self.mode == .digestAndProcessing{
                                    data = try Bartleby.cryptoDelegate.encryptData(data)
                                }
                                try __writeData(rank:Int(i),size:Int(offset), data: data,to:chunksfolderPath,digest:sha1,position:Int(position),relativePath:relativePath)
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


    // MARK: - Chunks to files and folders


    /// Joins multiple chunks to a folder
    ///
    /// - Parameters:
    ///   - chunks: the chunks
    ///   - assemblyFolderPath: the destination folder where the chunks will be joined (or assembled)
    ///   - progression: the progression closure
    ///   - success: the success closure
    ///   - failure: the failure closure with to created paths (to be able to roll back)
    public func joinsChunks( chunks:[Chunk],
                             assemblyFolderPath:String,
                             progression:@escaping((Progression)->()),
                             success:@escaping ()->(),
                             failure:@escaping (_ createdPaths:[String],_ message:String)->()){

        Async.utility {

            // #1 Compute the file path to chunk.
            var filePathToChunks=[String:[Chunk]]()
            for chunk in chunks{
                if !filePathToChunks.contains(where: { (k,v) -> Bool in
                    return k==chunk.nodePath
                }){
                    filePathToChunks[chunk.nodePath]=[Chunk]()
                }
                filePathToChunks[chunk.nodePath]!.append(chunk)
            }


            var failuresMessages=[String]()
            var createdPaths=[String]()

            let progressionState=Progression()
            progressionState.silentGroupedChanges {
                progressionState.totalTaskCount=filePathToChunks.count
                progressionState.currentTaskIndex=0
                progressionState.externalIdentifier=""
                progressionState.message=""
            }


            // #2 re-join the files
            var counter=0
            for (_,v) in filePathToChunks{
                let destinationFile=assemblyFolderPath+v[0].nodePath
                let nodeNature=v[0].nodeNature

                // Sub func for normalized progression relay
                func __progressWithPath(_ path:String){
                    counter += 1
                    createdPaths.append(path)
                    progressionState.silentGroupedChanges {
                        progressionState.message=path
                        progressionState.currentTaskIndex=counter
                    }
                    progressionState.currentPercentProgress=Double(counter)*Double(100)/Double(progressionState.totalTaskCount)
                    // Relay the progression
                    Async.main{
                        progression(progressionState)
                    }
                }

                if nodeNature == .file{

                    let chunksPaths=v.map({ (chunk) -> String in
                        return assemblyFolderPath+"/.blocks"+chunk.relativePath //chunk.absolutePath
                    })
                    self.joinChunksToFile(from: chunksPaths,
                                          to: destinationFile,
                                          decompress: true,
                                          decrypt: true,
                                          progression: { (progression) in
                                            //
                    }, success: { path in
                        counter += 1
                        __progressWithPath(path)
                        if counter==filePathToChunks.count{
                            Async.main{
                                if failuresMessages.count==0{
                                    // it is a success
                                    success()
                                }else{
                                    // Reduce the errors
                                    failure(createdPaths, failuresMessages.reduce("Errors: ", { (r, s) -> String in
                                        return r + " \(s)"
                                    }))
                                }
                            }
                        }
                    }, failure: { (message) in
                        counter += 1
                        failuresMessages.append(message)
                    })

                }else if nodeNature == .folder{
                    counter += 1
                    Async.utility{
                        do{
                            try FileManager.default.createDirectory(atPath: destinationFile, withIntermediateDirectories: true, attributes: nil)
                            __progressWithPath(destinationFile)
                        }catch{
                            failuresMessages.append("\(error)")
                        }
                    }


                }else if nodeNature == .alias{
                    counter += 1
                    Async.utility{
                        do{
                            try FileManager.default.createSymbolicLink(atPath: destinationFile, withDestinationPath: v[0].aliasDestination)
                            __progressWithPath(destinationFile)
                        }catch{
                            failuresMessages.append("\(error)")
                        }
                    }

                }
            }
        }



    }


    /// Joins the chunks to form a single file
    /// - The hard stuff is done Asynchronously on a the Utility queue
    /// - we use an Autorelease pool to lower the memory foot print
    /// - closures are called on the Main thread
    ///
    /// - Parameters:
    ///   - chunksPaths: the chunks absolute paths
    ///   - destinationFilePath: the joined file destination
    ///   - decompress: should we decompress using LZ4
    ///   - decrypt: should we decrypt usign AES256
    ///   - externalId: this identifier allow to map the progression
    ///   - progression: progress closure called on each discreet progression.
    ///   - success: the success closure
    ///   - failure: the failure closure
    public func joinChunksToFile (   from chunksPaths:[String],
                                     to assemblyFolderPath:String,
                                     decompress:Bool,
                                     decrypt:Bool,
                                     externalId:String=Default.NO_UID,
                                     progression:@escaping((Progression)->()),
                                     success:@escaping (_ path:String)->(),
                                     failure:@escaping (_ message:String)->()){

        // Don't block the main thread with those intensive IO  processing
        Async.utility {
            do{
                let folderPath=(assemblyFolderPath as NSString).deletingLastPathComponent
                try self._fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
                self._fileManager.createFile(atPath: assemblyFolderPath, contents: nil, attributes: nil)

                // Assemble
                if let writeFileHande = FileHandle(forWritingAtPath:assemblyFolderPath ){
                    writeFileHande.seek(toFileOffset: 0)

                    let progressionState=Progression()
                    progressionState.silentGroupedChanges {
                        progressionState.totalTaskCount=chunksPaths.count
                        progressionState.currentTaskIndex=0
                        progressionState.message=""
                        progressionState.externalIdentifier=externalId
                    }

                    var counter=0
                    for source in chunksPaths{
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
                        success(assemblyFolderPath)
                    }

                }else{
                    Async.main{
                        failure(NSLocalizedString("Enable to create file Handle", tableName:"system", comment: "Enable to create file Handle")+" \(assemblyFolderPath)")
                    }
                }
            }catch{
                Async.main{
                    failure("\(error)")
                }
            }
        }
    }

    // MARK: -


    /// Test the validity of a path
    /// 1# We test the existence of the path.
    /// 2# Some typeSymbolicLink may point to themselves and then be considerated as inexistent
    /// We consider those symlinks as valid entries (those symlink are generally in frameworks QA required)
    ///
    /// - Parameter path: the path
    /// - Returns: true if the path is valid
    fileprivate func _isPathValid(_ path:String)->Bool{
        if self._fileManager.fileExists(atPath:path){
            return true
        }
        if let attributes:[FileAttributeKey : Any] = try? self._fileManager.attributesOfItem(atPath: path){
            if let type=attributes[FileAttributeKey.type] as? FileAttributeType{
                if type == .typeSymbolicLink{
                    return true
                }
            }
        }
        return false
    }
    
    
    
    func _resolveAlias(at path:String) throws -> String {
        let pathURL=URL(fileURLWithPath: path)
        let original = try URL(resolvingAliasFileAt: pathURL, options:[])
        return original.path
    }
    
    
}
