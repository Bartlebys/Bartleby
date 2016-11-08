//
//  BSFS.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 02/11/2016.
//
//
import Foundation


/// The BSFS is set per document.
/// File level operations are done on GCD global utility queue.
public final class BSFS:TriggerHook{

    // Document

    fileprivate unowned var _document:BartlebyDocument

    /// The File manager used to perform all the BSFS operation on GCD global utility queue.
    /// Note that we also use specific FileHandle at chunk level
    fileprivate let _fileManager:FileManager=FileManager()

    // The box Delegate
    fileprivate var _boxDelegate:BoxDelegate?

    // The current accessors key:node.UID, value:Array of Accessors
    fileprivate var _accessors=[String:[NodeAccessor]]()

    /// The mounted node paths key:node.UID, value:tempFileName
    fileprivate var _mountedFileNames=[String:String]()

    /// Each document has it own BSFS
    ///
    /// - Parameter document: the document instance
    required public init(in document:BartlebyDocument){
        self._document=document
    }

    // MARKS: - Paths

    /// The BSFS base folder path
    /// ---
    /// baseFolder/
    ///     - blocks/ all the crypted compressed blocks (classifyed per 3 level of folders)
    ///     - tmp/ downloads in progress
    public var baseFolderPath:String{
        return NSHomeDirectory()+"/.bsfs/\(_document.UID)"
    }

    public var blocksFolderPath:String{
        return self.baseFolderPath+"/blocks"
    }

    /// The path correspond is where the Boxes assemble their files.
    /// The files are destroyed when a box is unmounted.
    public var boxesFolderPath:String{
        return Bartleby.getSearchPath(.cachesDirectory)!+"/boxes"
    }


    //MARK:  - Box Level

    /// Mounts the current local box == Assemble all its assemblable nodes
    /// There is no guarantee that the box is not fully up to date
    ///
    /// - Parameters:
    ///   - boxUID: the Box UID
    ///   - progressed: a closure  to relay the Progression State
    ///   - completed: a closure called on completion with Completion State.
    public func mount( boxUID:String,
                       progressed:@escaping (Progression)->(),
                       completed:@escaping (Completion)->()){
        do {

            let box = try Bartleby.registredObjectByUID(boxUID) as Box

            if box.assemblyInProgress || box.isMounted {
                throw BSFSError.attemptToMountBoxMultipleTime(boxUID: boxUID)
            }

            var concernedNodes=[Node]()

            // Let's try to assemble as much nodes as we can.
            for node in box.localNodes{
                if node.isAssemblable && !self._isAssembled(node) && !node.assemblyInProgress{
                    concernedNodes.append(node)
                }
            }

            box.silentGroupedChanges {
                box.assemblyProgression.totalTaskCount=concernedNodes.count
                box.assemblyProgression.currentTaskIndex=0
                box.assemblyProgression.currentPercentProgress=0
            }

            // We want to assemble the node sequentially.
            // So we will use a recursive pop method
            func __popNode(){
                if let node=concernedNodes.popLast(){
                    node.assemblyInProgress=true
                    self._assemble(node: node, progressed: { (progression) in
                        // We can add proportional box.assemblyProgression if we want smoother progression
                    }, completed: { (completion) in
                        node.assemblyInProgress=false
                        box.assemblyProgression.currentTaskIndex += 1
                        box.assemblyProgression.currentPercentProgress=Double(box.assemblyProgression.currentTaskIndex)*Double(100)/Double(box.assemblyProgression.totalTaskCount)
                        __popNode()
                    })
                }else{
                    box.assemblyInProgress=false
                    box.isMounted=true
                    completed(Completion.successState())
                }
            }

            // Call the first pop.
            __popNode()

        } catch {
            completed(Completion.failureStateFromError(error))
        }
    }



    /// Un mounts the Box == deletes all the assembled files
    ///
    /// - Parameters:
    ///   - boxUID: the Box UID
    ///   - completed: a closure called on completion with Completion State.
    public func unMount( boxUID:String,
                         completed:@escaping (Completion)->()){
        do {
            let box = try Bartleby.registredObjectByUID(boxUID) as Box
            for node in box.localNodes{
                if let accessors=self._accessors[node.UID]{
                    for accessor in accessors{
                        accessor.willBecomeUnusable(node: node)
                    }
                }
                let assembledPath=self._mountedPath(for:node)
                try self._fileManager.removeItem(atPath: assembledPath)
            }
            box.isMounted=false
            completed(Completion.successState())
        }catch{
            completed(Completion.failureStateFromError(error))
        }
    }


    ///
    /// - Parameter node: the node
    /// - Returns: the assembled path (created if there no
    fileprivate func _mountedPath(for node:Node)->String{
        if let fileName=self._mountedFileNames[node.UID]{
            if let box=node.box{
                return box.absoluteFolderPath+"\(node.relativePath)\(fileName)"
            }
        }
        return Default.NO_PATH
    }



    /// Return is the node file has been assembled
    ///
    /// - Parameter node: the node
    /// - Returns: true if the file is available and the node not marked assemblyInProgress
    fileprivate func _isAssembled(_ node:Node)->Bool{
        if node.assemblyInProgress {
            return false
        }
        let group=AsyncGroup()
        var exists=false
        group.utility{
            exists=self._fileManager.fileExists(atPath: self._mountedPath(for: node))
        }
        group.wait()
        return exists
    }


    /// Creates a file from the node blocks.
    /// IMPORTANT: this method requires a response from the BoxDelegate
    /// The completion occurs when the BoxDelegate invokes `applyPendingChanges` on the concerned node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - progressed: a closure  to relay the Progression State
    ///   - completed: a closure called on completion with Completion State.
    internal func _assemble(node:Node,
                            progressed:@escaping (Progression)->(),
                            completed:@escaping (Completion)->()){
        do {
            if node.isAssemblable == false{
                throw BSFSError.nodeIsNotAssemblable
            }
            if let delegate = self._boxDelegate{
                delegate.nodeIsReady(node: node, proceed: {

                    // Create a new file
                    let fileName=Bartleby.createUID().lowercased()
                    self._mountedFileNames[node.UID]=fileName
                    let filePath=self._mountedPath(for: node)

                    let blocks=node.localBlocks
                    var blockPaths=[String]()
                    for block in blocks{
                        blockPaths.append(block.absolutePath)
                    }
                    self.joinChunks(from: blockPaths, to: filePath, decompress: node.compressed, decrypt: node.cryptedBlocks,externalId:node.UID, progression: { (progression) in
                        progressed(progression)
                    }, success: {
                        let completionState=Completion.successState()
                        completionState.externalIdentifier=node.UID
                        completed(completionState)
                    }, failure: { (message) in
                        let completion=Completion()
                        completion.message=message
                        completion.success=false
                        completion.externalIdentifier=node.UID
                        completed(completion)
                    })
                })
            }else{
                throw BSFSError.boxDelegateIsNotAvailable
            }

        } catch{
            completed(Completion.failureStateFromError(error))
        }
    }
    


    //MARK:  - File Level


    /// Adds a file into the box
    ///
    ///     + generate the blocks in background.
    ///     + adds the node
    ///     + the node  ref is stored in the Completon (use completion.getResultExternalReference())
    ///
    /// - Parameters:
    ///   - fileReference: the file reference
    ///   - relativePath: the relative Path of the Node
    ///   - deleteOriginal: should we delete the original?
    ///   - progressed: a closure  to relay the Progression State
    ///   - completed: a closure called on completion with Completion State (the node ref is stored in the completion.getResultExternalReference())
    public func add( fileReference:FileReference,
                     to relativePath:String,
                     deleteOriginal:Bool=false,
                     progressed:@escaping (Progression)->(),
                     completed:@escaping (Completion)->()){


        let node=Node()
        let finalState=Completion.successState()
        finalState.setExternalReferenceResult(from:node)
        
        
    }


    /// Call to replace the content of a node.
    /// This action may be refused by the BoxDelegate (check the completion state)
    ///
    /// - Parameters:
    ///   - node: the concerned node
    ///   - path: the file path
    ///   - destroyOriginalContent: should we destroy the original file
    ///   - accessor: the accessor that ask for replacement
    ///   - progressed: a closure  to relay the Progression State
    ///   - completed: a closure called on completion with Completion State.
    func wantsToReplaceContent(of node:Node,
                               withContentAt path:String,
                               destroyOriginalContent:Bool,
                               accessor:NodeAccessor,
                               progressed:@escaping (Progression)->(),
                               completed:@escaping (Completion)->()){




    }


    //MARK: Node access

    /// Any accessor to obtain access to the resource (file) of a node need to call this method.
    /// The nodeIsUsable() will be called when the file will be usable.
    ///
    /// WHY?
    /// Because there is no guarantee that the node is locally available.
    /// The application may work with a file that is available or another computer, with pending synchro.
    ///
    /// By registering as accessor, the caller will be notified as soon as possible.
    ///
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - accessor: the accessor
    public func wantsAccess(to node:Node,accessor:NodeAccessor){
        // The nodeIsUsable() will be called when the file will be usable.
        if node.authorized.contains("*") || node.authorized.contains(self._document.currentUser.UID){
            if self._accessors[node.UID] != nil {
                self._accessors[node.UID]=[NodeAccessor]()
            }
            if !self._accessors[node.UID]!.contains(where: {$0.UID==accessor.UID}){
                self._accessors[node.UID]!.append(accessor)
            }
            if self._isAssembled(node){
                self._grantAccess(to: node, accessor: accessor)
            }
        }else{
            accessor.accessRefused(to:node, explanations: NSLocalizedString("Authorization failed", tableName:"system", comment: "Authorization failed"))
        }
    }



    /// Should be called when the accessor does not need any more the node resource.
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - accessor: the accessor
    public func stopsAccessing(to node:Node,accessor:NodeAccessor){
        if let idx=self._accessors[node.UID]?.index(where: {$0.UID==accessor.UID}){
            self._accessors[node.UID]!.remove(at: idx)
        }
    }

    fileprivate func _grantAccess(to node:Node,accessor:NodeAccessor){
        accessor.nodeIsUsable(node: node, at: self._mountedPath(for:node))
    }


    //MARK: Logical actions

    /// Moves a node to another destination in the box.
    /// IMPORTANT: this method requires a response from the BoxDelegate
    /// The completion occurs when the BoxDelegate invokes `applyPendingChanges` on the concerned node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - relativePath: the relative path
    ///   - handler: the completion hanlder
    public func copy(node:Node,to relativePath:String)->(){
        _boxDelegate?.copyIsReady(node: node, to: relativePath, proceed: {
            // TODO implement
        })

    }


    /// Moves a node to another destination in the box.
    /// IMPORTANT: this method requires a response from the BoxDelegate
    /// The completion occurs when the BoxDelegate invokes `applyPendingChanges` on the concerned node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - relativePath: the relative path
    ///   - handler: the completion hanlder
    public func move(node:Node,to relativePath:String)->(){
        _boxDelegate?.moveIsReady(node: node, to: relativePath, proceed: {
            // TODO implement
        })
    }


    /// Deletes a node
    /// IMPORTANT: this method requires a response from the BoxDelegate
    /// The completion occurs when the BoxDelegate invokes `applyPendingChanges` on the concerned node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - handler: the completion Handler
    public func delete(node:Node)->(){
        _boxDelegate?.deletionIsReady(node: node, proceed: {
            /// TODO implement the deletion
        })

    }


    // MARK: - TriggerHook


    /// Called by the Document before trigger integration
    ///
    /// - Parameter trigger: the trigger
    public func triggerWillBeIntegrated(trigger:Trigger){}

    /// Called by the Document after trigger integration
    ///
    /// - Parameter trigger: the trigger
    public func triggerHasBeenIntegrated(trigger:Trigger){

        // CHECK if there are Blocks, Node actions.

        // On Nodes or Blocks check if we are concerned / allowed.

        // TODO ANALYZE
        // HOW TO DETECT MIDDLE CHANGE user is authorized durign Upload == The first block have not been received.

    }





    //MARK: - Triggered Block Level Action

    /// Downloads a Block.
    /// This occurs before triggered_create on each successfull upload.
    ///
    /// - Parameters:
    ///   - node: the node
    internal func triggered_download(block:Block){
        if block.authorized.contains(self._document.currentUser.UID) ||
            block.authorized.contains("*"){
            // We can download
            // @TODO

            // On each completion :
            // Call self._tryToAssembleNodesInProgress()

        }
    }

    // MARK: - Internal Mechanisms

    public func _tryToAssembleNodesInProgress(){
        //TODO
    }

    //MARK: - Chunk level: chunk->file and file->chunk


    public struct Chunk {
        var baseDirectory:String
        var relativePath:String
        var sha1:String
        var originalSize:Int
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
    ///   - progression: progress closure called on each discreet progression.
    ///   - success: the success closure returns a Chunk Struct to be used to create/update Block instances
    ///   - failure: the failure closure
    public func breakIntoChunk(  fileAt path:String,
                                 destination folderPath:String,
                                 chunkMaxSize:Int=10*MB,
                                 compress:Bool,
                                 encrypt:Bool,
                                 externalId:String=Default.NO_UID,
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
                let r:UInt64=l % maxSize
                var nb=n-1
                if r>0 && l >= maxSize{
                    nb += 1
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

                func __writeData(data:Data,to folderPath:String)throws->(){
                    let sha1=data.sha1
                    // Generate a Classified Block Tree.
                    let c1=PString.substr(sha1, 0, 1)
                    let c2=PString.substr(sha1, 1, 1)
                    let c3=PString.substr(sha1, 2, 1)
                    let relativeFolderPath="\(c1)/\(c2)/\(c3)/"
                    let bFolderPath=folderPath+relativeFolderPath
                    let _ = try self._fileManager.createDirectory(atPath: bFolderPath, withIntermediateDirectories: true, attributes: nil)
                    let destination=bFolderPath+"/\(sha1)"
                    let chunkRelativePath=relativeFolderPath+"\(sha1)"
                    let chunk=Chunk(baseDirectory:folderPath, relativePath: chunkRelativePath,sha1: sha1,originalSize:Int(offset))
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
                            var data=fileHandle.readData(ofLength: Int(offset))
                            if compress{
                                data = try data.compress(algorithm: .lz4)
                            }
                            if encrypt {
                                data = try Bartleby.cryptoDelegate.encryptData(data)
                            }
                            try __writeData(data: data,to:folderPath)

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
