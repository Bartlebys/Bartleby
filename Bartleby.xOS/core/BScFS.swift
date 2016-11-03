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
    static public var fileManager: BartlebyFileIO=BFileManager()

    // The Boxes Delegate registry.
    internal var _boxesDelegates=[Box:BoxDelegate]()

    /// The standard singleton shared instance
    public static let sharedInstance: BSFS = {
        let instance = BSFS()
        return instance
    }()

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
    ///   - handlers: the handlers
    public func add(original absolutePath:String, relativePath:String, authorized:[String]?, deleteOriginal:Bool,handlers:Handlers)->(){
    }


    /// Applies the pending changes on a node.
    ///
    /// - Parameters:
    ///   - node: the node to be updated or deleted.
    ///   - applicant: the delegate that
    ///   - handlers: the handlers
    public func applyPendingChanges(on node:Node, applicant:BoxDelegate,handlers:Handlers)->(){
    }

    //MARK: - Nodes Actions



    /// Moves a node to another destination in the box.
    ///
    /// - Parameters:
    ///   - node: the node
    ///   - destinationPath: the relative path
    ///   - onCompletion: the completion closure
    public func move(node:Node,to destinationPath:String,onCompletion:(_ sucess:Bool,_ message:String)->())->(){

    }


    /// Deletes a node
    ///
    /// - Parameter node: the node to be deleted
    public func delete(node:Node,onCompletion:(_ sucess:Bool)->())->(){
    }

    public func createFolders(at relativePath:String,success:(_ node:Node)->(),failure:(_ message:String)->())->(){
    }

    public func createAlias(of node:Node,to destinationPath:String,success:(_ node:Node)->(),failure:(_ message:String)->())->(){
    }

    public func updateBlocks(of node:Node)throws->(){
    }


    //MARK: - Block Level Actions


    internal func _assemble(node:Node){

    }

    internal func _disassemble(node:Node){

    }

    internal func _deltaDownload(node:Node){
    }


    internal func _deltaUpload(node:Node){
    }

}
