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
 data -> the  Nodes files
 --------
 footer -> serialized crypted and compressed Container
 --------
 8Bytes for one Int -> gives the footer size
 --------

 */
struct Flocker{


    /// The file manager is used on the utility queue
    fileprivate let _fileManager:FileManager

    // The Crypto Helper
    fileprivate let _cryptoHelper:CryptoHelper

    /// Designated Initializer
    ///
    /// - Parameters:
    ///   - fileManager: the file manager to use on the Flocker Queue
    ///   - cryptoKey: the key used for crypto 32 char min
    ///   - cryptoSalt: the salt
    init(fileManager:FileManager,cryptoKey:String,cryptoSalt:String) {
        self._fileManager=fileManager
        self._cryptoHelper=CryptoHelper(key: cryptoKey, salt: cryptoSalt)
    }


    // MARK: - Flocking

    /// Flocks the files means you transform all the files to a single file
    /// By using this method the FileReference Authorization will apply to any Node
    ///
    /// - Parameters:
    ///   - folderReference: the reference to folder to flock
    ///   - path: the destination path
    func flockFolder(folderReference:FileReference, destination path:String,  progression:@escaping((Progression)->()),
                     success:@escaping ()->(),
                     failure:@escaping (Container,String)->())->(){

        self._flock(filesIn: folderReference.absolutePath,
                    flockFilePath: path,
                    chunkMaxSize: folderReference.chunkMaxSize,
                    compress: folderReference.compressed,
                    encrypt: folderReference.crypted,
                    progression: progression,
                    success: success,
                    failure: failure)
    }


    /// Breaks recursively any file, folder, alias from a given folder path  into block and adds theme to flock
    /// - The hard stuff is done Asynchronously on a the Utility queue
    /// - we use an Autorelease pool to lower the memory foot print
    /// - closures are called on the Main thread
    public func _flock(  filesIn folderPath:String,
                                       flockFilePath:String,
                                       chunkMaxSize:Int=10*MB,
                                       compress:Bool=true,
                                       encrypt:Bool=true,
                                       progression:@escaping((Progression)->()),
                                       success:@escaping ()->(),
                                       failure:@escaping (Container,String)->()){

        var container=Container()
        let box=BoxShadow()
        container.boxes.append(box)
        Async.utility{
            try? self._fileManager.removeItem(atPath: flockFilePath)
            self._fileManager.createFile(atPath: flockFilePath, contents: nil, attributes: nil)
            if let flockFileHandle = FileHandle(forWritingAtPath: flockFilePath){


                let progressionState=Progression()
                progressionState.silentGroupedChanges {
                    progressionState.totalTaskCount=1
                    progressionState.currentTaskIndex=0
                    progressionState.externalIdentifier=folderPath
                    progressionState.message=NSLocalizedString("Creating chunks: ", tableName:"system", comment: "Creating chunks: ")+" \(folderPath)"
                }
                progression(progressionState)

                var failuresMessages=[String]()

                let fm:FileManager = self._fileManager
                if let folderURL=URL(string: folderPath){
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
                                let path:String=r.path!.replacingOccurrences(of: folderPath, with: "")
                                paths.append(path)
                            }
                        }
                    }
                    progressionState.totalTaskCount += paths.count
                    let pathNb=paths.count
                    var counter=1
                    for relativePath in paths{
                        self._appendDataFromFilePath(folderPath: folderPath,
                                                     relativePath:relativePath,
                                                     handle: flockFileHandle,
                                                     container: &container,
                                                     progression: { (Progression) in
                                                    // We donnot need to consign discreet progression
                        }, success: {
                            counter += 1
                            progressionState.silentGroupedChanges {
                                progressionState.currentTaskIndex=counter
                            }
                            progressionState.currentPercentProgress=Double(counter)*Double(100)/Double(progressionState.totalTaskCount)
                            Async.main{
                                // Relay the progression
                                progression(progressionState)
                                if counter > pathNb{
                                    if failuresMessages.count==0{
                                        // it is a success
                                        success()
                                    }else{
                                        // Reduce the errors
                                        failure(container,failuresMessages.reduce("Errors: ", { (r, s) -> String in
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
                        failure(container,NSLocalizedString("Invalid URL", tableName:"system", comment: "Invalid URL")+" \(folderPath)")
                    }
                }
            }else{
                Async.main{
                    failure(container,NSLocalizedString("Unable to handle file at path: ", tableName:"system", comment: "Unable to handle file at path: ")+flockFilePath)
                }
            }

        }
    }


    fileprivate func _appendDataFromFilePath( folderPath:String,
                                             relativePath:String,
                                             handle:FileHandle,
                                             container:inout Container,
                                             progression:@escaping((Progression)->()),
                                             success:@escaping ()->(),
                                             failure:@escaping (String)->() )->(){


        let filePath=folderPath+relativePath



    }



    fileprivate func _writeContainerIntoFlock( handle:FileHandle,
                                               container:Container)throws->(){

        try autoreleasepool { () -> Void in
            let data=container.serialize()
            let compressed = try data.compress(algorithm: .lz4)
            let crypted = try Bartleby.cryptoDelegate.encryptData(compressed)
            var cryptedSize=crypted.count
            let intSize=MemoryLayout<Int>.size
            // Write the serialized container
            handle.write(data)
            // Write its size
            let sizeData=Data(bytes:&cryptedSize,count:intSize)
            handle.write(sizeData)
            // CLose the file handle
            handle.closeFile()
        }

    }

    /*

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
    
*/


    // MARK: - UnFlocking

    /// Transforms a Binary Flock to a set of files.
    ///
    /// - Parameters:
    ///   - flockedFile: the flock
    ///   - relativePath: the folder path 
    func unFlock(flockedFile:String,to folderPath:String?)->(){
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
