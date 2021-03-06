//
//  BFileManager.swift
//  Bartleby
//
//  Created by Benoit Pereira da silva on 28/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation


open class BFileManager: NSObject,BartlebyFileIO {

    // IMPORTANT NOTICE
    // When using BFileManager via XPC remember that the Handlers closure are not on your App Main Queue.
    // You should dispatch on the Main Queue if you perform any UI related action.

    // MARK: - Local File system

    /**
     Creates a directory

     - parameter path:                the path
     - parameter createIntermediates: create intermediates paths ?
     - parameter attributes:          attributes
     - parameter handlers:            the progress and completion handlers

     - returns: N/A
     */
    open func createDirectoryAtPath(_ path: String,
                                      handlers: Handlers) {
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            handlers.on(Completion.successState())
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromError(error))
        }
    }

    /**
     Reads the data

     - parameter path:            from file path
     - parameter handlers:            the progress and completion handlers

     - returns: N/A
     */
    open func readData( contentsOfFile path: String,
                                         handlers: Handlers) {
        do {
            let data=try Data(contentsOf: URL(fileURLWithPath: path), options: [])
            handlers.on(Completion.successState(data: data))
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromError(error))
        }

    }

    /**
     Writes data to the given path

     - parameter data:             the data
     - parameter path:             the path
     - parameter handlers:            the progress and completion handlers

     - returns: N/A
     */
    open func writeData( _ data: Data,
                           path: String,
                           handlers: Handlers) {
        do {
            try data.write(to: URL(fileURLWithPath: path), options:[])
            handlers.on(Completion.successState())
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromError(error))
        }


    }

    /**
     Reads a string from a file

     - parameter path:     the file path
     - parameter handlers:            the progress and completion handlers
     */
    open func readString(contentsOfFile path: String,
                                          handlers: Handlers) {

        do {
            let data=try Data(contentsOf: URL(fileURLWithPath: path), options: [])
            if let s = String(data: data, encoding: Default.STRING_ENCODING) {
                let read = Completion.successState()
                read.setStringResult(s)
                handlers.on(read)
            } else {
                handlers.on(Completion.failureState("\(path) doesn't contains valid data for given encoding \(Default.STRING_ENCODING)", statusCode: .unsupported_Media_Type))
            }
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromError(error))
        }

    }


    /**
     Writes String to the given path

     - parameter string:            the string
     - parameter path:             the path
     - parameter useAuxiliaryFile: useAuxiliaryFile
     - parameter enc:              encoding
     - parameter handlers:            the progress and completion handlers

     - returns: N/A
     */
    open func writeString( _ string: String,
                             path: String,
                             handlers: Handlers) {
        do {
            try string.write(toFile: path, atomically: true, encoding: Default.STRING_ENCODING)
            handlers.on(Completion.successState())
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromError(error))
        }

    }

    /**
     Determines if a file or a directory exists.

     - parameter path:     the path
     - parameter handlers:            the progress and completion handlers

     - returns:  N/A
     */
    open func itemExistsAtPath(_ path: String,
                                 handlers: Handlers) {
        var isADirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isADirectory) {
            handlers.on(Completion.successState())
        } else {
            handlers.on(Completion.failureState("Unexisting item: " + path, statusCode: .not_Found))
        }

    }

    /**
     Determines if a file exists.

     - parameter path:     the path
     - parameter handlers:            the progress and completion handlers

     - returns:  N/A
     */
    open func fileExistsAtPath(_ path: String,
                                 handlers: Handlers) {
        var isADirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isADirectory) {
            if isADirectory.boolValue {
                handlers.on(Completion.failureState("\(path) is a directory", statusCode: .unsupported_Media_Type))
            } else {
                handlers.on(Completion.successState())
            }
        } else {
            handlers.on(Completion.failureState("Unexisting item: " + path, statusCode: .not_Found))
        }

    }

    /**
     Determines if a file exists and is a directory.

     - parameter path:     the path
     - parameter handlers:            the progress and completion handlers

     - returns:  N/A
     */
    open func directoryExistsAtPath(_ path: String,
                                      handlers: Handlers) {
        var isADirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isADirectory) {
            if isADirectory.boolValue {
                handlers.on(Completion.successState())
            } else {
                handlers.on(Completion.failureState("\(path) is a file", statusCode: .unsupported_Media_Type))
            }
        } else {
            handlers.on(Completion.failureState("Unexisting item: " + path, statusCode: .not_Found))
        }

    }

    /**
     Removes the item at a given path
     Use with caution !

     - parameter path:     path
     - parameter handlers:            the progress and completion handlers
     */
    open func removeItemAtPath(_ path: String,
                                 handlers: Handlers) {
        do {
            try FileManager.default.removeItem(atPath: path)
            handlers.on(Completion.successState())
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromError(error))
        }

    }

    /**
     Copies the file

     - parameter srcPath:  srcPath
     - parameter dstPath:  dstPath
     - parameter handlers:            the progress and completion handlers

     - returns: N/A
     */
    open func copyItemAtPath(_ srcPath: String,
                               toPath dstPath: String,
                                      handlers: Handlers) {
        do {
            try FileManager.default.copyItem(atPath: srcPath, toPath: dstPath)
            handlers.on(Completion.successState())
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromError(error))
        }

    }

    /**
     Moves the file

     - parameter srcPath:  srcPath
     - parameter dstPath:  dstPath
     - parameter handlers:            the progress and completion handlers

     - returns: N/A
     */
    open func moveItemAtPath(_ srcPath: String,
                               toPath dstPath: String,
                                      handlers: Handlers) {
        do {
            try FileManager.default.moveItem(atPath: srcPath, toPath: dstPath)
            handlers.on(Completion.successState())
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromError(error))
        }
    }


    /**
     Lists the content of the directory

     - parameter path:     the path
     - parameter handlers:            the progress and completion handlers

     - returns: N/A
     */
    open func contentsOfDirectoryAtPath(_ path: String,
                                          handlers: Handlers) {
        do {
            let content=try FileManager.default.contentsOfDirectory(atPath: path)
            let c = Completion.successState()
            c.setStringArrayResult(content)
            handlers.on(c)
        } catch let error as NSError {
            handlers.on(Completion.failureStateFromError(error))
        }
        
    }
}
