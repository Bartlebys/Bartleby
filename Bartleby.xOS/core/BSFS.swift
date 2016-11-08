//
//  BSFS.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 02/11/2016.
//
//
import Foundation

enum BSFSError:Error{
    case boxDelegateIsNotAvailable
    case attemptToMountBoxMultipleTime(boxUID:String)
    case nodeIsNotAssemblable
}



// Should be implemented by anything that want to acceed to a node.
public protocol NodeAccessor:Identifiable{

    /// Called when:
    /// - the current node assembled file will become temporaly unusable (for example on external update)
    /// - the Box has been unmounted
    /// - the file will be deleted
    //  - or if the access to the file has been blocked (ACL)
    /// 
    /// If the node accessor remain active, if the node become usable again it will receive a `nodeIsUsable(node:Node)` call
    ///
    /// - Parameter node: the node
    func willBecomeUnusable(node:Node)


    /// Called after an `wantsAccess` demand  when
    /// - the current node assembled file becomes available (all the block are available, and the file has been assembled)
    ///
    /// - Parameter node: the node
    func nodeIsUsable(node:Node)

}


// Box Delegation is related to synchronization.
public protocol BoxDelegate{


    /// BSFS sends to BoxDelegate
    /// The delegate invokes proceed asynchronously giving the time to perform required actions
    ///
    /// - Parameter node: the node that will be moved or copied
    func moveIsReady(node:Node,to relativePath:String,proceed:()->())


    /// BSFS sends to BoxDelegate
    /// The delegate invokes proceed asynchronously giving the time to perform required actions
    ///
    /// - Parameter node: the node that will be moved or copied
    func copyIsReady(node:Node,to relativePath:String,proceed:()->())


    /// BSFS sends to BoxDelegate
    /// The delegate invokes proceed asynchronously giving the time to perform required actions
    ///
    /// - Parameter node: the node that will be Updated
    func deletionIsReady(node:Node,proceed:()->())


/// ????


    /// BSFS sends to BoxDelegate
    /// The delegate invokes proceed asynchronously giving the time to perform required actions
    ///
    /// - Parameter node: the node that will be Updated
    func blocksAreReady(node:Node,proceed:()->())


}

public class BSFS:TriggerHook{

    // Document

    fileprivate unowned var _document:BartlebyDocument

    /// The File manager used to perform all the BSFS operation on the utility queue.
    /// Note that we also use specific FileHandle at chunk level
    fileprivate let _fileManager:FileManager=FileManager()

    // The Boxes Delegate registry.
    fileprivate var _boxDelegate:BoxDelegate?

    // And their accessors
    fileprivate var _accessors=[String:[NodeAccessor]]()


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


    //MARK:  - BOX API

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
                if node.isAssemblable && !node.isAssembled && !node.assemblyInProgress{
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


    /// Un mounts the BOX == deletes all the assembled files
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
                let assembledPath=node.absolutePath
                try self._fileManager.removeItem(atPath: assembledPath)
            }
            box.isMounted=false
            completed(Completion.successState())
        }catch{
            completed(Completion.failureStateFromError(error))
        }
    }

    //MARK:  - File API

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
    /// - Returns: false if the current user is not authorized.
    public func wantsAccess(to node:Node,accessor:NodeAccessor)->Bool{
        // The nodeIsUsable() will be called when the file will be usable.
        if node.authorized.contains("*") || node.authorized.contains(self._document.currentUser.UID){
            if self._accessors[node.UID] != nil {
                self._accessors[node.UID]=[NodeAccessor]()
            }
            if !self._accessors[node.UID]!.contains(where: {$0.UID==accessor.UID}){
                self._accessors[node.UID]!.append(accessor)
            }
            if node.isAssembled{
                
            }
            return true
        }else{
            return false
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



    //MARK:  - Boxed API


    /// Adds a file into the box (copies if necessary the file into the box)
    ///
    /// - Parameters:
    ///   - absolutePath: the original file path
    ///   - relativePath: the relative Path of the Node
    ///   - authorized: the User UIDS or "*" if public
    ///   - deleteOriginal: should we delete the original?
    ///   - compressed: should we zip the node
    ///   - crypted: should we encrypt the node
    ///   - priority: synchronization priority (higher == will be synchronized before the other nodes)
    /// - Returns: the node
    public func add(original absolutePath:String,
                    relativePath:String,
                    authorized:[String],
                    deleteOriginal:Bool=false,
                    compressed:Bool=false,
                    crypted:Bool=true,
                    priority:Int=0)throws->Node{

        return Node()
    }


    /// Moves a node to another destination in the box.
    /// IMPORTANT: this method requires a response from the BoxDelegate
    /// The completion occurs when the BoxDelegate invokes `applyPendingChanges` on the concerned node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - relativePath: the relative path
    ///   - handler: the completion hanlder
    public func copy(node:Node,to destinationPath:String)->(){
        _boxDelegate?.copyIsReady(node: node, to: destinationPath, proceed: {
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

    /// Create Folders
    /// - Parameters:
    ///   - relativePath: the relative Path
    ///   - handler: the completion Handler
    public func createFolder(at relativePath:String)->(){
    }

    /// Creates the Alias
    /// - Parameters:
    ///   - node: the node to be aliased
    ///   - relativePath: the destination relativePath
    ///   - handler: the completion Handler
    public func createAlias(of node:Node,to relativePath:String)->(){
    }


    /// Creates the blocks of a node reflecting its current binary data
    ///
    /// - Parameters:
    ///   - node: the node
    public func create(node:Node)->(){
        self._tryToAssembleNodesInProgress()
    }

    /// Update the blocks of a node reflecting its current binary data
    /// - Parameters:
    ///   - node: the node
    public func update(node:Node)->(){
        self._tryToAssembleNodesInProgress()
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


    //MARK: - Block Level Actions


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
                delegate.blocksAreReady(node: node, proceed: {
                    let filePath=node.absolutePath
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

    //MARK: - WILL BECOME PRIVATE
    //MARK: Chunk level (low level chunk to file and file to chunk)


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
                    failure("Unable to create file Handle at: \(path)")
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
                        failure("Unable to create file Handle at: \(destinationFilePath)")
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
