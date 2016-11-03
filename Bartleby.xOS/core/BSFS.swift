//
//  BSFS.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 02/11/2016.
//
//
import Foundation

enum BSFSError {
    case BoxIsInBox(existingBox:URL)
}


public extension Node{
    func realPath()->String{
        return ""
    }
}


public protocol BoxDelegate{

    /// BSFS sends to BoxDelegate
    ///
    /// The Box Delegate should respond when appropriate:
    ///
    ///     self.applyPendingChanges(applyPendingChanges(on: node, applicant: self, onCompletion: { (succes, mesage) in
    ///
    ///     })
    ///
    /// - Parameter node: the node that will be Updated
    func fileUpdateIsReady(node:Node)

    /// BSFS sends to BoxDelegate
    ///
    /// The Box Delegate should respond when appropriate:
    ///
    ///     self.applyPendingChanges(applyPendingChanges(on: node, applicant: self, onCompletion: { (succes, mesage) in
    ///
    ///     })
    ///
    /// - Parameter node: the node that will be Updated
    func fileDeletionIsReady(node:Node)

}

public struct BSFS{

    // The File manager
    fileprivate var _fileManager: BartlebyFileIO { return Bartleby.fileManager }

    // The Boxes Delegate registry.
    fileprivate var _boxesDelegates=[String:BoxDelegate]()

    //MARK:  - Box

    /// Intitializes a box if possible.
    ///
    /// #1 Check if there is a box in the top of this path
    /// #2 create the .bsfs folder + content
    /// #3 deals with the collaborative server (Auth is a prerequisite)
    ///
    /// - Parameter path: path description
    /// - Throws: Exception on failures
    public func initializeBox(box:Box)throws->(){

    }

    /// Adds a file into the box (copies if necessary the file into the box)
    ///
    /// - Parameters:
    ///   - absolutePath: the original file path
    ///   - relativePath: the relative Path of the Node
    ///   - authorized: the User UIDS or "*" if public
    ///   - deleteOriginal: should we delete the original?
    ///   - handler: the completion handler
    public func add(original absolutePath:String, relativePath:String, authorized:[String]?, deleteOriginal:Bool,handler: @escaping CompletionHandler)->(){
    }


    /// Applies the pending changes on a node.
    ///
    /// - Parameters:
    ///   - node: the node to be updated or deleted.
    ///   - applicant: the delegate that
    ///   - handler: the completion handler
    public func applyPendingChanges(on node:Node, applicant:BoxDelegate,handler: @escaping CompletionHandler)->(){

    }

    //MARK: - Nodes Actions


    /// Moves a node to another destination in the box.
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - destinationPath: the relative path
    ///   - handler: the completion hanlder
    public func move(node:Node,to destinationPath:String,handler: @escaping CompletionHandler)->(){

    }


    /// Deletes a node
    /// IMPORTANT: this method requires a response from the BoxDelegate
    /// The completion occurs when the BoxDelegate invokes `applyPendingChanges` on the concerned node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - handler: the completion Handler
    public func delete(node:Node,handler: @escaping CompletionHandler)->(){

    }

    /// Create Folders
    ///
    /// - Parameters:
    ///   - relativePath: the relative Path
    ///   - handler: the completion Handler
    public func createFolder(at relativePath:String,handler: @escaping CompletionHandler)->(){

    }

    /// Creates the Alias
    ///
    /// - Parameters:
    ///   - node: the node to be aliased
    ///   - destinationPath: the destination path
    ///   - handler: the completion Handler
    public func createAlias(of node:Node,to destinationPath:String,handler: @escaping CompletionHandler)->(){
    }


    /// Creates the blocks of a node reflecting its current binary data
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - handler: the completion handler
    public func create(node:Node,handler: @escaping CompletionHandler)->(){

    }

    /// Update the blocks of a node reflecting its current binary data
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - handler: the completion handler
    public func update(node:Node,handler: @escaping CompletionHandler)->(){

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
    }


    /// Create blocks from the file.
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - handler: the completion handler
    internal func _disassemble(node:Node,handler: @escaping CompletionHandler){
    }


    /// Downloads a Block.
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - handler: the completion handler
    internal func _download(node:Block,handler: @escaping CompletionHandler){
    }

    /// Uploads a block
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - handler: the completion handler
    internal func _upload(node:Block,handler: @escaping CompletionHandler){
    }


    //MARK: - Triggered Nodes Level Action


    /// Moves a node to another destination in the box.
    /// IMPORTANT: this method requires a response from the BoxDelegate
    /// The completion occurs when the BoxDelegate invokes `applyPendingChanges` on the concerned node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - destinationPath: the relative path
    ///   - handler: the completion hanlder
    public func triggered_move(node:Node,to destinationPath:String)->(){

    }


    /// Deletes a node
    /// IMPORTANT: this method requires a response from the BoxDelegate
    /// The completion occurs when the BoxDelegate invokes `applyPendingChanges` on the concerned node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - handler: the completion Handler
    public func triggered_delete(node:Node)->(){

    }

    /// Create Folders
    /// - Parameters:
    ///   - relativePath: the relative Path
    ///   - handler: the completion Handler
    public func triggered_createFolder(at relativePath:String)->(){

    }

    /// Creates the Alias
    /// - Parameters:
    ///   - node: the node to be aliased
    ///   - destinationPath: the destination path
    ///   - handler: the completion Handler
    public func triggered_createAlias(of node:Node,to destinationPath:String)->(){
    }


    /// Creates the blocks of a node reflecting its current binary data
    ///
    /// - Parameters:
    ///   - node: the node
    public func triggered_create(node:Node)->(){

    }

    /// Update the blocks of a node reflecting its current binary data
    /// IMPORTANT: this method requires a response from the BoxDelegate
    /// The completion occurs when the BoxDelegate invokes `applyPendingChanges` on the concerned node
    /// - Parameters:
    ///   - node: the node
    public func triggered_update(node:Node)->(){
        
    }

    //MARK: - Triggered Block Level Action

    /// Downloads a Block.
    /// This occurs before triggered_create on each successfull upload.
    ///
    /// - Parameters:
    ///   - node: the node
    internal func triggered_download(block:Block){
        //if block.authorized.contains()
    }


}
