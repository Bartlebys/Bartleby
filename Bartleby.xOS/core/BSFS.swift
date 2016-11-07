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
}


public extension Node{
    func realPath()->String{
        return ""
    }
}


// Should be implemented by anything that want to acceed to a node.
public protocol NodeAccessor{

    /// Called when
    /// - the current node assembled file will become unusable (for example on external update)
    /// - the file will be deleted
    ///
    /// - Parameter node: the node
    func willBecomeUnusable(node:Node)


    /// Called after an `askForAccess` demand  when
    /// - the current node rendered file becomes available (all the block are available, and the file has been assembled)
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
    func moveIsReady(node:Node,to destinationPath:String,proceed:()->())


    /// BSFS sends to BoxDelegate
    /// The delegate invokes proceed asynchronously giving the time to perform required actions
    ///
    /// - Parameter node: the node that will be moved or copied
    func copyIsReady(node:Node,to destinationPath:String,proceed:()->())


    /// BSFS sends to BoxDelegate
    /// The delegate invokes proceed asynchronously giving the time to perform required actions
    ///
    /// - Parameter node: the node that will be Updated
    func deletionIsReady(node:Node,proceed:()->())



    /// BSFS sends to BoxDelegate
    /// The delegate invokes proceed asynchronously giving the time to perform required actions
    ///
    /// - Parameter node: the node that will be Updated
    func blocksAreReady(node:Node,proceed:()->())


}

// COMPRESSION is using LZFSE https://developer.apple.com/reference/compression/1665429-data_compression
// CRYPTO is using CommonCrypto

public class BSFS:TriggerHook{


    // Document

    fileprivate unowned var _document:BartlebyDocument

    // The File manager
    fileprivate var _fileManager: BartlebyFileIO { return Bartleby.fileManager }

    // The Boxes Delegate registry.
    fileprivate var _boxDelegate:BoxDelegate?

    // The current accessed nodes
    fileprivate var _accessedNodes:[Node] = [Node]()

    // And their accessors
    fileprivate var _accessors=[String:[NodeAccessor]]()


    /// Each document has it own BSFS
    ///
    /// - Parameter document: the document instance
    required public init(in document:BartlebyDocument){
        self._document=document
    }


    //MARK:  - File API

    public func provisionAccess(to nodes:[Node],onCompletion:@escaping CompletionHandler){

    }

    public func askForAccess(to node:Node,by accessor:NodeAccessor){
        // The nodeIsUsable() will be called when the file will be usable.
    }



    public func stopAccessingNode(node:Node,onCompletion:@escaping CompletionHandler){
        if let idx=self._accessedNodes.index(of: node){
            self._accessedNodes.remove(at: idx)
        }
        // TODO "unmount" node
    }


    public func releaseAccessOnAllNodes()->Bool{
        // Wait synchronously.
        for node in self._accessedNodes {
            self.stopAccessingNode(node: node, onCompletion: VoidCompletionHandler)
        }
        return true
    }

    //MARK:  -

    fileprivate func _startAccessing(to node:Node,mounted:@escaping(String)->()){
        if !self._accessedNodes.contains(node) {
            self._accessedNodes.append(node)
        }
        // TODO "Mount" node
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
    public func add(original absolutePath:String, relativePath:String,authorized:[String],deleteOriginal:Bool=false,compressed:Bool=false,crypted:Bool=true,priority:Int=0)throws->Node{
        return Node()
    }


    /// Moves a node to another destination in the box.
    /// IMPORTANT: this method requires a response from the BoxDelegate
    /// The completion occurs when the BoxDelegate invokes `applyPendingChanges` on the concerned node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - destinationPath: the relative path
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
    ///   - destinationPath: the relative path
    ///   - handler: the completion hanlder
    public func move(node:Node,to destinationPath:String)->(){
        _boxDelegate?.moveIsReady(node: node, to: destinationPath, proceed: {
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
    ///   - destinationPath: the destination path
    ///   - handler: the completion Handler
    public func createAlias(of node:Node,to destinationPath:String)->(){
    }


    /// Creates the blocks of a node reflecting its current binary data
    ///
    /// - Parameters:
    ///   - node: the node
    public func create(node:Node)->(){
        self._document.metadata.nodesInProgress.append(node)
        self._tryToAssembleNodesInProgress()
    }

    /// Update the blocks of a node reflecting its current binary data
    /// - Parameters:
    ///   - node: the node
    public func update(node:Node)->(){
        self._document.metadata.nodesInProgress.append(node)
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
    ///   - handler: the completion handler
    internal func _assemble(node:Node,handler: @escaping CompletionHandler){
        do {
            if let delegate = _boxDelegate{
                delegate.blocksAreReady(node: node, proceed: {
                    /// TODO implement Assembly process

                    /// END
                    if let idx=self._document.metadata.nodesInProgress.index(of: node){
                        self._document.metadata.nodesInProgress.remove(at: idx)
                    }
                    let completion=Completion.successState()
                    completion.externalIdentifier=node.UID
                    handler(completion)

                })
            }else{
                throw BSFSError.boxDelegateIsNotAvailable
            }

        } catch{
            handler(Completion.failureStateFromError(error))
        }
    }



    internal func _disassemble(node:Node,handler: @escaping CompletionHandler){
        // #1 Break the node into chunk
        // #2 Compare the block
        // #3 Update the node instance

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
        for node in self._document.metadata.nodesInProgress {
            // Check if we have all the blocks
            if (self._allBlocksAreAvailableFor(node: node)){
                self._assemble(node: node, handler: VoidCompletionHandler)
            }
        }
    }

    public func _allBlocksAreAvailableFor(node:Node)->Bool{
        // @TODO
        return true
    }



    //MARK: - Chunk API (low level chunk to file and file to chunk)


    public struct Chunk {
        var baseDirectory:String
        var relativePath:String
        var sha1:String
        var originalSize:Int
    }


    /// This breaks efficiently a file to chunks.
    /// - The hard stuff is done Asynchronously on a the Utility queue
    /// - we use an Autorelease pool to lower the memory foot print
    ///
    /// - Parameters:
    ///   - path: the file path
    ///   - folderPath: the destination folder path
    ///   - chunkMaxSize: the max size for a chunk / future block
    ///   - compress: should we compress (using LZ4)
    ///   - encrypt: should we encrypt (using AES256)
    ///   - success: the success closure returns a Chunk Struct to be used to create/update Block instances
    ///   - failure: the failure closure
    public func breakIntoChunk(  fileAt path:String,
                                 destination folderPath:String,
                                 chunkMaxSize:Int=10*MB,
                                 compress:Bool,encrypt:Bool,
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

                let _ = try? FileManager.default.removeItem(atPath: folderPath)
                let _ = try? FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)

                var offset:UInt64=0
                var position:UInt64=0
                var chunks=[Chunk]()


                func __writeData(data:Data,to folderPath:String)throws->(){
                    let sha1=data.sha1
                    // Generate a Classified Block Tree.
                    let c1=PString.substr(sha1, 0, 1)
                    let c2=PString.substr(sha1, 1, 1)
                    let c3=PString.substr(sha1, 2, 1)
                    let relativeFolderPath="\(c1)/\(c2)/\(c3)/"
                    let bFolderPath=folderPath+relativeFolderPath
                    let _ = try FileManager.default.createDirectory(atPath: bFolderPath, withIntermediateDirectories: true, attributes: nil)
                    let destination=bFolderPath+"/\(sha1)"
                    let chunkRelativePath=relativeFolderPath+"\(sha1)"
                    let chunk=Chunk(baseDirectory:folderPath, relativePath: chunkRelativePath,sha1: sha1,originalSize:Int(offset))
                    chunks.append(chunk)
                    let url=URL(fileURLWithPath: destination)
                    let _ = try data.write(to:url )
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
    ///
    /// - Parameters:
    ///   - paths: the chunks absolute paths
    ///   - destinationFilePath: the joined file destination
    ///   - decompress: should we decompress using LZ4
    ///   - decrypt: should we decrypt usign AES256
    ///   - success: the success closure
    ///   - failure: the failure closure
    public func joinChunks (   from paths:[String],
                              to destinationFilePath:String,
                              decompress:Bool,
                              decrypt:Bool,
                              success:@escaping ()->(),
                              failure:@escaping (String)->()){

        // Don't block the main thread with those intensive IO  processing
        Async.utility {

            do{

                let folderPath=(destinationFilePath as NSString).deletingLastPathComponent
                try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
                FileManager.default.createFile(atPath: destinationFilePath, contents: nil, attributes: nil)

                // Assemble
                if let writeFileHande = FileHandle(forWritingAtPath:destinationFilePath ){
                    writeFileHande.seek(toFileOffset: 0)

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
