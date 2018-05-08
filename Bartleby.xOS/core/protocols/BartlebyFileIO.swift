//
//  BartlebyFileIO.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 28/01/2016.
//
//

import Foundation

/**
 * Provides an abstraction for file IO
 */
public protocol BartlebyFileIO {
    /**
     Creates a directory

     - parameter path:                the path
     - parameter handlers:            the handlers
     */
    func createDirectoryAtPath(_ path: String,
                               handlers: Handlers)

    /**
     Reads the data with options

     - parameter path:            from file path
     - parameter readOptionsMask: readOptionsMask
     - parameter handlers:        the handlers
     */
    func readData(contentsOfFile path: String,
                  handlers: Handlers)

    /**
     Writes data to the given path

     - parameter data:             the data
     - parameter path:             the path
     - parameter useAuxiliaryFile: useAuxiliaryFile
     - parameter handlers:          the handlers
     */
    func writeData(_ data: Data,
                   path: String,
                   handlers: Handlers)

    /**
     Reads the string

     - parameter path:            from file path
     - parameter handlers:        the handlers

     Here is an example showing how to extract the string
     in the completion handler:

     { (read) in
     if let s = read.getStringResult() where read.success {
     // Handle success
     ...
     } else {
     // Handle error
     ...
     }
     }
     */
    func readString(contentsOfFile path: String,
                    handlers: Handlers)

    /**
     Writes String to the given path using utf8 encoding

     - parameter string:            the string
     - parameter path:             the path
     - parameter handlers:          the handlers
     */
    func writeString(_ string: String,
                     path: String,
                     handlers: Handlers)

    /**
     Determines if a file or directory exists.

     - parameter path:     the path
     - parameter handlers: The progress and completion handler
     */
    func itemExistsAtPath(_ path: String,
                          handlers: Handlers)

    /**
     Determines if a file exists and is a directory.

     - parameter path:     the path
     - parameter handlers: The progress and completion handler
     */
    func fileExistsAtPath(_ path: String,
                          handlers: Handlers)

    /**
     Determines if a directory exists.

     - parameter path:     the path
     - parameter handlers: The progress and completion handler
     */
    func directoryExistsAtPath(_ path: String,
                               handlers: Handlers)

    /**
     Removes the item at a given path
     Use with caution !

     - parameter path:     path
     - parameter handlers: The progress and completion handler
     */
    func removeItemAtPath(_ path: String,
                          handlers: Handlers)

    /**
     Copies the file

     - parameter srcPath:  srcPath
     - parameter dstPath:  dstPath
     - parameter handlers: The progress and completion handler
     */
    func copyItemAtPath(_ srcPath: String,
                        toPath dstPath: String,
                        handlers: Handlers)

    /**
     Moves the file

     - parameter srcPath:  srcPath
     - parameter dstPath:  dstPath
     - parameter handlers: The progress and completion handler
     */
    func moveItemAtPath(_ srcPath: String,
                        toPath dstPath: String,
                        handlers: Handlers)

    /**
     Lists the content of the directory

     - parameter path:     the path
     - parameter handlers: The progress and completion handler

     Here is an example showing how to extract the string
     in the completion handler:

     { (content) in
     if let s = content.getStringArrayResult() where content.success {
     // Handle success
     ...
     } else {
     // Handle error
     ...
     }
     }
     */
    func contentsOfDirectoryAtPath(_ path: String,
                                   handlers: Handlers)
}
