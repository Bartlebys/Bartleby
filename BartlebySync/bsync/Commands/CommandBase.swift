//
//  CommandBase.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 06/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Foundation


public class CommandBase{

    
    public var isVerbose=true
    
    let cli = CommandLine()
    
    init(){
        cli.usesSubCommands=true
    }
    
    func printVerbose(string: String) {
        if isVerbose {
            self.printVersatile(string)
        }
    }
    
    /**
     Versatile print method.
     
     - parameter string: the message
     */
    func printVersatile(string:String){
         if self.runAsCommandLine == true {
            print(string)
         }else{
            // Could be indiriged in future versions 
            // To provide feed back to the client
            print(string)
        }
    }

    
    var runAsCommandLine:Bool=true
    
     /**
     A versatile EXIT method to support commandline and XPC or lib calls
     with the same implementation
     
     - parameter code:    the exit code
     - parameter message: the message
     */
    func completion_EXIT(exitCode:Int32,message:String?){
        if self.runAsCommandLine == true {
            if let m=message {
                print(m)
            }
            exit(exitCode)
        }
        if ( self.completionBlock != nil ){
            if exitCode == EX_OK {
                self.completionBlock!(success: true,message: message)
            }else{
                self.completionBlock!(success: false,message: message)
            }
        }else{
            let m=message ?? ""
            print("No completion block found (!) exit code \(exitCode) message: \(m)")
        }
    }
    
    
    
    
    // MARK: Versatile completion
    
    var progressBlock:((taskIndex:Int,totalTaskCount:Int,taskProgress:Double,message:String?,data:NSData?)->())?
    
    func addProgressBlock(progressBlock:((taskIndex:Int,totalTaskCount:Int,taskProgress:Double,message:String?,data:NSData?)->())){
        self.progressBlock=progressBlock
    }
    
    
    // MARK: Versatile completion
    
    /// This completion block is used when not running as a commandline
    var completionBlock:((success:Bool,message:String?)->())?
    
    func addcompletionBlock(completionBlock:((success:Bool,message:String?)->())){
        self.completionBlock=completionBlock
    }
    
    
}
