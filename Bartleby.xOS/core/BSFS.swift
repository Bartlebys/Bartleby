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
    ///   - zipped: should we zip the node
    ///   - crypted: should we encrypt the node
    ///   - priority: synchronization priority (higher == will be synchronized before the other nodes)
    /// - Returns: the node
    public func add(original absolutePath:String, relativePath:String,authorized:[String],deleteOriginal:Bool=false,zipped:Bool=false,crypted:Bool=true,priority:Int=0)throws->Node{
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

}
