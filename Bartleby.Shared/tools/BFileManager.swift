//
//  BFileManager.swift
//  Bartleby
//
//  Created by Benoit Pereira da silva on 28/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation


@objc(BFileManager) class BFileManager: NSObject, BartlebyFileIO {
    
    // MARK: - Local File system
    
    /**
     Creates a directory
     
     - parameter path:                the path
     - parameter createIntermediates: create intermediates paths ?
     - parameter attributes:          attributes
     - parameter callBack:            the call back
     
     - returns: N/A
     */
    func createDirectoryAtPath(path: String,
                                                           handlers: Handlers) -> () {
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
            handlers.on(Completion.successState())
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromNSError(error))
        }
    }
    
    /**
     Reads the data
     
     - parameter path:            from file path
     - parameter readOptionsMask: readOptionsMask
     - parameter callBack:        the callBack
     
     - returns: N/A
     */
    func readData( contentsOfFile path: String,
                                          handlers: Handlers) -> () {
        do {
            // TODO: @md If we don't use option we can remove the do try catch block
            let data=try NSData(contentsOfFile: path, options: [])
            handlers.on(Completion.successState(data: data))
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromNSError(error))
        }
    }
    
    /**
     Writes data to the given path
     
     - parameter data:             the data
     - parameter path:             the path
     - parameter useAuxiliaryFile: useAuxiliaryFile
     - parameter callBack:          the call back
     
     - returns: N/A
     */
    func writeData( data: NSData,
                    path: String,
                               handlers: Handlers) -> () {
        do {
            // TODO: @md Check common usage
//            if useAuxiliaryFile {
//                try data.writeToFile(path, options: NSDataWritingOptions.AtomicWrite)
//            } else {
                try data.writeToFile(path, options:[])
//            }
            
            handlers.on(Completion.successState())
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromNSError(error))
        }
    }
    
    /**
     Reads a string from a file
     
     - parameter path:     the file path
     - parameter callBack: the callBack
     
     - returns : N/A
     */
    func readString(contentsOfFile path: String,
                               handlers: Handlers) -> () {
        do {
            // TODO: @md Check common usage for option
            let data=try NSData(contentsOfFile: path, options: [])
            if let s = String(data: data, encoding: Default.TEXT_ENCODING) {
                let read = Completion.successState()
                read.setStringResult(s)
                handlers.on(read)
            } else {
                handlers.on(Completion.failureState("\(path) doesn't contains valid data for given encoding \(Default.TEXT_ENCODING)", statusCode: .Unsupported_Media_Type))
            }
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromNSError(error))
        }
    }
    
    
    /**
     Writes String to the given path
     
     - parameter string:            the string
     - parameter path:             the path
     - parameter useAuxiliaryFile: useAuxiliaryFile
     - parameter enc:              encoding
     - parameter callBack:          the call back
     
     - returns: N/A
     */
    func writeString( string: String,
                      path: String,
                                          handlers: Handlers) -> () {
        do {
            // TODO: @md Check common usage for atomically
            try string.writeToFile(path, atomically: true, encoding: Default.TEXT_ENCODING)
            handlers.on(Completion.successState())
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromNSError(error))
        }
    }
    
    /**
     Determines if a file or a directory exists.
     
     - parameter path:     the path
     - parameter callBack: the call back
     
     - returns:  N/A
     */
    func itemExistsAtPath(path: String,
                          handlers: Handlers) -> () {
        
        var isADirectory: ObjCBool = false
        if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isADirectory) {
            handlers.on(Completion.successState())
        } else {
            handlers.on(Completion.failureState("Unexisting item: " + path, statusCode: .Not_Found))
        }
    }
    
    /**
     Determines if a file exists.
     
     - parameter path:     the path
     - parameter callBack: the call back
     
     - returns:  N/A
     */
    func fileExistsAtPath(path: String,
                          handlers: Handlers) -> () {
        
        var isADirectory: ObjCBool = false
        if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isADirectory) {
            if isADirectory.boolValue {
                handlers.on(Completion.failureState("\(path) is a directory", statusCode: .Unsupported_Media_Type))
            } else {
                handlers.on(Completion.successState())
            }
        } else {
            handlers.on(Completion.failureState("Unexisting item: " + path, statusCode: .Not_Found))
        }
    }
    
    /**
     Determines if a file exists and is a directory.
     
     - parameter path:     the path
     - parameter callBack: the call back
     
     - returns:  N/A
     */
    func directoryExistsAtPath(path: String,
                          handlers: Handlers) -> () {
        
        var isADirectory: ObjCBool = false
        if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isADirectory) {
            if isADirectory.boolValue {
                handlers.on(Completion.successState())
            } else {
                handlers.on(Completion.failureState("\(path) is a file", statusCode: .Unsupported_Media_Type))
            }
        } else {
            handlers.on(Completion.failureState("Unexisting item: " + path, statusCode: .Not_Found))
        }
    }
    
    /**
     Removes the item at a given path
     Use with caution !
     
     - parameter path:     path
     - parameter callBack: the call back
     */
    func removeItemAtPath(path: String,
                          handlers: Handlers) -> () {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
            handlers.on(Completion.successState())
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromNSError(error))
        }
    }
    
    /**
     Copies the file
     
     - parameter srcPath:  srcPath
     - parameter dstPath:  dstPath
     - parameter callBack: callBack
     
     - returns: N/A
     */
    func copyItemAtPath(srcPath: String,
                        toPath dstPath: String,
                               handlers: Handlers) -> () {
        do {
            try NSFileManager.defaultManager().copyItemAtPath(srcPath, toPath: dstPath)
            handlers.on(Completion.successState())
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromNSError(error))
        }
    }
    
    /**
     Moves the file
     
     - parameter srcPath:  srcPath
     - parameter dstPath:  dstPath
     - parameter callBack: callBack
     
     - returns: N/A
     */
    func moveItemAtPath(srcPath: String,
                        toPath dstPath: String,
                               handlers: Handlers) -> () {
        do {
            try NSFileManager.defaultManager().moveItemAtPath(srcPath, toPath: dstPath)
            handlers.on(Completion.successState())
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromNSError(error))
        }
    }
    
    
    /**
     Lists the content of the directory
     
     - parameter path:     the path
     - parameter callBack: the callBack
     
     - returns: N/A
     */
    func contentsOfDirectoryAtPath(path: String,
                                   handlers: Handlers) -> () {
        do {
            let content=try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path)
            let c = Completion.successState()
            c.setStringArrayResult(content)
            handlers.on(c)
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromNSError(error))
        }
    }
}
