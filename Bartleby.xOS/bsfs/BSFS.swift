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

    // MARK: - Variables

    // Document
    fileprivate unowned var _document:BartlebyDocument

    /// The File manager used to perform all the BSFS operation on GCD global utility queue.
    /// Note that we also use specific FileHandle at chunk level
    fileprivate let _fileManager:FileManager=FileManager()

    /// Chunk level operations
    fileprivate let _chunker:Chunker

    // The box Delegate
    fileprivate var _boxDelegate:BoxDelegate?

    // The current accessors key:node.UID, value:Array of Accessors
    fileprivate var _accessors=[String:[NodeAccessor]]()

    /// The shadow container Reflects the local state
    /// We use the shadows to store the upload, download and assembly state
    /// And to determine the delta operations.
    fileprivate var _localContainer:Container=Container()

    /// Returns the local nodes shadows
    var localBoxesShadows:[BoxShadow] { return self._localContainer.boxes }

    /// Returns the local nodes shadows
    var localNodesShadows:[NodeShadow] { return self._localContainer.nodes }

    /// Returns the local blocks shadows
    var localBlocksShadows:[BlockShadow] { return self._localContainer.blocks }

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
                              cryptoKey:Bartleby.configuration.KEY,
                              cryptoSalt:Bartleby.configuration.SHARED_SALT,
                              mode:.digestAndProcessing
            ,embeddedIn:document)
    }

    // MARK: - Persistency

    /// Serialize the local state of the BSFS
    ///
    /// - Returns: the serialized data
    public func saveState()->Data{
        return _localContainer.serialize()
    }

    /// Restore the state
    ///
    /// - Parameter data: from the serialized state data
    public func restoreStateFrom(data:Data)throws->(){
        let _ = try self._localContainer.updateData(data, provisionChanges: false)
    }


    // MARK: - Paths

    /// The BSFS base folder path
    /// ---
    /// baseFolder/
    ///     - blocks/ all the crypted compressed blocks (classifyed per 3 level of folders)
    ///     - tmp/ downloads in progress
    public var baseFolderPath:String{
        return NSHomeDirectory()+"/.bsfs/\(_document.UID)" //@*
    }

    public var blocksFolderPath:String{
        return self.baseFolderPath+"/blocks"//@*
    }

    /// The path correspond is where the Boxes assemble their files.
    /// The files are destroyed when a box is unmounted.
    public var boxesFolderPath:String{
        return Bartleby.getSearchPath(.documentDirectory)!+"/boxes"
    }

    //MARK:  - Box Level

    /// New Box Factory
    /// Includes shadowing
    /// - Returns: returns the box
    public func newLocalBox()->Box{
        let box=self._document.newBox()
        let _=self._shadowBoxIfNecessary(box: box)
        return box
    }

    /// Mounts the current local box == Assemble all its assemblable nodes
    /// There is no guarantee that the box is not fully up to date
    ///
    /// - Parameters:
    ///   - boxUID: the Box UID
    ///   - progressed: a closure  to relay the Progression State
    ///   - completed: a closure called on completion with Completion State.
    ///                the box ref is stored in the completion.getResultExternalReference()
    public func mount( boxUID:String,
                       progressed:@escaping (Progression)->(),
                       completed:@escaping (Completion)->()){
        do {

            let box = try Bartleby.registredObjectByUID(boxUID) as Box

            if box.assemblyInProgress || box.isMounted {
                throw BSFSError.attemptToMountBoxMultipleTime(boxUID: boxUID)
            }

            var concernedNodes=[Node]()

            try? self._fileManager.createDirectory(atPath: box.nodesFolderPath, withIntermediateDirectories: true, attributes: nil)

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
                    let completionState=Completion.successState()
                    completionState.setExternalReferenceResult(from:box)
                    completed(completionState)
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
                let assembledPath=self._assemblyPath(for:node)
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
    fileprivate func _assemblyPath(for node:Node)->String{
        if !(node is Shadow){
            if let box=node.box{
                return self.assemblyPath(for: box)
            }

        }
        return Default.NO_PATH
    }


    public func assemblyPath(for box:Box)->String{
        return  box.nodesFolderPath//@*
    }


    /// Return is the node file has been assembled
    ///
    /// - Parameter node: the node
    /// - Returns: true if the file is available and the node not marked assemblyInProgress
    fileprivate func _isAssembled(_ node:Node)->Bool{
        if node is Shadow{
            return false
        }else{
            if node.assemblyInProgress {
                return false
            }
            let group=AsyncGroup()
            var exists=false
            group.utility{
                exists=self._fileManager.fileExists(atPath: self._assemblyPath(for: node))
            }
            group.wait()
            return exists
        }
    }


    /// Creates a file from the node blocks.
    /// IMPORTANT: this method requires a response from the BoxDelegate
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - progressed: a closure  to relay the Progression State
    ///   - completed: a closure called on completion with Completion State.
    ///                the node ref is stored in the completion.getResultExternalReference()
    internal func _assemble(node:Node,
                            progressed:@escaping (Progression)->(),
                            completed:@escaping (Completion)->()){

        if node is Shadow{
            completed(Completion.failureState(NSLocalizedString("Shadows are forbidden!", tableName:"system", comment: "Shadows are forbidden!"), statusCode: .forbidden))
        }else{
            do {
                if node.isAssemblable == false{
                    throw BSFSError.nodeIsNotAssemblable
                }
                if let delegate = self._boxDelegate{
                    delegate.nodeIsReady(node: node, proceed: {

                        let path=self._assemblyPath(for: node)
                        let blocks=node.localBlocks

                        if node.nature == .file || node.nature == .flock {

                            var blockPaths=[String]()
                            for block in blocks{
                                blockPaths.append(block.absolutePath)
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
                                            let destination=self._assemblyPath(for: rNode)
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
    }


    /// Creates and store a local BoxShadow from its distant pair
    ///
    /// - Parameter box: the box
    /// - Returns: the Shadow
    func _shadowBoxIfNecessary(box:Box)->BoxShadow{
        if let idx=self._localContainer.boxes.index(where: { (boxShadow) -> Bool in
            return box.UID == boxShadow.UID
        }){
            return self._localContainer.boxes[idx]
        }else{
            // Let's add the boxShadow
            let boxShadow=BoxShadow.from(box)
            self._localContainer.boxes.append(boxShadow)
            return boxShadow
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
    ///   - FileReference: the file reference (Nature == file or flock)
    ///   - box: the box
    ///   - relativePath: the relative Path of the Node in the box
    ///   - deleteOriginal: should we delete the original?
    ///   - progressed: a closure  to relay the Progression State
    ///   - completed: a closure called on completion with Completion State
    ///                the node ref is stored in the completion.getResultExternalReference()
    public func add( reference:FileReference,
                     in box:Box,
                     to relativePath:String,
                     deleteOriginal:Bool=false,
                     progressed:@escaping (Progression)->(),
                     completed:@escaping (Completion)->()){

        if box is Shadow{
            completed(Completion.failureState(NSLocalizedString("Shadows are forbidden!", tableName:"system", comment: "Shadows are forbidden!"), statusCode: .forbidden))
        }else{

            let _ = self._shadowBoxIfNecessary(box: box)

            if self._fileManager.fileExists(atPath: reference.absolutePath){

                /// Let's break the file into chunk.
                self._chunker.breakIntoChunk( fileAt: reference.absolutePath,
                                              relativePath:relativePath,
                                              chunksFolderPath: box.nodesFolderPath, // @? useless if embedded
                                              chunkMaxSize:reference.chunkMaxSize,
                                              compress: reference.compressed,
                                              encrypt: reference.crypted,
                                              progression: { (progression) in
                                                progressed(progression)
                }
                    , success: { (chunks) in

                        // Successful operation
                        // Let's Upsert the distant models.
                        // AND create their local Shadows

                        // Create the new node.
                        // And add its blocks
                        let node=self._document.newNode()
                        node.silentGroupedChanges {
                            node.boxUID=box.UID
                            node.nature=reference.nodeNature.forNode
                            node.relativePath=relativePath
                            node.priority=reference.priority

                            var cumulatedDigests=""
                            // Let's add the blocks
                            for chunk in chunks{
                                let block=self._document.newBlock()
                                block.silentGroupedChanges {
                                    block.nodeUID=node.UID
                                    block.rank=chunk.rank
                                    block.digest=chunk.sha1
                                    block.startsAt=chunk.startsAt
                                    block.size=chunk.originalSize
                                    block.priority=reference.priority
                                }

                                cumulatedDigests += chunk.sha1

                                let blockShadow=self._shadowBlockIfNecessary(block: block)
                                blockShadow.needsUpload=true // Mark the upload requirement on the Block shadow
                                node.blocksUIDS.append(block.UID)
                                self._localContainer.blocks.append(blockShadow)
                            }
                            // Store the digest of the cumulated digests.
                            node.digest=cumulatedDigests.sha1
                            let nodeShadow=self._shadowNodeIfNecessary(node: node)
                            self._localContainer.nodes.append(nodeShadow)
                        }

                        // Delete the original
                        Async.utility{
                            if deleteOriginal{
                                // We consider deletion as non mandatory.
                                // So we produce only a log.
                                do {
                                    try self._fileManager.removeItem(atPath: reference.absolutePath)
                                } catch  {
                                    self._document.log("Deletion has failed. Path:\( reference.absolutePath)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
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

            }else{
                completed(Completion.failureState(NSLocalizedString("Reference Not Found!", tableName:"system", comment: "Reference Not Found!")+" \(reference.absolutePath)", statusCode: .not_Found))
            }
        }
    }




    /// Call to replace the content of a node.
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
    ///                the node ref is stored in the completion.getResultExternalReference()
    func replaceContent(of node:Node,
                        withContentAt path:String,
                        deleteOriginal:Bool,
                        accessor:NodeAccessor,
                        progressed:@escaping (Progression)->(),
                        completed:@escaping (Completion)->()){

        if node.nature == .file{
            if node is Shadow{
                completed(Completion.failureState(NSLocalizedString("Shadows are forbidden!", tableName:"system", comment: "Shadows are forbidden!"), statusCode: .forbidden))
            }else{
                if node.authorized.contains(self._document.currentUser.UID) ||
                    node.authorized.contains("*"){

                    if let box=node.box{
                        let analyzer=DeltaAnalyzer(cryptoKey:Bartleby.configuration.KEY,cryptoSalt:Bartleby.configuration.SHARED_SALT)

                        //////////////////////////////
                        // #1 We first compute the `deltaChunks` to determine if some Blocks can be preserved
                        //////////////////////////////

                        analyzer.deltaChunks(fromFileAt: path, to: node, using: self._fileManager, completed: { (toBePreserved, toBeDeleted) in


                            /// delete the blocks to be deleted
                            for chunk in toBeDeleted{
                                if let block=self._findBlockMatching(chunk: chunk){
                                    self._deleteBlock(block)
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
                                    // AND create their local Shadows

                                    node.silentGroupedChanges {

                                        var cumulatedDigests=""
                                        // Let's add the blocks
                                        for chunk in chunks{
                                            var block:Block?
                                            if let b=self._findBlockMatching(chunk: chunk){
                                                block=b
                                                block?.commitRequired()
                                            }else{
                                                block=self._document.newBlock()
                                            }

                                            block!.silentGroupedChanges {
                                                block!.nodeUID=node.UID
                                                block!.rank=chunk.rank
                                                block!.digest=chunk.sha1
                                                block!.startsAt=chunk.startsAt
                                                block!.size=chunk.originalSize
                                                block!.priority=node.priority
                                            }
                                            cumulatedDigests += chunk.sha1

                                            let blockShadow=self._shadowBlockIfNecessary(block:  block!)
                                            blockShadow.needsUpload=true // Mark the upload requirement on the Block shadow
                                            node.blocksUIDS.append( block!.UID)
                                            if !self._localContainer.blocks.contains(where:{ $0.UID == blockShadow.UID }){
                                                self._localContainer.blocks.append(blockShadow)
                                            }
                                        }

                                        // Store the digest of the cumulated digests.
                                        node.digest=cumulatedDigests.sha1

                                        // Update the node Shadow
                                        let nodeShadow=self._shadowNodeIfNecessary(node: node)
                                        nodeShadow.silentGroupedChanges {
                                            for k in node.exposedKeys{
                                                try? nodeShadow.setExposedValue(node.getExposedValueForKey(k), forKey: k)
                                            }
                                            try? nodeShadow.setShadowUID(UID: node.UID)
                                        }
                                    }

                                    // Mark the node to be committed
                                    node.commitRequired()

                                    // Delete the original
                                    Async.utility{
                                        if deleteOriginal{
                                            // We consider deletion as non mandatory.
                                            // So we produce only a log.
                                            do {
                                                try self._fileManager.removeItem(atPath: path)
                                            } catch  {
                                                self._document.log("Deletion has failed. Path:\( path)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
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
                }else{
                    completed(Completion.failureState(NSLocalizedString("Forbidden! Replacement refused", tableName:"system", comment: "Forbidden! Replacement refused"), statusCode: .forbidden))
                }
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
        if node is Shadow{
            accessor.accessRefused(to: node, explanations: NSLocalizedString("Shadows are forbidden!", tableName:"system", comment: "Shadows are forbidden!"))
        }else{
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
        if node is Shadow{
            accessor.accessRefused(to: node, explanations: NSLocalizedString("Shadows are forbidden!", tableName:"system", comment: "Shadows are forbidden!"))
        }else{
            accessor.fileIsAvailable(for:node, at: self._assemblyPath(for:node))
        }
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
    ///                the copied node ref is stored in the completion.getResultExternalReference()
    public func copy(node:Node,to relativePath:String,completed:@escaping (Completion)->())->(){
        if node is Shadow{
            completed(Completion.failureState(NSLocalizedString("Shadows are forbidden!", tableName:"system", comment: "Shadows are forbidden!"), statusCode: .forbidden))
        }else{
            // The nodeIsUsable() will be called when the file will be usable.
            if node.authorized.contains("*") || node.authorized.contains(self._document.currentUser.UID){
                _boxDelegate?.copyIsReady(node: node, to: relativePath, proceed: {
                    if let box=node.box{
                        Async.utility{
                            do{
                                try self._fileManager.copyItem(atPath: self._assemblyPath(for: node), toPath:box.nodesFolderPath+relativePath)

                                // Create the copiedNode
                                let copiedNode=self._document.newNode()
                                copiedNode.silentGroupedChanges {
                                    try? copiedNode.mergeWith(node)// merge
                                    copiedNode.relativePath=relativePath // Thats it!
                                }
                                // Create the copiedNode shadow
                                let nodeShadow=self._shadowNodeIfNecessary(node: copiedNode)
                                self._localContainer.nodes.append(nodeShadow)

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
    }


    /// Moves a node to another destination in the box.
    /// IMPORTANT: this method requires a response from the BoxDelegate
    /// The completion occurs when the BoxDelegate invokes `applyPendingChanges` on the concerned node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - relativePath: the relative path
    ///   - completed: a closure called on completion with Completion State.
    ///                the copied node ref is stored in the completion.getResultExternalReference()
    public func move(node:Node,to relativePath:String,completed:@escaping (Completion)->())->(){
        if node is Shadow{
            completed(Completion.failureState(NSLocalizedString("Shadows are forbidden!", tableName:"system", comment: "Shadows are forbidden!"), statusCode: .forbidden))
        }else{
            // The nodeIsUsable() will be called when the file will be usable.
            if node.authorized.contains("*") || node.authorized.contains(self._document.currentUser.UID){
                _boxDelegate?.moveIsReady(node: node, to: relativePath, proceed: {
                    node.relativePath=relativePath
                    let finalState=Completion.successState()
                    finalState.setExternalReferenceResult(from:node)
                    completed(finalState)
                })

            }else{
                completed(Completion.failureState(NSLocalizedString("Authorization failed", tableName:"system", comment: "Authorization failed"), statusCode: .unauthorized))
            }
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
        if node is Shadow{
            completed(Completion.failureState(NSLocalizedString("Shadows are forbidden!", tableName:"system", comment: "Shadows are forbidden!"), statusCode: .forbidden))
        }else{
            // The nodeIsUsable() will be called when the file will be usable.
            if node.authorized.contains("*") || node.authorized.contains(self._document.currentUser.UID){
                _boxDelegate?.deletionIsReady(node: node, proceed: {

                    /// TODO implement the deletion
                    /// Delete the node
                    /// Delete its shadow
                    /// Delete the files if necessary
                    /// Refuse to delete folder containing nodes

                    completed(Completion.successState())
                })
            }else{
                completed(Completion.failureState(NSLocalizedString("Authorization failed", tableName:"system", comment: "Authorization failed"), statusCode: .unauthorized))
            }
        }
    }


    /// Create Folders
    /// - Parameters:
    ///   - relativePath: the relative Path
    ///   - completed: a closure called on completion with Completion State.
    public func createFolder(in box:Box,at relativePath:String,completed:@escaping (Completion)->())->(){
        if box is Shadow{
            completed(Completion.failureState(NSLocalizedString("Shadows are forbidden!", tableName:"system", comment: "Shadows are forbidden!"), statusCode: .forbidden))
        }else{
            /// TODO implement
            /// TEST IF THERE IS A LOCAL FOLDER
            /// Create the folder
            /// Create the NODE
            /// Create its shadow

            completed(Completion.successState())
        }

    }



    /// Creates the Alias
    /// - Parameters:
    ///   - node: the node to be aliased
    ///   - relativePath: the destination relativePath
    ///   - completed: a closure called on completion with Completion State.
    public func createAlias(of node:Node,to relativePath:String, completed:@escaping (Completion)->())->(){
        if node is Shadow{
            completed(Completion.failureState(NSLocalizedString("Shadows are forbidden!", tableName:"system", comment: "Shadows are forbidden!"), statusCode: .forbidden))
        }else{
            // The nodeIsUsable() will be called when the file will be usable.
            if node.authorized.contains("*") || node.authorized.contains(self._document.currentUser.UID){
                // TODO
                /// Create the Alias
                /// Create the NODE
                /// Create its shadow
            }else{
                completed(Completion.failureState(NSLocalizedString("Authorization failed", tableName:"system", comment: "Authorization failed"), statusCode: .unauthorized))
            }
        }
    }


    /// Creates and store a local NodeShadow from its distant pair
    ///
    /// - Parameter node: the Node
    /// - Returns: the block shadow
    func _shadowNodeIfNecessary(node:Node)->NodeShadow{
        if let idx=self._localContainer.nodes.index(where: { (nodeShadow) -> Bool in
            return nodeShadow.UID == node.UID
        }){
            return self._localContainer.nodes[idx]
        }else{
            // Let's add the nodeShadow
            let nodeShadow=NodeShadow.from(node)
            self._localContainer.nodes.append(nodeShadow)
            return nodeShadow
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
                let shadowBlock=self._shadowBlockIfNecessary(block: block)
                shadowBlock.needsDownload=true
                self._downloadNext()
            }
        }

    }


    //MARK: - Block Level


    /// Will upload the next block if possible
    /// Respecting the priorities
    internal func _uploadNext()->(){
        if self._uploadsInProgress.count<_maxSimultaneousOperations{

            let blocksS=self.localBlocksShadows.sorted { (l, r) -> Bool in
                return l.priority>r.priority
            }

            var toBeUploaded:BlockShadow?
            for candidate in blocksS{
                if candidate.needsUpload && candidate.uploadInProgress==false {
                    toBeUploaded=candidate
                    break
                }
            }

            func __removeBlockFromList(_ block:Block){
                block.uploadInProgress=false
                if let idx=self._uploadsInProgress.index(where:{ $0.blockUID == block.UID}){
                    self._uploadsInProgress.remove(at: idx)
                }
            }

            if toBeUploaded != nil{
                if let block = try? Bartleby.registredObjectByUID(toBeUploaded!.UID) as Block {
                    block.uploadInProgress=true
                    let uploadOperation=UploadBlock(block: block, documentUID: self._document.UID, sucessHandler: { (context) in
                        __removeBlockFromList(block)
                        block.needsUpload=false
                        self._uploadNext()

                    }, failureHandler: { (context) in
                        __removeBlockFromList(block)
                    }, cancelationHandler: {
                        __removeBlockFromList(block)
                    })
                    self._uploadsInProgress.append(uploadOperation)

                }else{
                    self._document.log("Block not found \(toBeUploaded!.UID)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
                }
            }
        }

    }

    /// Will download the next block if possible
    /// Respecting the priorities
    internal func _downloadNext()->(){

        if self._downloadsInProgress.count<_maxSimultaneousOperations{

            let blocksS=self.localBlocksShadows.sorted { (l, r) -> Bool in
                return l.priority>r.priority
            }

            var toBeDownloaded:BlockShadow?
            for candidate in blocksS{
                if candidate.needsDownload && candidate.downloadInProgress==false {
                    toBeDownloaded=candidate
                    break
                }
            }

            func __removeBlockFromList(_ block:Block){
                block.downloadInProgress=false
                if let idx=self._downloadsInProgress.index(where:{ $0.blockUID == block.UID }){
                    self._downloadsInProgress.remove(at: idx)
                }
            }

            if toBeDownloaded != nil{
                if let block = try? Bartleby.registredObjectByUID(toBeDownloaded!.UID) as Block {
                    block.downloadInProgress=true
                    let downLoadOperation=DownloadBlock(block: block, documentUID: self._document.UID, sucessHandler: { (context) in
                        __removeBlockFromList(block)
                        block.needsUpload=false
                        self._uploadNext()

                    }, failureHandler: { (context) in
                        __removeBlockFromList(block)
                    }, cancelationHandler: {
                        __removeBlockFromList(block)
                    })
                    self._downloadsInProgress.append(downLoadOperation)
                }else{
                    self._document.log("Block not found \(toBeDownloaded!.UID)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
                }
            }
        }
    }
    
    
    /// Creates and store a local BlockShadow from its distant pair
    ///
    /// - Parameter block: the Block
    /// - Returns: the block shadow
    func _shadowBlockIfNecessary(block:Block)->BlockShadow{
        if let idx=self._localContainer.blocks.index(where: { (blockShadow) -> Bool in
            return blockShadow.UID == block.UID
        }){
            return self._localContainer.blocks[idx]
        }else{
            // Let's add the blockShadow
            let blockShadow=BlockShadow.from(block)
            self._localContainer.blocks.append(blockShadow)
            return blockShadow
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
    
    /// Delete a Block its BlockShadow, raw file
    ///
    /// - Parameter block: the block or the BlockShadow reference
    func _deleteBlock(_ block:Block) {
        if let idx=self._localContainer.blocks.index(where:{ $0.UID == block.UID }){
            let block=self._localContainer.blocks[idx]
            let path=block.absolutePath
            Async.utility{
                do{
                    try self._fileManager.removeItem(atPath: path)
                }catch{
                    self._document.log("Block deletion failed found \(path)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
                }
            }
            // Remove the local block
            self._localContainer.blocks.remove(at: idx)
        }
        
        // Delete the distant Block
        if let idx=self._document.blocks.index(where: { $0.UID == block.UID }){
            self._document.blocks.removeObject(self._document.blocks[idx])
        }
    }
}
