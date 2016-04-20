//
//  BFileManager.swift
//  Bartleby
//
//  Created by Benoit Pereira da silva on 28/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation


@objc(BFileManager) class BFileManager:NSObject,BartlebyFileIO {
    
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
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [String : AnyObject]?,
        callBack:(success:Bool,message:String?)->())->(){
            do{
                try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: createIntermediates, attributes: attributes)
                callBack(success: true, message: nil)
            }catch {
                callBack(success: false, message: "\(error)")
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
        options readOptionsMask: NSDataReadingOptions,
        callBack:(data:NSData?, success:Bool,message:String?)->())->(){
            do{
                let data=try NSData(contentsOfFile: path, options: readOptionsMask)
                callBack(data: data, success: true, message: nil)
            }catch {
                callBack(data: nil, success: false, message: "\(error)")
            }
    }
    
    
    /**
     Reads the data
     
     - parameter path:     the data file path
     - parameter callBack: the call back
     
     - returns: N/A
     */
    func readData( contentsOfFile path: String,
        callBack:(data:NSData?)->())->(){
            let data=NSData(contentsOfFile: path)
            callBack(data: data)
    }
    
    
    /**
     Writes data to the given path
     
     - parameter data:             the data
     - parameter path:             the path
     - parameter useAuxiliaryFile: useAuxiliaryFile
     - parameter callBack:          the call back
     
     - returns: N/A
     */
    func writeData( data:NSData,
        path: String,
        atomically useAuxiliaryFile: Bool,
        callBack:(success:Bool,message:String?)->())->(){
            do{
                if useAuxiliaryFile{
                    try data.writeToFile(path, options: NSDataWritingOptions.AtomicWrite)
                }else{
                    try data.writeToFile(path, options:[])
                }
                
                callBack(success: true, message: nil)
            }catch {
                callBack(success: false, message: "\(error)")
            }
    }
    
    /**
     Reads a string from a file
     
     - parameter path:     the file path
     - parameter enc:      the encoding
     - parameter callBack: the callBack
     
     - returns : N/A
     */
    func readString(contentsOfFile path: String,
        encoding enc: NSStringEncoding,
        callBack:(string:String?,success:Bool,message:String?)->())->(){
            do{
                let data=try NSData(contentsOfFile: path, options: [])
                let string:String?=String(data: data, encoding: enc)
                callBack(string: string,success:true,message:nil)
            }catch {
                callBack(string: nil, success: false, message: "\(error)")
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
    func writeString( string:String,
        path: String,
        atomically useAuxiliaryFile: Bool,
        encoding enc: NSStringEncoding,
        callBack:(success:Bool,message:String?)->())->(){
            do{
                try string.writeToFile(path, atomically: useAuxiliaryFile, encoding: enc)
                callBack(success: true, message: nil)
            }catch {
                callBack(success: false, message: "\(error)")
            }
            
    }
    
    
    /**
     Determines if a file exists and is a directory.
     
     - parameter path:     the path
     - parameter callBack: the call back
     
     - returns:  N/A
     */
    func fileExistsAtPath(path: String,
                          callBack:(exists:Bool,isADirectory:Bool,success:Bool,message:String?)->())->(){
            
            var isAFolder : ObjCBool = false
            let result=NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isAFolder)
            let isADirectory:Bool = isAFolder.boolValue
            callBack(exists:result,isADirectory:isADirectory,success: true,message: nil)
    }
    
    
    /**
     Removes the item at a given path
     Use with caution !
     
     - parameter path:     path
     - parameter callBack: the call back
     */
    func removeItemAtPath(path: String,
                               callBack:(success:Bool,message:String?)->())->(){
        do{
            try NSFileManager.defaultManager().removeItemAtPath(path)
            callBack(success: true, message: nil)
        }catch {
            callBack(success: false, message: "\(error)")
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
        callBack:(success:Bool,message:String?)->())->(){
            do{
                try NSFileManager.defaultManager().copyItemAtPath(srcPath, toPath: dstPath)
                callBack(success: true, message: nil)
            }catch {
                callBack(success: false, message: "\(error)")
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
        callBack:(success:Bool,message:String?)->())->(){
            do{
                try NSFileManager.defaultManager().moveItemAtPath(srcPath, toPath: dstPath)
                callBack(success: true, message: nil)
            }catch {
                callBack(success: false, message: "\(error)")
            }
    }
    
    
    /**
     Lists the content of the directory
     
     - parameter path:     the path
     - parameter callBack: the callBack
     
     - returns: N/A
     */
    func contentsOfDirectoryAtPath(path: String,
        callBack:(success:Bool,content:[String],message:String?)->())->(){
            do{
                let content=try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path)
                callBack(success: true, content: content, message: nil)
            }catch {
                callBack(success: false, content:[String](), message: "\(error)")
            }
    }
}