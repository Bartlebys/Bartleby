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
 data -> the  Nodes binary
 --------
 footer -> serialized crypted and compressed Container
 --------
 8Bytes for one UInt64 -> gives the footer size
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
    ///   - keySize: the key size
    init(fileManager:FileManager,cryptoKey:String,cryptoSalt:String,keySize:KeySize = .s128bits) {
        self._fileManager=fileManager
        self._cryptoHelper=CryptoHelper(key: cryptoKey, salt: cryptoSalt,keySize:keySize)
    }


    // MARK: - Flocking

    /// Flocks the files means you transform all the files to a single file
    /// By using this method the FileReference Authorization will apply to any Node
    ///
    /// - Parameters:
    ///   - folderReference: the reference to folder to flock
    ///   - path: the destination path
    func flockFolder(folderReference:FileReference,
                     destination path:String,
                     progression:@escaping((Progression)->()),
                     success:@escaping ()->(),
                     failure:@escaping (Container,String)->())->(){

        self._flock(filesIn: folderReference.absolutePath,
                    flockFilePath: path,
                    authorized:folderReference.authorized,
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
    fileprivate func _flock(  filesIn folderPath:String,
                              flockFilePath:String,
                              authorized:[String],
                              chunkMaxSize:Int=10*MB,
                              compress:Bool=true,
                              encrypt:Bool=true,
                              progression:@escaping((Progression)->()),
                              success:@escaping ()->(),
                              failure:@escaping (Container,String)->()){

        let container=Container()
        container.defineUID()
        let box=BoxShadow()
        box.defineUID()
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
                    progressionState.message=NSLocalizedString("Adding file: ", tableName:"system", comment: "Adding file:  ")+" \(folderPath)"
                }
                Async.main{
                    progression(progressionState)
                }

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
                    var counter=0
                    for relativePath in paths{
                        self._append(folderPath: folderPath,
                                     relativePath:relativePath,
                                     writeHandle: flockFileHandle,
                                     container: container,
                                     authorized:authorized,
                                     chunkMaxSize:chunkMaxSize,
                                     compress:compress,
                                     encrypt:encrypt,
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
                            }
                            if counter == pathNb{
                                defer{
                                    // Close the flockFileHandle
                                    flockFileHandle.closeFile()
                                }
                                do{
                                    try self._writeContainerIntoFlock(handle: flockFileHandle, container: container)

                                }catch{
                                    failuresMessages.append("_writeContainerIntoFlock \(error)")
                                }
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

                        }, failure: { (message) in
                            counter += 1
                            failuresMessages.append(message)
                        })
                    }
                }else{
                     // Close the flockFileHandle
                    flockFileHandle.closeFile()
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


    fileprivate func _append( folderPath:String,
                              relativePath:String,
                              writeHandle:FileHandle,
                              container:Container,
                              authorized:[String],
                              chunkMaxSize:Int=10*MB,
                              compress:Bool=true,
                              encrypt:Bool=true,
                              progression:@escaping((Progression)->()),
                              success:@escaping ()->(),
                              failure:@escaping (String)->() )->(){


        let filePath=folderPath+relativePath
        let node=NodeShadow()
        node.defineUID()
        node.relativePath=relativePath
        node.boxUID=container.boxes[0].UID
        node.compressedBlocks=compress
        node.cryptedBlocks=encrypt
        Async.utility {
            if self._isPathValid(filePath){
                if let attributes:[FileAttributeKey : Any] = try? self._fileManager.attributesOfItem(atPath: filePath){
                    if let type=attributes[FileAttributeKey.type] as? FileAttributeType{

                        if (URL(fileURLWithPath: filePath).isAnAlias){
                            // It is an alias
                            var aliasDestinationPath:String=Default.NO_PATH
                            do{
                                aliasDestinationPath = try self._resolveAlias(at:filePath)
                            }catch{
                                glog("Alias resolution error for path \(filePath) s\(error)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
                            }
                            node.nature=Node.Nature.alias
                            node.proxyPath=aliasDestinationPath
                            container.nodes.append(node)
                            Async.main{
                                success()
                            }
                        }else if type==FileAttributeType.typeRegular{
                            // It is a file
                            node.nature=Node.Nature.file
                            if let fileHandle=FileHandle(forReadingAtPath:filePath ){

                                // We Can't guess what will Happen
                                // But we want a guarantee the handle will be closed
                                defer{
                                    fileHandle.closeFile()
                                }

                                // determine the length
                                let _=fileHandle.seekToEndOfFile()
                                let length=fileHandle.offsetInFile
                                // reposition to 0
                                fileHandle.seek(toFileOffset: 0)
                                let maxSize:UInt64 = UInt64(chunkMaxSize)
                                let n:UInt64 = length / maxSize
                                var rest:UInt64 = length % maxSize
                                var nb:UInt64=0
                                if rest>0 && length >= maxSize{
                                    nb += n
                                }
                                if length < maxSize{
                                    rest = length
                                }
                                var offset:UInt64=0
                                var position:UInt64=0
                                var counter=0



                                do {


                                    for i in 0 ... nb{
                                        // We try to reduce the memory usage
                                        // To the footprint of a Chunk +  Derivated Data.
                                        try autoreleasepool(invoking: { () -> Void in
                                            fileHandle.seek(toFileOffset: position)
                                            offset = (i==nb ? rest : maxSize)
                                            position += offset
                                            var data=fileHandle.readData(ofLength: Int(offset))
                                            let sha1=data.sha1
                                            if compress{
                                                data = try data.compress(algorithm: .lz4)
                                            }
                                            if encrypt{
                                                data = try self._cryptoHelper.encryptData(data)
                                            }
                                            let writePosition=Int(writeHandle.offsetInFile)
                                            let lengthOfAddedData:Int=data.count
                                            print("\(i) \(filePath) [\(length)] \(position) \(writePosition) \(writePosition+lengthOfAddedData) | \(lengthOfAddedData)")

                                            writeHandle.write(data)

                                            let block=BlockShadow()
                                            block.defineUID()
                                            block.startsAt = writePosition-lengthOfAddedData
                                            block.size = lengthOfAddedData
                                            block.digest=sha1
                                            block.rank=counter
                                            block.nodeUID=node.UID
                                            block.compressed=compress
                                            block.crypted=encrypt
                                            node.blocksUIDS.append(block.UID)
                                            container.blocks.append(block)
                                            counter+=1
                                        })
                                    }

                                    container.nodes.append(node)
                                    Async.main{
                                        success()
                                    }


                                }catch{
                                    Async.main{
                                        failure("\(error)")
                                    }
                                }
                            }else{
                                Async.main{
                                    failure(NSLocalizedString("Enable to create Reading file Handle", tableName:"system", comment: "Enable to create Reading file Handle")+" \(filePath)")
                                }
                            }
                        }else if type==FileAttributeType.typeDirectory{
                            node.nature=Node.Nature.folder
                            container.nodes.append(node)
                            Async.main{
                                success()
                            }
                        }
                    }
                }else{
                    Async.main{
                        failure(NSLocalizedString("Unable to extract attributes at path:", tableName:"system", comment: "Unable to extract attributes at path:")+" \(filePath)")
                    }
                }
            }else{
                Async.main{
                    failure(NSLocalizedString("Invalid file at path:", tableName:"system", comment: "Unexisting file at path:")+" \(filePath)")
                }
            }
        }
    }



    fileprivate func _writeContainerIntoFlock( handle: FileHandle,
                                               container: Container)throws->(){
        try autoreleasepool { () -> Void in
            var data=container.serialize()
            data = try data.compress(algorithm: .lz4)
            data = try self._cryptoHelper.encryptData(data)
            var cryptedSize:UInt64=UInt64(data.count)
            let intSize=MemoryLayout<UInt64>.size
            // Write the serialized container
            handle.write(data)
            // Write its size
            let sizeData=Data(bytes:&cryptedSize,count:intSize)
            handle.write(sizeData)
        }
    }



    // MARK: - UnFlocking

    /// Transforms a .flk to a file tree
    ///
    /// - Parameters:
    ///   - flockedFile: the flock
    ///   - destination: the folder path
    ///   - progression:
    ///   - success:
    ///   - failure:
    func unFlock(flockedFile:String
        ,to destination:String
        ,progression:@escaping((Progression)->()),
         success:@escaping ()->(),
         failure:@escaping(_ message:String)->()){
        do{
            let container = try self.containerFrom(flockedFile: flockedFile)
            Async.utility{
                if let fileHandle=FileHandle(forReadingAtPath:flockedFile ){

                    let progressionState=Progression()
                    progressionState.silentGroupedChanges {
                        progressionState.totalTaskCount=container.nodes.count
                        progressionState.currentTaskIndex=0
                        progressionState.externalIdentifier=flockedFile
                        progressionState.message=""
                    }

                    var failuresMessages=[String]()
                    var counter=0
                    Async.main{
                        progression(progressionState)
                    }
                    for node in container.nodes{
                        let blocks=container.blocks.filter({ (block) -> Bool in
                            return block.nodeUID==node.UID
                        })
                        self._assembleNode(node: node,
                                           blocks: blocks,
                                           flockFileHandle:fileHandle,
                                           assemblyFolderPath: destination, progression: {
                                            (progression) in
                                            // No discreet progression
                        }, success: {
                            counter += 1
                            if counter==container.nodes.count{
                                Async.main{
                                    if failuresMessages.count==0{
                                        // it is a success
                                        success()
                                    }else{
                                        // Reduce the errors
                                        failure(failuresMessages.reduce("Errors: ", { (r, s) -> String in
                                            return r + " \(s)"
                                        }))
                                    }
                                }
                            }
                        }, failure: { (createdPaths,message) in
                            counter += 1
                            failuresMessages.append(message)
                        })
                    }

                }else{
                    Async.main{
                        failure(NSLocalizedString("Enable to create Reading file Handle", tableName:"system", comment: "Enable to create Reading file Handle")+" \(flockedFile)")
                    }
                }
            }

        }catch{
            failure(NSLocalizedString("Container error", tableName:"system", comment: "Container Error") + " \(error)")
        }

    }

    /// Returns the deserialized container from the flock file
    ///
    /// - Parameter flockedFile: the flocked file
    /// - Returns: the Container for potential random access
    func containerFrom(flockedFile:String)throws->Container{
        let group=AsyncGroup()
        var container:Container?
        var catched:Error?=nil
        group.utility {
            if let fileHandle=FileHandle(forReadingAtPath:flockedFile ){

                // We Can't guess what will Happen
                // But we want a guarantee the handle will be closed
                defer{
                    fileHandle.closeFile()
                }

                /*
                 Binary Format specs
                 --------
                 data -> the  Nodes binary
                 --------
                 footer -> serialized crypted and compressed Container
                 --------
                 8Bytes for one (UInt64) -> gives the footer size
                 --------
                 */
                do{
                    let _=fileHandle.seekToEndOfFile()
                    let l=fileHandle.offsetInFile
                    let intSize=MemoryLayout<UInt64>.size
                    // Go to size position
                    let sizePosition=UInt64(l)-UInt64(intSize)
                    fileHandle.seek(toFileOffset:sizePosition)
                    let footerSizeData=fileHandle.readData(ofLength: intSize)
                    let footerSize:UInt64=footerSizeData.withUnsafeBytes { $0.pointee }

                    /// Go to footer position
                    let footerPosition=UInt64(l)-(UInt64(intSize)+footerSize)
                    fileHandle.seek(toFileOffset:footerPosition)
                    var data=fileHandle.readData(ofLength: Int(footerSize))
                    data = try self._cryptoHelper.decryptData(data)
                    data = try data.decompress(algorithm: .lz4)
                    container = try JSerializer.deserialize(data) as? Container
                }catch{
                    catched=error
                }
            }
        }
        group.wait()
        if catched != nil{
            throw catched!
        }
        return container!
    }


    /// Assemble the node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - blocks: the blocks
    ///   - assemblyFolderPath: the destination folder where the chunks will be joined (or assembled)
    ///   - progression: the progression closure
    ///   - success: the success closure
    ///   - failure: the failure closure with to created paths (to be able to roll back)
    public func _assembleNode( node:Node,
                               blocks:[BlockShadow],
                               flockFileHandle:FileHandle,
                               assemblyFolderPath:String,
                               progression:@escaping((Progression)->()),
                               success:@escaping ()->(),
                               failure:@escaping (_ createdPaths:[String],_ message:String)->()){

        Async.utility {

            print("\(node.relativePath) \(blocks.count)")

            var failuresMessages=[String]()
            var createdPaths=[String]()

            let decrypt=node.cryptedBlocks
            let decompress=node.compressedBlocks

            let progressionState=Progression()
            progressionState.silentGroupedChanges {
                progressionState.totalTaskCount=blocks.count
                progressionState.currentTaskIndex=0
                progressionState.externalIdentifier=""
                progressionState.message=""
            }


            var counter=0

            let destinationFile=assemblyFolderPath+node.relativePath
            let nodeNature=node.nature


            // Sub func for normalized progression and finalization handling
            func __progressWithPath(_ path:String,error:Bool=false){
                counter += 1
                if (!error){
                    createdPaths.append(path)
                }
                progressionState.silentGroupedChanges {
                    progressionState.message=path
                    progressionState.currentTaskIndex=counter
                }
                progressionState.currentPercentProgress=Double(counter)*Double(100)/Double(progressionState.totalTaskCount)
                // Relay the progression
                Async.main{
                    progression(progressionState)
                }

                if counter>=blocks.count{
                    Async.main{
                        if failuresMessages.count==0{
                            // it is a success
                            success()
                        }else{
                            let messages=failuresMessages.reduce("Errors: ", { (r, s) -> String in
                                return r + " \(s)"
                            })
                            // Reduce the errors
                            failure(createdPaths, messages)
                        }
                    }
                }
            }


            if nodeNature == .file{
                do{
                    let folderPath=(destinationFile as NSString).deletingLastPathComponent
                    try self._fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
                    self._fileManager.createFile(atPath: destinationFile, contents: nil, attributes: nil)

                    if let writeFileHandler = FileHandle(forWritingAtPath:destinationFile ){

                        // We Can't guess what will Happen
                        // But we want a guarantee the handle will be closed
                        defer{
                            writeFileHandler.closeFile()
                        }

                        writeFileHandler.seek(toFileOffset: 0)
                        for block in blocks{
                            autoreleasepool(invoking: { () -> Void in
                                do{
                                    let startsAt=UInt64(block.startsAt)
                                    let size=block.size
                                    flockFileHandle.seek(toFileOffset: startsAt)
                                    var data = flockFileHandle.readData(ofLength: size)
                                    let rawDataSize=data.count
                                    if decrypt{
                                        data = try self._cryptoHelper.decryptData(data)
                                    }
                                    let decryptDataSize=data.count
                                    if decompress{
                                        data = try data.decompress(algorithm: .lz4)
                                    }
                                    let decompressDataSize=data.count
                                    writeFileHandler.write(data)
                                    print("\(counter)-\(block.rank)| \(startsAt) \(size) =>\(rawDataSize) - \(decryptDataSize)- \(decompressDataSize) --")
                                    __progressWithPath(destinationFile)
                                }catch{
                                    failuresMessages.append("\(error)")
                                    __progressWithPath(destinationFile,error:true)
                                }
                            })
                        }
                    }else{
                        failuresMessages.append("Enable to create file Handle \(destinationFile)")
                        __progressWithPath(destinationFile,error:true)

                    }
                }catch{
                    failuresMessages.append("\(error)")
                    __progressWithPath(destinationFile,error:true)
                }


            }else if nodeNature == .folder{
                Async.utility{
                    do{
                        try self._fileManager.createDirectory(atPath: destinationFile, withIntermediateDirectories: true, attributes: nil)
                        __progressWithPath(destinationFile)
                    }catch{
                        failuresMessages.append("\(error)")
                        __progressWithPath(destinationFile,error:true)
                    }
                }


            }else if nodeNature == .alias{
                Async.utility{
                    do{
                        try self._fileManager.createSymbolicLink(atPath: destinationFile, withDestinationPath: node.proxyPath!)
                        __progressWithPath(destinationFile)
                    }catch{
                        failuresMessages.append("\(error)")
                        __progressWithPath(destinationFile,error:true)
                    }
                }
            }

        }
    }

    // MARK: - Random Access TODO

    // MARK:  Read Access

    func extractNode(node:NodeShadow,from container:Container, of flockedFilePath:String, destinationPath:String)->String{
        return ""
    }

    // MARK: Write Access

    // LOGICAL action bytes are not removed.
    func delete(node:NodeShadow,from container:Container, of flockedFilePath:String, destinationPath:String)->String{
        return ""
    }

    func add(fileReference:FileReference,from container:Container, of flockedFilePath:String,to relativePath:String){

    }

    // MARK: Utility

    // Remove the holes
    func compact(container:Container, of flockedFilePath:String){

    }


    // MARK: - Private implementation details
    
    
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
    
    
    fileprivate func _resolveAlias(at path:String) throws -> String {
        let pathURL=URL(fileURLWithPath: path)
        let original = try URL(resolvingAliasFileAt: pathURL, options:[])
        return original.path
    }
    
}
