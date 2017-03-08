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

    // MARK: -

    // Document
    fileprivate var _document:BartlebyDocument

    /// The File manager used to perform all the BSFS operation on GCD global utility queue.
    /// Note that we also use specific FileHandle at chunk level
    fileprivate let _fileManager:FileManager=FileManager()

    /// Chunk level operations
    fileprivate let _chunker:Chunker

    // The box Delegate
    fileprivate var _boxDelegate:BoxDelegate?

    // The current accessors key:node.UID, value:Array of Accessors
    fileprivate var _accessors=[String:[NodeAccessor]]()


    /// Store the blocks UIDs that need to be uploaded
    fileprivate var _toBeUploadedBlocksUIDS=[String]()

    // Store the blocks UIDs that need to be downloaded
    fileprivate var _toBeDownloadedBlocksUIDS=[String]()

    /// The downloads operations in progrees
    fileprivate var _downloadsInProgress=[DownloadBlock]()

    /// The uploads operations in progrees
    fileprivate var _uploadsInProgress=[UploadBlock]()

    /// Max Simultaneous operations ( per operation type and per bsfs instance. )
    fileprivate var _maxSimultaneousOperations=1

    // MARK: - initialization

    /// Each document has it own BSFS
    ///
    /// - Parameter document: the document instance
    required public init(in document:BartlebyDocument){
        self._document=document
        self._chunker=Chunker(fileManager: FileManager.default,
                              mode:.digestAndProcessing,
                              embeddedIn:document)
        self._boxDelegate=document
    }


    // MARK: - Persistency

    /// Serialize the local state of the BSFS
    ///
    /// - Returns: the serialized data
    public func saveState()->Data{
        let state=["toBeUploaded":self._toBeUploadedBlocksUIDS,
                   "toBeDownloaded":self._toBeDownloadedBlocksUIDS]
        if let data = try? JSONSerialization.data(withJSONObject: state){
            return data
        }
        return Data()
    }

    /// Restore the state
    ///
    /// - Parameter data: from the serialized state data
    public func restoreStateFrom(data:Data)throws->(){
        if let state = try? JSONSerialization.jsonObject(with: data) as? [String:[String]]{
            self._toBeDownloadedBlocksUIDS=state?["toBeDownloaded"] ?? [String]()
            self._toBeUploadedBlocksUIDS=state?["toBeUploaded"] ?? [String]()
        }
    }


    // MARK: - Paths

    /// The BSFS base folder path
    /// ---
    /// baseFolder/
    ///     - boxes/<boxUID>/[files]
    ///     - downloads/[files] tmp download files
    public var baseFolderPath:String{
        if self._document.metadata.appGroup != ""{
            if let url=self._fileManager.containerURL(forSecurityApplicationGroupIdentifier: self._document.metadata.appGroup){
                return url.path+"/\(_document.UID)"
            }
        }
        return Bartleby.getSearchPath(.documentDirectory)!+"/\(_document.UID)"

    }

    /// Downloads folder
    public var downloadFolderPath:String{
        return baseFolderPath+"/downloads"
    }

    /// Boxes folder
    public var boxesFolderPath:String{
        return baseFolderPath+"/boxes"
    }


    //MARK:  - Box Level

    /// Mounts the current local box == Assemble all its assemblable nodes
    /// There is no guarantee that the box is not fully up to date
    ///
    /// - Parameters:
    ///   - boxUID: the Box UID
    ///   - progressed: a closure  to relay the Progression State
    ///   - completed: a closure called on completion with Completion State.
    ///                the box UID is stored in the completion.getResultExternalReference()
    public func mount( boxUID:String,
                       progressed:@escaping (Progression)->(),
                       completed:@escaping (Completion)->()){
        do {

            let box = try Bartleby.registredObjectByUID(boxUID) as Box
            self._document.send(BoxStates.isMounting(box: box))
            if box.assemblyInProgress || box.isMounted {
                throw BSFSError.attemptToMountBoxMultipleTime(boxUID: boxUID)
            }

            var concernedNodes=[Node]()

            try? self._fileManager.createDirectory(atPath: box.nodesFolderPath, withIntermediateDirectories: true, attributes: nil)

            // Let's try to assemble as much nodes as we can.
            let nodes=box.nodes
            for node in nodes{
                let isNotAssembled = !self.isAssembled(node)
                let isAssemblable = node.isAssemblable
                if node.isAssemblable && isNotAssembled{
                    concernedNodes.append(node)
                }
            }

            box.quietChanges{
                box.assemblyProgression.totalTaskCount=concernedNodes.count
                box.assemblyProgression.currentTaskIndex=0
                box.assemblyProgression.currentPercentProgress=0
            }

            // We want to assemble the node sequentially.
            // So we will use a recursive pop method
            func __popNode(){
                if let node=concernedNodes.popLast(){
                    node.assemblyInProgress=true
                    do{
                        try self._assemble(node: node, progressed: { (progression) in
                            progressed(progression)
                        }, completed: { (completion) in
                            node.assemblyInProgress=false
                            box.assemblyProgression.currentTaskIndex += 1
                            box.assemblyProgression.currentPercentProgress=Double(box.assemblyProgression.currentTaskIndex)*Double(100)/Double(box.assemblyProgression.totalTaskCount)
                            __popNode()
                        })
                    }catch{
                        self._document.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
                        completed(Completion.failureStateFromError(error))
                    }

                }else{
                    box.assemblyInProgress=false
                    box.isMounted=true
                    let completionState=Completion.successState()
                    completionState.setExternalReferenceResult(from:box)
                    completed(completionState)
                    self._document.send(BoxStates.hasBeenMounted(box: box))
                }
            }
            // Call the first pop.
            __popNode()

        } catch {
            completed(Completion.failureStateFromError(error))
            self._document.send(BoxStates.mountingHasFailed(boxUID:boxUID,message: error.localizedDescription))
        }
    }


    public func unMountAllBoxes(){
        self._document.boxes.forEach { (box) in
            try? self.unMount(box: box)
        }
        try? self._fileManager.removeItem(atPath: self.boxesFolderPath)
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
            try self.unMount(box: box)
            completed(Completion.successState())
        }catch{
            completed(Completion.failureStateFromError(error))
        }
    }


    public func unMount(box:Box)->(){
        for node in box.nodes{
            if let accessors=self._accessors[node.UID]{
                for accessor in accessors{
                    accessor.willBecomeUnusable(node: node)
                }
            }
            let assembledPath=self.assemblyPath(for:node)
            do{
                try self._fileManager.removeItem(atPath: assembledPath)
            }catch{
            }
        }
        do{
            try self._fileManager.removeItem(atPath: box.nodesFolderPath)
        }catch{
        }
        box.isMounted=false
        box.assemblyInProgress=false
    }

    ///
    /// - Parameter node: the node
    /// - Returns: the assembled path (created if there no
    public func assemblyPath(for node:Node)->String{
        if let box=node.box{
            return self.assemblyPath(for: box)+node.relativePath
        }

        return Default.NO_PATH
    }


    public func assemblyPath(for box:Box)->String{
        return  box.nodesFolderPath
    }


    /// Return is the node file has been assembled
    ///
    /// - Parameter node: the node
    /// - Returns: true if the file is available and the node not marked assemblyInProgress
    public func isAssembled(_ node:Node)->Bool{
        if node.assemblyInProgress {
            // Return false if the assembly is in progress
            return false
        }
        let group=AsyncGroup()
        var isAssembled=false
        group.utility{
            let path=self.assemblyPath(for: node)
            isAssembled=self._fileManager.fileExists(atPath: path)
            if isAssembled{
                if let attributes = try? self._fileManager.attributesOfItem(atPath: path){
                    if let size:Int=attributes[FileAttributeKey.size] as? Int{
                        if size != node.size{
                            self._document.log("Divergent size node Size:\(node.size) fs.size: \(size) ", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
                            isAssembled=false
                        }
                    }
                }
            }
        }
        group.wait()
        return isAssembled

    }


    /// Creates a file from the node blocks.
    /// IMPORTANT: this method requires a response from the BoxDelegate
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - progressed: a closure  to relay the Progression State
    ///   - completed: a closure called on completion with Completion State.
    ///                the node UID is stored in the completion.getResultExternalReference()
    internal func _assemble(node:Node,
                            progressed:@escaping (Progression)->(),
                            completed:@escaping (Completion)->()) throws->(){


        do {
            if node.isAssemblable == false{
                throw BSFSError.nodeIsNotAssemblable
            }
            if let delegate = self._boxDelegate{
                delegate.nodeIsReady(node: node, proceed: {

                    let path=self.assemblyPath(for: node)

                    let blocks=node.blocks.sorted(by: { (rblock, lblock) -> Bool in
                        return rblock.rank < lblock.rank
                    })

                    if node.nature == .file || node.nature == .flock {

                        var blockPaths=[String]()
                        for block in blocks{
                            // The blocks are embedded in a document
                            // So we use the relative path
                            blockPaths.append(block.blockRelativePath())
                        }
                        self._chunker.joinChunksToFile(from: blockPaths,
                                                       to: path,
                                                       decompress: node.compressedBlocks,
                                                       decrypt: node.cryptedBlocks,
                                                       externalId:node.UID,
                                                       progression: { (progression) in
                                                        progressed(progression)
                        }, success: { path in

                            if node.nature == .flock{
                                //TODO

                                // FLOCK path == path

                                let completionState=Completion.successState()
                                completionState.setExternalReferenceResult(from:node)
                                completed(completionState)

                            }else{
                                // The file has been assembled
                                let completionState=Completion.successState()
                                completionState.setExternalReferenceResult(from:node)
                                completed(completionState)
                            }
                        }, failure: { (message) in
                            let completion=Completion()
                            completion.message=message
                            completion.success=false
                            completion.externalIdentifier=node.UID
                            completed(completion)
                        })
                    }else if node.nature == .alias{
                        Async.utility{
                            do{
                                if let rNodeUID=node.referentNodeUID{
                                    if let rNode = try? Bartleby.registredObjectByUID(rNodeUID) as Node{
                                        let destination=self.assemblyPath(for: rNode)
                                        try self._fileManager.createSymbolicLink(atPath: path, withDestinationPath:destination)
                                        let completionState=Completion.successState()
                                        completionState.setExternalReferenceResult(from:node)
                                        completed(completionState)
                                    }else{
                                        completed(Completion.failureState("Unable to find Alias referent node", statusCode:.expectation_Failed))
                                    }
                                }else{
                                    completed(Completion.failureState("Unable to find Alias destination", statusCode:.expectation_Failed))

                                }
                            }catch{
                                completed(Completion.failureStateFromError(error))
                            }
                        }

                    }else if node.nature == .folder{
                        Async.utility{
                            do{
                                try self._fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                                let completionState=Completion.successState()
                                completionState.setExternalReferenceResult(from:node)
                                completed(completionState)
                            }catch{
                                completed(Completion.failureStateFromError(error))
                            }
                        }

                    }
                })
            }else{
                throw BSFSError.boxDelegateIsNotAvailable
            }

        } catch{
            completed(Completion.failureStateFromError(error))
        }

    }


    //MARK:  - File Level


    /// Adds a file or all the file from o folder into the box
    ///     Flocks may be supported soon
    ///
    ///     + generate the blocks in background.
    ///     + adds the node(s)
    ///     + the first node UID is stored in the Completion (use completion.getResultExternalReference())
    ///
    /// - Parameters:
    ///   - FileReference: the file reference (Nature == file or flock)
    ///   - box: the box
    ///   - relativePath: the relative Path of the Node in the box
    ///   - deleteOriginal: should we delete the original?
    ///   - progressed: a closure  to relay the Progression State
    ///   - completed: a closure called on completion with Completion State
    ///                the node UID is stored in the completion.getResultExternalReference()
    public func add( reference:FileReference,
                     in box:Box,
                     to relativePath:String,
                     deleteOriginal:Bool=false,
                     progressed:@escaping (Progression)->(),
                     completed:@escaping (Completion)->()){

        if self._fileManager.fileExists(atPath: reference.absolutePath){

            var firstNode:Node?
            func __chunksHaveBeenCreated(chunks:[Chunk]){

                // Successful operation
                // Let's Upsert the distant models.
                // AND  the local nodes

                let groupedChunks=Chunk.groupByNodePath(chunks: chunks)

                for (nodeRelativePath,groupOfChunks) in groupedChunks{
                    // Create the new node.
                    // And add its blocks
                    let node=self._document.newObject() as Node
                    if firstNode==nil{
                        firstNode=node
                    }
                    node.quietChanges{
                        node.nature=reference.nodeNature.forNode
                        node.relativePath=relativePath///
                        node.priority=reference.priority
                        // Set up the node relative path
                        node.relativePath=nodeRelativePath

                        var cumulatedDigests=""
                        var cumulatedSize=0

                        box.quietChanges {
                            box.declaresOwnership(of: node)
                        }

                        // Let's add the blocks
                        for chunk in groupOfChunks{
                            let block=self._document.newObject() as Block
                            block.quietChanges{
                                block.rank=chunk.rank
                                block.digest=chunk.sha1
                                block.startsAt=chunk.startsAt
                                block.size=chunk.originalSize
                                block.priority=reference.priority

                            }
                            cumulatedSize += chunk.originalSize
                            cumulatedDigests += chunk.sha1
                            node.addBlock(block)
                            self._toBeUploadedBlocksUIDS.append(block.UID)
                        }
                        // Store the digest of the cumulated digests.
                        node.digest=cumulatedDigests.sha1
                        // And the node original size
                        node.size=cumulatedSize
                    }

                }


                // Delete the original
                if deleteOriginal{
                    // We consider deletion as non mandatory.
                    // So we produce only a log.
                    do {
                        try self._fileManager.removeItem(atPath: reference.absolutePath)
                    } catch  {
                        self._document.log("Deletion has failed. Path:\( reference.absolutePath)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
                    }
                }

                let finalState=Completion.successState()
                if let node=firstNode{
                    finalState.setExternalReferenceResult(from:node)
                }
                completed(finalState)

                // Call the centralized upload mechanism
                self._uploadNext()

            }
            Async.utility{
                if  reference.nodeNature == .file{
                    var isDirectory:ObjCBool=false
                    if self._fileManager.fileExists(atPath: reference.absolutePath, isDirectory: &isDirectory){
                        if isDirectory.boolValue{
                            self._chunker.breakFolderIntoChunk(filesIn: reference.absolutePath,
                                                               chunksFolderPath: box.nodesFolderPath,
                                                               progression: { (progression) in
                                                                progressed(progression)
                            }, success: { (chunks) in
                                __chunksHaveBeenCreated(chunks: chunks)
                            }, failure: { (chunks, message) in
                                completed(Completion.failureState(message, statusCode: .expectation_Failed))
                            })
                        }else{
                            /// Let's break the file into chunk.
                            self._chunker.breakIntoChunk( fileAt: reference.absolutePath,
                                                          relativePath:relativePath,
                                                          chunksFolderPath: box.nodesFolderPath,
                                                          chunkMaxSize:reference.chunkMaxSize,
                                                          compress: reference.compressed,
                                                          encrypt: reference.crypted,
                                                          progression: { (progression) in
                                                            progressed(progression)
                            }
                                , success: { (chunks) in
                                    __chunksHaveBeenCreated(chunks: chunks)

                            }, failure: { (message) in
                                completed(Completion.failureState(message, statusCode: .expectation_Failed))
                            })
                        }
                    }else{
                        let message=NSLocalizedString("Unexisting path: ", tableName:"system", comment: "Unexisting path: ")+reference.absolutePath
                        completed(Completion.failureState(message, statusCode: .expectation_Failed))
                    }
                }

                if  reference.nodeNature == .flock{
                    // @TODO
                }

            }


        }else{
            completed(Completion.failureState(NSLocalizedString("Reference Not Found!", tableName:"system", comment: "Reference Not Found!")+" \(reference.absolutePath)", statusCode: .not_Found))
        }

    }




    /// Call to replace the content of a file node with a given file. (alias, flocks, folders are not supported)
    /// This action may be refused by the BoxDelegate (check the completion state)
    ///
    /// Delta Optimization:
    /// We first compute the `deltaChunks` to determine if some Blocks can be preserved
    /// Then we `breakIntoChunk` the chunks that need to be chunked.
    ///
    ///
    /// - Parameters:
    ///   - node: the concerned node
    ///   - path: the file path
    ///   - deleteOriginal: should we destroy the original file
    ///   - accessor: the accessor that ask for replacement
    ///   - progressed: a closure  to relay the Progression State
    ///   - completed: a closure called on completion with Completion State.
    ///                the node UID is stored in the completion.getResultExternalReference()
    func replaceContent(of node:Node,
                        withContentAt path:String,
                        deleteOriginal:Bool,
                        accessor:NodeAccessor,
                        progressed:@escaping (Progression)->(),
                        completed:@escaping (Completion)->()){

        if node.nature == .file{

            if node.authorized.contains(self._document.currentUser.UID) ||
                node.authorized.contains("*"){

                var isDirectory:ObjCBool=false
                if self._fileManager.fileExists(atPath:path, isDirectory: &isDirectory){
                    if isDirectory.boolValue{
                        completed(Completion.failureState(NSLocalizedString("Forbidden! Replacement is restricted to single files not folder", tableName:"system", comment: "Forbidden! Replacement is restricted to single files not folder"), statusCode: .forbidden))
                    }else{

                        if let box=node.box{
                            let analyzer=DeltaAnalyzer(embeddedIn: self._document)

                            //////////////////////////////
                            // #1 We first compute the `deltaChunks` to determine if some Blocks can be preserved
                            //////////////////////////////

                            analyzer.deltaChunks(fromFileAt: path, to: node, using: self._fileManager, completed: { (toBePreserved, toBeDeleted) in


                                /// delete the blocks to be deleted
                                for chunk in toBeDeleted{
                                    if let block=self._findBlockMatching(chunk: chunk){
                                        self.deleteBlockFile(block)
                                    }
                                }

                                /////////////////////////////////
                                // #2 Then we `breakIntoChunk` the chunks that need to be chunked.
                                /////////////////////////////////
                                self._chunker.breakIntoChunk(fileAt: path,
                                                             relativePath: node.relativePath,
                                                             chunksFolderPath: box.nodesFolderPath,
                                                             compress: node.compressedBlocks,
                                                             encrypt: node.cryptedBlocks,
                                                             excludeChunks:toBePreserved,
                                                             progression: { (progression) in
                                                                progressed(progression)
                                }
                                    , success: { (chunks) in

                                        // Successful operation
                                        // Let's Upsert the node.
                                        // AND create the local node

                                        node.quietChanges{

                                            var cumulatedDigests=""
                                            var cumulatedSize=0

                                            // Let's add the blocks
                                            for chunk in chunks{
                                                var block:Block?
                                                if let b=self._findBlockMatching(chunk: chunk){
                                                    block=b
                                                    block?.needsToBeCommitted()
                                                }else{
                                                    block=self._document.newObject() as Block
                                                    node.quietChanges {
                                                        block!.quietChanges {
                                                            node.addBlock(block!)
                                                        }
                                                    }
                                                }

                                                block!.quietChanges{
                                                    block!.rank=chunk.rank
                                                    block!.digest=chunk.sha1
                                                    block!.startsAt=chunk.startsAt
                                                    block!.size=chunk.originalSize
                                                    block!.priority=node.priority
                                                }
                                                cumulatedDigests += chunk.sha1
                                                cumulatedSize += chunk.originalSize
                                            }

                                            // Store the digest of the cumulated digests.
                                            node.digest=cumulatedDigests.sha1
                                            // And the node original size
                                            node.size=cumulatedSize
                                        }

                                        // Mark the node to be committed
                                        node.needsToBeCommitted()

                                        // Delete the original
                                        Async.utility{
                                            if deleteOriginal{
                                                // We consider deletion as non mandatory.
                                                // So we produce only a log.
                                                do {
                                                    try self._fileManager.removeItem(atPath: path)
                                                } catch  {
                                                    self._document.log("Deletion has failed. Path:\( path)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
                                                }
                                            }
                                        }

                                        let finalState=Completion.successState()
                                        finalState.setExternalReferenceResult(from:node)
                                        completed(finalState)

                                        // Call the centralized upload mechanism
                                        self._uploadNext()

                                }, failure: { (message) in
                                    completed(Completion.failureState(message, statusCode: .expectation_Failed))
                                })

                            }, failure: { (message) in
                                completed(Completion.failureState(message, statusCode: .expectation_Failed))
                            })

                        }else{
                            completed(Completion.failureState(NSLocalizedString("Forbidden! Box not found", tableName:"system", comment: "Forbidden! Box not found"), statusCode: .forbidden))
                        }
                    }
                }
            }else{
                completed(Completion.failureState(NSLocalizedString("Forbidden! Replacement refused", tableName:"system", comment: "Forbidden! Replacement refused"), statusCode: .forbidden))
            }

        }else{
            completed(Completion.failureState("\(node.nature)", statusCode: .precondition_Failed))
        }
    }


    //MARK: - Node Level


    //MARK: Access

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
            if self.isAssembled(node){
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

    /// Grants the access
    ///
    /// - Parameters:
    ///   - node: to the node
    ///   - accessor: for an Accessor
    fileprivate func _grantAccess(to node:Node,accessor:NodeAccessor){
        accessor.fileIsAvailable(for:node, at: self.assemblyPath(for:node))
    }


    //MARK: Logical actions

    /// Moves a node to another destination in the box.
    /// IMPORTANT: this method requires a response from the BoxDelegate
    /// The completion occurs when the BoxDelegate invokes `applyPendingChanges` on the concerned node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - relativePath: the relative path
    ///   - completed: a closure called on completion with Completion State.
    ///                the copied node UID is stored in the completion.getResultExternalReference()
    public func copy(node:Node,to relativePath:String,completed:@escaping (Completion)->())->(){

        // The nodeIsUsable() will be called when the file will be usable.
        if node.authorized.contains("*") || node.authorized.contains(self._document.currentUser.UID){
            self._boxDelegate?.copyIsReady(node: node, to: relativePath, proceed: {
                if let box=node.box{
                    Async.utility{
                        do{
                            try self._fileManager.copyItem(atPath: self.assemblyPath(for: node), toPath:box.nodesFolderPath+relativePath)

                            // Create the copiedNode
                            let copiedNode=self._document.newObject() as Node

                            copiedNode.quietChanges{
                                box.declaresOwnership(of: copiedNode)
                                try? copiedNode.mergeWith(node)// merge
                                copiedNode.relativePath=relativePath // Thats it!
                            }
                            let finalState=Completion.successState()
                            finalState.setExternalReferenceResult(from:copiedNode)
                            completed(finalState)
                        }catch{
                            completed(Completion.failureStateFromError(error))

                        }
                    }
                }else{
                    completed(Completion.failureState(NSLocalizedString("Forbidden! Box not found", tableName:"system", comment: "Forbidden! Box not found"), statusCode: .forbidden))
                }



            })
        }else{
            completed(Completion.failureState(NSLocalizedString("Authorization failed", tableName:"system", comment: "Authorization failed"), statusCode: .unauthorized))
        }

    }


    /// Moves a node to another destination in the box.
    /// IMPORTANT: this method requires a response from the BoxDelegate
    /// The completion occurs when the BoxDelegate invokes `applyPendingChanges` on the concerned node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - relativePath: the relative path
    ///   - completed: a closure called on completion with Completion State.
    ///                the copied node UID is stored in the completion.getResultExternalReference()
    public func move(node:Node,to relativePath:String,completed:@escaping (Completion)->())->(){

        // The nodeIsUsable() will be called when the file will be usable.
        if node.authorized.contains("*") || node.authorized.contains(self._document.currentUser.UID){
            self._boxDelegate?.moveIsReady(node: node, to: relativePath, proceed: {
                node.relativePath=relativePath
                let finalState=Completion.successState()
                finalState.setExternalReferenceResult(from:node)
                completed(finalState)
            })

        }else{
            completed(Completion.failureState(NSLocalizedString("Authorization failed", tableName:"system", comment: "Authorization failed"), statusCode: .unauthorized))
        }

    }


    /// Deletes a node
    /// IMPORTANT: this method requires a response from the BoxDelegate
    /// The completion occurs when the BoxDelegate invokes `applyPendingChanges` on the concerned node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - completed: a closure called on completion with Completion State.
    public func delete(node:Node,completed:@escaping (Completion)->())->(){

        // The nodeIsUsable() will be called when the file will be usable.
        if node.authorized.contains("*") || node.authorized.contains(self._document.currentUser.UID){
            self._boxDelegate?.deletionIsReady(node: node, proceed: {

                /// TODO implement the deletion
                /// Delete the node
                /// Delete the files if necessary
                /// Refuse to delete folder containing nodes

                completed(Completion.successState())
            })
        }else{
            completed(Completion.failureState(NSLocalizedString("Authorization failed", tableName:"system", comment: "Authorization failed"), statusCode: .unauthorized))
        }

    }


    /// Create Folders
    /// - Parameters:
    ///   - relativePath: the relative Path
    ///   - completed: a closure called on completion with Completion State.
    public func createFolder(in box:Box,at relativePath:String,completed:@escaping (Completion)->())->(){

        /// TODO implement
        /// TEST IF THERE IS A LOCAL FOLDER
        /// Create the folder
        /// Create the NODE

        completed(Completion.successState())


    }



    /// Creates the Alias
    /// - Parameters:
    ///   - node: the node to be aliased
    ///   - relativePath: the destination relativePath
    ///   - completed: a closure called on completion with Completion State.
    public func createAlias(of node:Node,to relativePath:String, completed:@escaping (Completion)->())->(){

        // The nodeIsUsable() will be called when the file will be usable.
        if node.authorized.contains("*") || node.authorized.contains(self._document.currentUser.UID){
            // TODO
            /// Create the Alias
            /// Create the NODE
        }else{
            completed(Completion.failureState(NSLocalizedString("Authorization failed", tableName:"system", comment: "Authorization failed"), statusCode: .unauthorized))
        }

    }



    // MARK: - TriggerHook


    /// Called by the Document before trigger integration
    ///
    /// - Parameter trigger: the trigger
    public func triggerWillBeIntegrated(trigger:Trigger){
        // We have nothing to do.
    }

    /// Called by the Document after trigger integration
    ///
    /// - Parameter trigger: the trigger
    public func triggerHasBeenIntegrated(trigger:Trigger){

        // CHECK if there are Blocks, Node actions.

        // UploadBlock -> download if allowed triggered_download
        // DeleteBlock, DeleteBlocks -> delete the block immediately
        // UpsertBlock, UpsertBlocks -> nothing to do

        // On Nodes or Blocks check if we are concerned / allowed.

    }

    //MARK: - Triggered Block Level Action

    /// Downloads a Block.
    /// This occurs before triggered_create on each successfull upload.
    ///
    /// - Parameters:
    ///   - node: the node
    internal func triggered_download(block:Block){
        if let node=block.node{
            if node.authorized.contains(self._document.currentUser.UID) ||
                node.authorized.contains("*"){
                self._toBeDownloadedBlocksUIDS.append(block.UID)
                self._downloadNext()
            }
        }
    }


    //MARK: - Block Level


    /// Will upload the next block if possible
    /// Respecting the priorities
    internal func _uploadNext()->(){
        if self._uploadsInProgress.count<_maxSimultaneousOperations{

            do{
                let uploadableBlocks = try self._toBeUploadedBlocksUIDS.map({ (UID) -> Block in
                    return try Bartleby.registredObjectByUID(UID) as Block
                })

                let priorizedBlocks=uploadableBlocks.sorted { (l, r) -> Bool in
                    return l.priority>r.priority
                }

                var toBeUploaded:Block?
                for candidate in priorizedBlocks{
                    if self._toBeUploadedBlocksUIDS.contains(candidate.UID) && candidate.uploadInProgress==false {
                        toBeUploaded=candidate
                        break
                    }
                }

                func __removeBlockFromList(_ block:Block){
                    block.uploadInProgress=false

                    if let idx=self._toBeUploadedBlocksUIDS.index(where:{ $0 == block.UID}){
                        self._toBeUploadedBlocksUIDS.remove(at: idx)
                    }

                    if let idx=self._uploadsInProgress.index(where:{ $0.blockUID == block.UID}){
                        self._uploadsInProgress.remove(at: idx)
                    }
                }

                if toBeUploaded != nil{
                    if let block = try? Bartleby.registredObjectByUID(toBeUploaded!.UID) as Block {
                        block.uploadInProgress=true
                        let uploadOperation=UploadBlock(block: block, documentUID: self._document.UID, sucessHandler: { (context) in
                            __removeBlockFromList(block)
                            self._uploadNext()

                        }, failureHandler: { (context) in
                            __removeBlockFromList(block)
                        }, cancelationHandler: {
                            __removeBlockFromList(block)
                        })
                        self._uploadsInProgress.append(uploadOperation)

                    }else{
                        self._document.log("Block not found \(toBeUploaded!.UID)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
                    }
                }

            } catch{
                self._document.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
            }
        }

    }

    /// Will download the next block if possible
    /// Respecting the priorities
    internal func _downloadNext()->(){

        if self._downloadsInProgress.count<self._maxSimultaneousOperations{
            do{

                let downloadableBlocks = try self._toBeDownloadedBlocksUIDS.map({ (UID) -> Block in
                    return try Bartleby.registredObjectByUID(UID) as Block
                })


                let priorizedBlocks=downloadableBlocks.sorted { (l, r) -> Bool in
                    return l.priority>r.priority
                }

                var toBeDownloaded:Block?
                for candidate in priorizedBlocks{
                    if self._toBeDownloadedBlocksUIDS.contains(candidate.UID) && candidate.downloadInProgress==false {
                        toBeDownloaded=candidate
                        break
                    }
                }

                func __removeBlockFromList(_ block:Block){
                    block.downloadInProgress=false
                    if let idx=self._toBeDownloadedBlocksUIDS.index(where:{ $0 == block.UID }){
                        self._toBeDownloadedBlocksUIDS.remove(at: idx)
                    }

                    if let idx=self._downloadsInProgress.index(where:{ $0.blockUID == block.UID }){
                        self._downloadsInProgress.remove(at: idx)
                    }
                }

                if toBeDownloaded != nil{
                    if let block = try? Bartleby.registredObjectByUID(toBeDownloaded!.UID) as Block {
                        block.downloadInProgress=true
                        let downLoadOperation=DownloadBlock(block: block, documentUID: self._document.UID, sucessHandler: { (tempURL) in
                            var data:Data?
                            var sha1=""
                            Async.utility{
                                do{
                                    data=try Data(contentsOf:tempURL)
                                    sha1=data!.sha1
                                }catch{
                                    self._document.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
                                }
                                }.main{
                                    do{
                                        if sha1==block.digest{
                                            try self._document.put(data: data!, identifiedBy:sha1)
                                            __removeBlockFromList(block)
                                            self._uploadNext()
                                        }else{
                                            self._document.log("Digest of the block is not matching", file: #file, function: #function, line: #line, category: Default.LOG_SECURITY, decorative: false)
                                        }
                                    }catch{
                                        self._document.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
                                    }
                            }
                        }, failureHandler: { (context) in
                            __removeBlockFromList(block)
                        }, cancelationHandler: {
                            __removeBlockFromList(block)
                        })
                        self._downloadsInProgress.append(downLoadOperation)
                    }else{
                        self._document.log("Block not found \(toBeDownloaded!.UID)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
                    }
                }
                
            }catch{
                self._document.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
            }
            
        }
    }
    
    
    /// Return the block matching the Chunk if found
    ///
    /// - Parameter chunk: the chunk
    /// - Returns: the block.
    internal func _findBlockMatching(chunk:Chunk) -> Block? {
        if let idx=self._document.blocks.index(where: { (block) -> Bool in
            return block.digest==chunk.sha1
        }){
            return self._document.blocks[idx]
        }
        return nil
    }
    
    ///
    ///
    /// - Parameter block: the block or the Block reference
    
    
    ///  Delete a Block its Block, raw file
    ///
    /// - Parameters:
    ///   - block: the block or the Block
    open func deleteBlockFile(_ block:Block) {
        if let node:Node = block.firstRelation(Relationship.ownedBy){
            node.removeRelation(Relationship.owns, to: block)
            node.numberOfBlocks -= 1
        }else{
            self._document.log("Block's node not found (block.UID:\(block.UID)", file: #file, function: #function, line: #line, category: Default.LOG_FAULT, decorative: false)
        }
        self._document.blocks.removeObject(block)
        do{
            try self._document.removeBlock(with: block.digest)
        }catch{
            self._document.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
        }
        
    }
}
