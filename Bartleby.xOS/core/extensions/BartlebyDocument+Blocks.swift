//
//  BartlebyDocument+Blocks.swift
//  bartleby
//
//  Created by Benoit Pereira da silva on 25/11/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

extension BartlebyDocument{

    // MARK: - Blocks Wrappers

    public var blocksDirectoryWrapperName: String { return "blocks" }
    public var blocksWrapper:FileWrapper? {
        return self.documentFileWrapper.fileWrappers?[self.blocksDirectoryWrapperName]
    }


    /// Returns the list of the digest (sha1) of each blocks in the blocks wrapper
    ///
    /// - Returns: the list of the digest (sha1) of each blocks in the blocks wrapper
    public func availableBlocksDigests()->[String]{
        var digests=[String]()
        if let fileWrappers=self.blocksWrapper?.fileWrappers{
            digests=fileWrappers.map({ (digest, _) ->String in
                return digest
            })
        }
        return digests
    }



    /// Returns true if the block is Available
    ///
    /// - Parameter digest: the identifier of the file
    /// - Returns: the availability of the block
    public func blockIsAvailable(identifiedBy digest:String)->Bool{
        return !(self.blocksWrapper?.fileWrappers?.index(forKey: digest) == nil)
    }





    /// Add a file into the package
    ///
    /// - Parameters:
    ///   - url: the original content URL
    ///   - digest: the identifier of the block (use the block digests)
    ///   - isABlock: defines if the file must be considerate as a block (bsfs)
    public func put(data:Data,identifiedBy digest:String)throws->(){
        if let directoryFileWrapper = self.blocksWrapper {
            Async.main{
                // Remove the previous wrapper if there is one
                if let w=directoryFileWrapper.fileWrappers?[digest]{
                    directoryFileWrapper.removeFileWrapper(w)
                }
                let f = FileWrapper(regularFileWithContents: data)

                f.preferredFilename=digest
                directoryFileWrapper.addFileWrapper(f)
            }
        }else{
            throw DocumentError.fileWrapperNotFound(message: "Directory Wrapper not found ")
        }
    }


    /// Removes a Block from the package
    ///
    /// - Parameters:
    ///   - digest: the identifier of the file
    ///   - isABlock: defines if the file must be considerate as a block (bsfs)
    public func removeBlock(with digest:String)throws->(){
        if let directoryFileWrapper:FileWrapper = self.blocksWrapper {
            if let w=directoryFileWrapper.fileWrappers?[digest]{
                Async.main{
                    directoryFileWrapper.removeFileWrapper(w)
                }
            }else{
                throw DocumentError.fileWrapperNotFound(message:"File Wrapper with digest \(digest)")
            }
        }else{
            throw DocumentError.fileWrapperNotFound(message: "Directory Wrapper not found )")
        }
    }


    /// Returns the data for a given identifier
    ///
    /// - Parameter digest: the block digest
    /// - Returns: the block file Wrapper
    public func dataForBlock(identifiedBy digest:String)throws->Data{
        let mainGroup=AsyncGroup()
        var data:Data?
        mainGroup.main {
            data=self.blocksWrapper?.fileWrappers?[digest]?.regularFileContents
        }
        mainGroup.wait()
        if let data=data{
            return data
        }else{
            throw DocumentError.blockNotFound(identifiedBy: digest)
        }
    }

    // MARK: Maintenance

    /// Clean procedure usable during maintenance to clean up potential Orphans blocks@
    public func eraseOrphansBlocks()throws->(){
        if let fileWrappers=self.blocksWrapper?.fileWrappers{
            for (k,_) in fileWrappers {
                if !self.blocks.contains(where: { return $0.digest==k }){
                    try removeBlock(with: k)
                    self.log("Erased block with digest \(k)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
                }
            }
        }
    }

    
}
