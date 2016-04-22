//
//  CommandBase.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 06/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Foundation


public class CommandBase: ProgressAndCompletionHandler {

    
    public var isVerbose=true
    
    let cli = CommandLine()

    public required init(completionBlock:((success:Bool,message:String?)->())){
        super.init(completionBlock: completionBlock)
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
        if exitCode == EX_OK {
            self.completionBlock(success: true,message: message)
        }else{
            self.completionBlock(success: false,message: message)
        }
    }
}
