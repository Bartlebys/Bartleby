//
//  BartlebyFileIO.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 28/01/2016.
//
//

import Foundation


/**
 * Provides an abstraction for file IO.
 * Sandoboxed os x App can use BsyncXPCHelper that implement BartlebyFileIO
 */
@objc protocol BartlebyFileIO{
    
    /**
    Creates a directory
    
    - parameter path:                the path
    - parameter createIntermediates: create intermediates paths ?
    - parameter attributes:          attributes
    - parameter callBack:            the call back
    
    - returns: N/A
    */
    func createDirectoryAtPath(path: String,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [String : AnyObject]?,
        callBack:(success:Bool,message:String?)->())->()
    
    
    /**
     Reads the data with options
     
     - parameter path:            from file path
     - parameter readOptionsMask: readOptionsMask
     - parameter callBack:        the callBack
     
     - returns: N/A
     */
    func readData( contentsOfFile path: String,
        options readOptionsMask: NSDataReadingOptions,
        callBack:(data:NSData?, success:Bool,message:String?)->())->()
    
    
    /**
     Reads the data
     
     - parameter path:     the data file path
     - parameter callBack: the call back
     
     - returns: N/A
     */
    func readData( contentsOfFile path: String,
        callBack:(data:NSData?)->())->()
    
    
    /**
     Writes data to the given path
     
     - parameter data:             the data
     - parameter path:             the path
     - parameter useAuxiliaryFile: useAuxiliaryFile
     - parameter callBack:          the call back
     
     - returns: N/A
     */
    func writeData(data:NSData,
        path: String,
        atomically useAuxiliaryFile: Bool,
        callBack:(success:Bool,message:String?)->())->()
    
    
    
    /**
     Reads a string from a file
     
     - parameter path:     the file path
     - parameter enc:      the encoding
     - parameter callBack: the callBack
     
     - returns : N/A
     */
    func readString(contentsOfFile path: String,
        encoding enc: NSStringEncoding,
        callBack:(string:String?,success:Bool,message:String?)->())->()
    
    
    /**
     Writes String to the given path
     
     - parameter string:            the string
     - parameter path:             the path
     - parameter useAuxiliaryFile: useAuxiliaryFile
     - parameter enc:              encoding
     - parameter callBack:          the call back
     
     - returns: N/A
     */
    func writeString(string:String,
        path: String,
        atomically useAuxiliaryFile: Bool,
        encoding enc: NSStringEncoding,
        callBack:(success:Bool,message:String?)->())->()
    
    
    

    /**
     Determines if a file exists and is a directory.
     
     - parameter path:     the path
     - parameter callBack: the call back
     
     - returns: N/A
     */
    func fileExistsAtPath(path: String,
                          callBack:(exists:Bool,isADirectory:Bool,success:Bool,message:String?)->())->()
    
    /**
     Removes the item at a given path
     Use with caution !
     
     - parameter path:     path
     - parameter callBack: the call back
     */
    func removeItemAtPath(path: String,
                          callBack:(success:Bool,message:String?)->())->()
    
    /**
     Copies the file
     
     - parameter srcPath:  srcPath
     - parameter dstPath:  dstPath
     - parameter callBack: callBack
     
     - returns: N/A
     */
    func copyItemAtPath(srcPath: String,
        toPath dstPath: String,
        callBack:(success:Bool,message:String?)->())->()
    
    /**
     Moves the file
     
     - parameter srcPath:  srcPath
     - parameter dstPath:  dstPath
     - parameter callBack: callBack
     
     - returns: N/A
     */
    func moveItemAtPath(srcPath: String,
        toPath dstPath: String,
        callBack:(success:Bool,message:String?)->())->()
    
    
    /**
     Lists the content of the directory
     
     - parameter path:     the path
     - parameter callBack: the callBack
     
     - returns: N/A
     */
    func contentsOfDirectoryAtPath(path: String,
        callBack:(success:Bool,content:[String],message:String?)->())->()

    
}