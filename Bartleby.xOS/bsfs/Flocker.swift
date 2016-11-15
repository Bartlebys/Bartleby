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
    func flockFolder(folderReference:FileReference, destination path:String,  progression:@escaping((Progression)->()),
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
    public func _flock(  filesIn folderPath:String,
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
                        self._append(folderPath: folderPath,
                                     relativePath:relativePath,
                                     handle: flockFileHandle,
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
                                if counter > pathNb{
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


    fileprivate func _append( folderPath:String,
                              relativePath:String,
                              handle:FileHandle,
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
                        }else if type==FileAttributeType.typeRegular{
                            node.nature=Node.Nature.file

                            /// READ AND WRITE THE DATA + CONSIGN THE BLOCKS in THE NODE + IN CONTAINER




                        }else if type==FileAttributeType.typeDirectory{
                            node.nature=Node.Nature.folder
                        }
                    }
                    container.nodes.append(node)
                    Async.main{
                        // success([chunk])
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
