//
//  BSFS.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 02/11/2016.
//
//
import Foundation

enum BSFSError:Error{
    case boxIsInBox(existingBox:URL)
    case boxDelegateIsNotAvailable(message:String)
}


public extension Node{
    func realPath()->String{
        return ""
    }
}


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
    func assemblyIsReady(node:Node,proceed:()->())

    /// BSFS sends to BoxDelegate
    /// The delegate invokes proceed asynchronously giving the time to perform required actions
    ///
    /// - Parameter node: the node that will be Updated
    func deletionIsReady(node:Node,proceed:()->())

}

public class BSFS:TriggerHook{


    // Document

    fileprivate unowned var _document:BartlebyDocument

    // The File manager
    fileprivate var _fileManager: BartlebyFileIO { return Bartleby.fileManager }

    // The Boxes Delegate registry.
    fileprivate var _boxesDelegates = [String:BoxDelegate]()


    required public init(in document:BartlebyDocument){
        self._document=document
    }

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


    /// Moves a node to another destination in the box.
    /// IMPORTANT: this method requires a response from the BoxDelegate
    /// The completion occurs when the BoxDelegate invokes `applyPendingChanges` on the concerned node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - destinationPath: the relative path
    ///   - handler: the completion hanlder
    public func copy(node:Node,to destinationPath:String)->(){
        do {
            let delegate = try self._getBoxDelegateFor(node: node)
            delegate?.copyIsReady(node: node, to: destinationPath, proceed: {
                // TODO implement
            })
        } catch{
            self._document.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
        }
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
        do {
            let delegate = try self._getBoxDelegateFor(node: node)
            delegate?.moveIsReady(node: node, to: destinationPath, proceed: {
                // TODO implement
            })
        } catch{
            self._document.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
        }

    }


    /// Deletes a node
    /// IMPORTANT: this method requires a response from the BoxDelegate
    /// The completion occurs when the BoxDelegate invokes `applyPendingChanges` on the concerned node
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - handler: the completion Handler
    public func delete(node:Node)->(){
        do {
            let delegate = try self._getBoxDelegateFor(node: node)
            delegate?.deletionIsReady(node: node, proceed: {
                /// TODO implement the deletion
            })
        } catch{
            self._document.log("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
        }
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
        self._tryToAssembleNodeInProgress()
    }

    /// Update the blocks of a node reflecting its current binary data
    /// - Parameters:
    ///   - node: the node
    public func update(node:Node)->(){
        self._document.metadata.nodesInProgress.append(node)
        self._tryToAssembleNodeInProgress()
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
            let delegate = try self._getBoxDelegateFor(node: node)
            delegate?.assemblyIsReady(node: node, proceed: {
                /// TODO implement Assembly process

                /// END
                if let idx=self._document.metadata.nodesInProgress.index(of: node){
                    self._document.metadata.nodesInProgress.remove(at: idx)
                }
                let completion=Completion.successState()
                completion.externalIdentifier=node.UID
                handler(completion)

            })
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
            // Call self._tryToAssembleNodeInProgress()

        }
    }

    // MARK: - Internal Mechanisms

    public func _tryToAssembleNodeInProgress(){
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


    internal func _getBoxDelegateFor(node:Node)throws->BoxDelegate?{
        if let boxUID=node.boxUID{
            let _:Box=try Bartleby.registredObjectByUID(boxUID) as Box
            if let delegate=self._boxesDelegates[boxUID]{
                return delegate
            }else{
                throw BSFSError.boxDelegateIsNotAvailable(message: "Delegate for box <\(boxUID)> not found")
            }
        }else{
            throw BSFSError.boxDelegateIsNotAvailable(message: "Box not found for <\(node.UID)>")
        }
    }

}
